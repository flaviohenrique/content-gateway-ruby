module ContentGateway
  class Request
    def initialize(method, url, headers = {}, payload = {}, proxy = nil, params = {})
      data = { method: method, url: url, proxy: proxy || :none }.tap do |h|
        h[:payload] = payload if payload.present?
        h[:headers] = headers if headers.present?
        load_ssl_params(h, params) if params.key?(:ssl_certificate)
      end
      RestClient.proxy = proxy
      @client = RestClient::Request.new(data)
    end

    def execute
      @client.execute
    rescue RestClient::ResourceNotFound => e1
      raise ContentGateway::ResourceNotFound.new url, e1
    rescue RestClient::Unauthorized => e2
      raise ContentGateway::UnauthorizedError.new url, e2
    rescue RestClient::UnprocessableEntity => e3
      raise ContentGateway::ValidationError.new url, e3
    rescue RestClient::Forbidden => e4
      raise ContentGateway::Forbidden.new url, e4
    rescue RestClient::Conflict => e5
      raise ContentGateway::ConflictError.new url, e5
    rescue RestClient::PreconditionFailed => e6
      raise ContentGateway::PreconditionFailed.new url, e6
    rescue RestClient::BadRequest => e7
      raise ContentGateway::BadRequest.new url, e7
    rescue RestClient::Exception => e8
      status_code = e8.http_code
      raise e8 if status_code && status_code < 500
      raise ContentGateway::ServerError.new url, e8, status_code
    rescue StandardError => e9
      raise ContentGateway::ConnectionFailure.new url, e9
    end

    private

    def load_ssl_params(h, params)
      ssl_client_cert = params[:ssl_certificate][:ssl_client_cert]
      ssl_client_key = params[:ssl_certificate][:ssl_client_key]
      if ssl_client_cert || ssl_client_key
        client_cert_file = File.read ssl_client_cert
        client_cert_key = File.read ssl_client_key

        h[:ssl_client_cert] = OpenSSL::X509::Certificate.new(client_cert_file)
        h[:ssl_client_key] = OpenSSL::PKey::RSA.new(client_cert_key)
        h[:verify_ssl] = OpenSSL::SSL::VERIFY_NONE
      end

      ssl_version = params[:ssl_certificate][:ssl_version]
      h[:ssl_version] = ssl_version if ssl_version

      h
    rescue Errno::ENOENT => e0
      raise ContentGateway::OpenSSLFailure.new h[:url], e0
    rescue OpenSSL::X509::CertificateError => e1
      raise ContentGateway::OpenSSLFailure.new h[:url], e1, 'invalid ssl client cert'
    rescue OpenSSL::PKey::RSAError => e2
      raise ContentGateway::OpenSSLFailure.new h[:url], e2, 'invalid ssl client key'
    end

    def url
      @client.url
    end
  end
end
