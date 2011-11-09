EventMachine.run do
  EventMachine::WS.start :host => SERVER_CONFIG['host'], :port => SERVER_CONFIG['port']

end
