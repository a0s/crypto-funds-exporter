module Process
  class Kucoin
    attr_reader :currencies, :currencies_usdt

    def initialize(api_key:, secret_key:)
      ::KucoinRuby::Net.class_eval do
        define_singleton_method :key, -> { api_key }
        define_singleton_method :secret, -> { secret_key }
      end
    end

    def request!
      ThreadsWait.all_waits(
        Thread.new do
          operation_balance = ::KucoinRuby::Operations.balance
          @currencies = operation_balance['data'].select { |h| h['balance'] > 0.0 }.inject({}) do |h, hash|
            key, value = hash.values_at('coinType', 'balance')
            h[key] = value.to_d
            h
          end
        end,
        Thread.new { @pairs = ::KucoinRuby::Currency.exanges['data']['rates'] }
      )

      @currencies_usdt = {}
      @currencies.each do |symbol, amount|
        if symbol == 'USDT'
          @currencies_usdt[symbol] = amount
        elsif (rate1 = @pairs.dig(symbol, 'IDR')) && (rate2 = @pairs.dig('USDT', 'IDR'))
          @currencies_usdt[symbol] = amount * rate1 / rate2
        else
          puts "Kucoin: Unknown #{symbol}"
        end
      end
    end
  end
end
