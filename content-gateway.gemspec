
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'content_gateway/version'

Gem::Specification.new do |gem|
  gem.name          = 'content_gateway'
  gem.version       = ContentGateway::VERSION
  gem.authors       = ['Túlio Ornelas',
                       'Roberto Soares',
                       'Emerson Macedo',
                       'Guilherme Garnier',
                       'Daniel Martins',
                       'Rafael Biriba',
                       'Célio Latorraca']
  gem.email         = ['ornelas.tulio@gmail.com',
                       'roberto.tech@gmail.com',
                       'emerleite@gmail.com',
                       'guilherme.garnier@gmail.com',
                       'daniel.tritone@gmail.com',
                       'biribarj@gmail.com',
                       'celio.la@gmail.com']
  gem.description   = 'An easy way to get external content with two cache levels. The first is a performance cache and second is the stale'
  gem.summary       = 'Content Gateway'
  gem.homepage      = 'https://github.com/globocom/content-gateway-ruby'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'activesupport', '>= 3'
  gem.add_dependency 'rest-client',   '~> 2.0'
  gem.add_dependency 'json',          '~> 2.0'

  gem.add_development_dependency 'rspec',     '~> 3.7',  '>= 3.7.0'
  gem.add_development_dependency 'simplecov', '~> 0.14', '>= 0.14.1'
  gem.add_development_dependency 'byebug',    '~> 9.1',  '>= 9.1.0'
  gem.add_development_dependency 'rake',      '~> 12.3', '>= 12.3.0'
end
