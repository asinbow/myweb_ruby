
server_yml_file = File.join(ROOT_PATH, 'config/yml/server.yml')
SERVERS_CONFIG = YAML.load(File.read(server_yml_file))
SERVER_CONFIG = defined?(SERVER_TYPE) ? SERVERS_CONFIG[SERVER_TYPE] : nil

$LOAD_PATH << File.join(ROOT_PATH, 'config')

require 'gems_requires'
require 'pre_initialize'

# TODO


require 'post_initialize'

require 'sources_requires'
