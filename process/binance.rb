module Process
  class Binance
    attr_reader :currencies, :currencies_usdt

    def initialize(api_key:, secret_key:)
      @api_key = api_key
      @secret_key = secret_key
    end

    def client
      @client ||= ::Binance::Client::REST.new(api_key: @api_key, secret_key: @secret_key)
    end

    def request!
      ThreadsWait.all_waits(
        Thread.new { @book_ticker = client.book_ticker },
        Thread.new { @account_info = client.account_info },
        Thread.new { @exchange_info = client.exchange_info['symbols'].inject({}) { |h, arr| h[arr['symbol']] = arr; h } }
      )

      @currencies =
        @account_info['balances']
          .map { |h| [h['asset'], h['free'].to_d] }
          .select { |_, free| free > 0.0 }
          .to_h

      pairs = {}
      @book_ticker.each do |h|
        base_asset = @exchange_info[h['symbol']]['baseAsset']
        quote_asset = @exchange_info[h['symbol']]['quoteAsset']

        pairs[quote_asset] ||= {}
        pairs[quote_asset][base_asset] = h['askPrice'].to_d
      end

      @currencies_usdt = {}
      @currencies.each do |symbol, amount|
        if symbol == 'USDT'
          @currencies_usdt[symbol] = amount
        elsif (rate = pairs.dig('USDT', symbol))
          @currencies_usdt[symbol] = amount * rate
        elsif (rate1 = pairs.dig('BTC', symbol)) && (rate2 = pairs.dig('USDT', 'BTC'))
          @currencies_usdt[symbol] = amount * rate1 * rate2
        elsif (rate1 = pairs.dig('ETH', symbol)) && (rate2 = pairs.dig('USDT', 'ETH'))
          @currencies_usdt[symbol] = amount * rate1 * rate2
        elsif (rate1 = pairs.dig('BNB', symbol)) && (rate2 = pairs.dig('USDT', 'BNB'))
          @currencies_usdt[symbol] = amount * rate1 * rate2
        else
          puts "Binance: Unknown #{symbol}"
        end
      end
    end
  end
end
