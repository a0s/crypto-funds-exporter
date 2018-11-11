module Process
  class Bittrex
    attr_reader :currencies, :currencies_usdt

    def initialize(api_key:, secret_key:)
      ::Bittrex.config do |c|
        c.key = api_key
        c.secret = secret_key
      end
    end

    def request!
      @currencies = ::Bittrex::Wallet.all
                      .select { |obj| obj.available.to_d > 0.0 }
                      .inject({}) do |h, obj|
        h[obj.currency] = obj.available.to_d
        h
      end

      @currencies_usdt = {}
      @currencies.each do |symbol, amount|
        if symbol == 'USDT'
          @currencies_usdt[symbol] = amount
        elsif (quota = ::Bittrex::Quote.current("USDT-#{symbol}")) && quota.ask
          @currencies_usdt[symbol] = amount * quota.ask.to_d
        elsif (quota1 = ::Bittrex::Quote.current("BTC-#{symbol}")) && quota1.ask &&
          (quota2 = ::Bittrex::Quote.current("USDT-BTC")) && quota2.ask
          @currencies_usdt[symbol] = amount * quota1.ask.to_d * quota2.ask.to_d
        end
      end
    end
  end
end
