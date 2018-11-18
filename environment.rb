$:.unshift(File.dirname(File.expand_path(__FILE__)))

require 'bigdecimal'
require 'bigdecimal/util'
require 'awesome_print'
require 'pry'
require 'active_support/all'
require 'thread'
require 'thwait'
require 'binance'
require 'bittrex'

AwesomePrint.defaults = { sort_keys: true }
AwesomePrint.pry!

require 'process/binance'
require 'process/bittrex'
require 'exporter'
