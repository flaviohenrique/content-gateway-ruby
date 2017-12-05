module ContentGateway
  class Cache
    attr_reader :status

    def initialize(config, url, method, params = {})
      @config = config
      @url = url
      @method = method.to_sym
      @skip_cache = params[:skip_cache] || false
    end

    def use?
      !@skip_cache && %i[get head].include?(@method)
    end

    def fetch(request, params = {})
      timeout = params[:timeout] || @config.timeout
      expires_in = params[:expires_in] || @config.cache_expires_in
      stale_expires_in = params[:stale_expires_in] || @config.cache_stale_expires_in
      stale_on_error = config_stale_on_error params, @config

      begin
        Timeout.timeout(timeout) do
          @config.cache.fetch(@url, expires_in: expires_in) do
            @status = 'MISS'
            response = request.execute
            response = String.new(response) if response

            @config.cache.write(stale_key, response, expires_in: stale_expires_in)
            response
          end
        end
      rescue Timeout::Error => e
        begin
          serve_stale
        rescue ContentGateway::StaleCacheNotAvailableError
          raise ContentGateway::TimeoutError.new(@url, e, timeout)
        end
      rescue ContentGateway::ServerError => e
        begin
          raise e unless stale_on_error
          serve_stale
        rescue ContentGateway::StaleCacheNotAvailableError
          raise e
        end
      end
    end

    def serve_stale
      @config.cache.read(stale_key).tap do |cached|
        raise ContentGateway::StaleCacheNotAvailableError unless cached
        @status = 'STALE'
      end
    end

    def stale_key
      @stale_key ||= "stale:#{@url}"
    end

    private

    def config_stale_on_error(params, config)
      return params[:stale_on_error] unless params[:stale_on_error].nil?
      return config.stale_on_error unless config.try(:stale_on_error).nil?
      true
    end
  end
end
