require 'active_record'
require 'erb'
require 'pg'
require 'yaml'
require 'byebug'
require 'webdrivers'
require 'selenium-webdriver'

require File.join(File.absolute_path('.'), "general_actions.rb")
require File.join(File.absolute_path('.'), "scraper.rb")

config_path = File.join(File.absolute_path('.'), "config.yml")
ActiveRecord::Base.configurations = YAML.load(ERB.new(File.read(config_path)).result)
ActiveRecord::Base.establish_connection(:development)
# Set a logger so that you can view the SQL actually performed by ActiveRecord
logger = Logger.new(STDOUT)
logger.formatter = proc do |severity, datetime, progname, msg|
   "#{msg}\n"
end
ActiveRecord::Base.logger = logger

Dir["#{__dir__}/models/*.rb"].each {|file| require file }
