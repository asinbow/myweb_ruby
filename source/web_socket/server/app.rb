EventMachine.run do
  EventMachine::WebSocket.start :host => SERVER_CONFIG['host'], :port => SERVER_CONFIG['port'] do |ws|

    ws.onopen do
      puts "WebSocket connection open"
      ws.send "Hello Client"
    end

    ws.onclose do
      puts "Connection closed"
    end

    ws.onmessage do |message|
      puts "Received message: #{message}"
      ws.send "Pong: #{message}"
    end

  end
end
