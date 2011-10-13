
$LOAD_PATH << File.join(ROOT_PATH, 'config')

require 'gems_requires'

SERVER_TYPE = ENV['SERVER_TYPE']
server_yml_file = File.join(ROOT_PATH, 'config/yml/server.yml')
SERVERS_CONFIG = YAML.load(File.read(server_yml_file))['servers']
SERVER_CONFIG = defined?(SERVER_TYPE) ? SERVERS_CONFIG[SERVER_TYPE] : nil


require 'pre_initialize'

# TODO


require 'post_initialize'

require 'sources_requires'
