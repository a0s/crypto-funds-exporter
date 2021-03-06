class Exporter
  attr_reader :binance, :bittrex, :kucoin

  def initialize(prefix: '', binance_key: nil, binance_secret: nil, bittrex_key: nil, bittrex_secret: nil, kucoin_key: nil, kucoin_secret: nil)
    @prefix = prefix

    if binance_key && binance_secret
      @binance = Process::Binance.new(api_key: binance_key, secret_key: binance_secret)
    end

    if bittrex_key && bittrex_secret
      @bittrex = Process::Bittrex.new(api_key: bittrex_key, secret_key: bittrex_secret)
    end

    if kucoin_key && kucoin_secret
      @kucoin = Process::Kucoin.new(api_key: kucoin_key, secret_key: kucoin_secret)
    end
  end

  def request!
    threads = []
    threads << Thread.new { @binance.request! } if @binance
    threads << Thread.new { @bittrex.request! } if @bittrex
    threads << Thread.new { @kucoin.request! } if @kucoin
    ThreadsWait.all_waits(*threads) if threads.present?
  end

  def export
    result = []

    if @binance
      @binance.currencies.each do |currency, amount|
        result << "#{@prefix}funds{stock_exchange=\"binance\",currency=\"#{currency}\"} #{amount}"
      end
      @binance.currencies_usdt.each do |currency, amount|
        result << "#{@prefix}funds_usdt{stock_exchange=\"binance\",currency=\"#{currency}\"} #{amount}"
      end
    end

    if @bittrex
      @bittrex.currencies.each do |currency, amount|
        result << "#{@prefix}funds{stock_exchange=\"bittrex\",currency=\"#{currency}\"} #{amount}"
      end
      @bittrex.currencies_usdt.each do |currency, amount|
        result << "#{@prefix}funds_usdt{stock_exchange=\"bittrex\",currency=\"#{currency}\"} #{amount}"
      end
    end

    if @kucoin
      @kucoin.currencies.each do |currency, amount|
        result << "#{@prefix}funds{stock_exchange=\"kucoin\",currency=\"#{currency}\"} #{amount}"
      end
      @kucoin.currencies_usdt.each do |currency, amount|
        result << "#{@prefix}funds_usdt{stock_exchange=\"kucoin\",currency=\"#{currency}\"} #{amount}"
      end
    end

    funds_total = {}
    funds_total_usdt = {}

    if @binance
      @binance.currencies.each do |currency, amount|
        funds_total[currency] ||= 0.0
        funds_total[currency] += amount
      end
      @binance.currencies_usdt.each do |currency, amount|
        funds_total_usdt[currency] ||= 0.0
        funds_total_usdt[currency] += amount
      end
    end

    if @bittrex
      @bittrex.currencies.each do |currency, amount|
        funds_total[currency] ||= 0.0
        funds_total[currency] += amount
      end
      @bittrex.currencies_usdt.each do |currency, amount|
        funds_total_usdt[currency] ||= 0.0
        funds_total_usdt[currency] += amount
      end
    end

    if @kucoin
      @kucoin.currencies.each do |currency, amount|
        funds_total[currency] ||= 0.0
        funds_total[currency] += amount
      end
      @kucoin.currencies_usdt.each do |currency, amount|
        funds_total_usdt[currency] ||= 0.0
        funds_total_usdt[currency] += amount
      end
    end

    funds_total.each do |currency, amount|
      result << "#{@prefix}funds_total{currency=\"#{currency}\"} #{amount}"
    end

    funds_total_usdt.each do |currency, amount|
      result << "#{@prefix}funds_total_usdt{currency=\"#{currency}\"} #{amount}"
    end

    result.join("\n") + "\n"
  end
end
