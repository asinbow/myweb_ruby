#!/usr/bin/env ruby

ROOT_PATH = File.expand_path(File.dirname(__FILE__) + '/..')
$LOAD_PATH << ROOT_PATH

require 'config/initialize'

require 'pry'

Pry.start

exit
