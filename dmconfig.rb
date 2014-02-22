require 'data_mapper'
DataMapper::Logger.new($stdout, ENV.fetch("LOG_LEVEL", "error").to_sym)
db_path = File.join(File.dirname(__FILE__), 'cache.db')
DataMapper.setup(:default, "sqlite://#{db_path}")
DataMapper.auto_upgrade!
