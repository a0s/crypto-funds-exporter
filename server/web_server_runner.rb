require File.expand_path(File.join(__FILE__, %w(.. .. environment.rb)))

class WebServerRunner
  ENV_PREFIX = 'CRYPTO_FUNDS_EXPORTER_'
  EXPORT_PREFIX = 'crypto_funds_exporter_'

  def initialize
    Thread.abort_on_exception = true
    WebServer.class_eval { set :server, :puma }
    WebServer.class_eval { set :port, (ENV[ENV_PREFIX + 'PORT'] || 9518).to_i }
    WebServer.class_eval { set :bind, ENV[ENV_PREFIX + 'HOST'] || '0.0.0.0' }
    WebServer.class_eval do
      set :exporter, Exporter.new(
        prefix: ENV[ENV_PREFIX + 'EXPORT_PREFIX'] || EXPORT_PREFIX,
        binance_key: ENV[ENV_PREFIX + 'BINANCE_KEY'],
        binance_secret: ENV[ENV_PREFIX + 'BINANCE_SECRET'],
        bittrex_key: ENV[ENV_PREFIX + 'BITTREX_KEY'],
        bittrex_secret: ENV[ENV_PREFIX + 'BITTREX_SECRET'],
        kucoin_key: ENV[ENV_PREFIX + 'KUCOIN_KEY'],
        kucoin_secret: ENV[ENV_PREFIX + 'KUCOIN_SECRET'])
    end
  end

  def run!
    WebServer.run!
  end
end

WebServerRunner.new.run!
