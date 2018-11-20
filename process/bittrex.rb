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
      ThreadsWait.all_waits(
        Thread.new do
          @currencies = ::Bittrex::Wallet.all.select { |obj| obj.available.to_d > 0.0 }.inject({}) do |h, obj|
            h[obj.currency] = obj.available.to_d
            h
          end
        end,
        Thread.new do
          @pairs = ::Bittrex::Summary.all.inject({}) do |h, obj|
            quote_asset, base_asset = obj.name.split('-')
            h[quote_asset] ||= {}
            h[quote_asset][base_asset] = obj.ask.to_d
            h
          end
        end
      )

      @currencies_usdt = {}
      @currencies.each do |symbol, amount|
        if symbol == 'USDT'
          @currencies_usdt[symbol] = amount
        elsif (rate = @pairs.dig('USDT', symbol))
          @currencies_usdt[symbol] = amount * rate
        elsif (rate1 = @pairs.dig('BTC', symbol)) && (rate2 = @pairs.dig('USDT', 'BTC'))
          @currencies_usdt[symbol] = amount * rate1 * rate2
        elsif (rate1 = @pairs.dig('ETH', symbol)) && (rate2 = @pairs.dig('USDT', 'ETH'))
          @currencies_usdt[symbol] = amount * rate1 * rate2
        else
          puts "Bittrex: Unknown #{symbol}"
        end
      end
    end
  end
end
