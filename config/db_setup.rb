require 'yaml'

DB_CONFIG = YAML.load_file('config/database.yml')

if File.exist?('config/database.yml.local')
  local_db_config = YAML.load_file('config/database.yml.local')
  DB_CONFIG.merge!(local_db_config)
end

DATABASE_URL = if DB_CONFIG['use_test_db']
                 DB_CONFIG['mongo_db_test_url']
               else
                 DB_CONFIG['mongo_db_url']
               end
