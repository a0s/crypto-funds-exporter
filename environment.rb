$:.unshift(File.dirname(File.expand_path(__FILE__)))

require 'bigdecimal'
require 'bigdecimal/util'
require 'awesome_print'
require 'pry'

AwesomePrint.defaults = { sort_keys: true }
AwesomePrint.pry!

require 'process/binance'
