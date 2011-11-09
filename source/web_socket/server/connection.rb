module EventMachine
  module WS

    class Connection < EventMachine::WebSocket::Connection

      def initialize(options)
        puts options.inspect
        super options
      end

      def client_signature
        @client_signature ||= begin
                         @remote_port, @remote_host = Socket.unpack_sockaddr_in get_peername
                         @remote_host.to_s + ':' + @remote_port.to_s
                       end
      end

      def trigger_on_message(msg)
        EventMachine::WS.scene_instance.append_command(self, JSON.load(msg))
      end

      def trigger_on_open
        EventMachine::WS.scene_instance.append_command(self, [Command::User::LOGIN])
      end

      def trigger_on_close
        EventMachine::WS.scene_instance.append_command(self, [Command::User::LOGOUT])
      end


    end

    class << self

      def scene_instance
        @scene_instance ||= SceneInstance.new
      end

      def start(options)
        EM.epoll
        EM.run do
          trap("TERM") { stop }
          trap("INT")  { stop }
          EventMachine::start_server(options[:host], options[:port], EventMachine::WS::Connection, options)
        end
      end

      def stop
        puts "Terminating WebSocket Server"
        EventMachine.stop
      end

    end

  end

end
