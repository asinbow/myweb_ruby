class SceneInstance

  SCENE_WIDTH  = 500
  SCENE_HEIGHT = 400

  def initialize
    @connections_lock = Mutex.new
    @command_queue_lock = Mutex.new
    @processing = false
  end

  def all_connections
    @all_connections ||= {}
  end


  def command_queue
    @command_queue ||= []
  end

  def append_command(connection, command)
    command_queue.push([connection, command])
    process_command_queue
  end

  def process_command_queue
    while true
      connection, command = nil
      @command_queue_lock.synchronize do
        connection, command = command_queue.shift
        unless connection
          @processing = false
          return
        end
        return if @processing
      end

      process_command(connection, *command)
    end
  end

  def process_command(connection, command, args=nil)
    @connections_lock.synchronize do
      case command.to_i
      when Command::User::LOGIN
        puts "user login #{connection.client_signature}"
        all_connections[connection.client_signature] = connection
        all_connections.each do |client_signature, connection|
          connection.send [client_signature, Command::Push::LOGIN].to_json
        end
      when Command::User::LOGOUT
        puts "user logout #{connection.client_signature}"
        all_connections.delete(connection.client_signature)
        all_connections.each do |client_signature, connection|
          connection.send [client_signature, Command::Push::LOGOUT].to_json
        end
      when Command::User::TALK
        puts "user talk #{connection.client_signature}: #{args}"
        all_connections.each do |client_signature, connection|
          connection.send [client_signature, Command::Push::TALK, args].to_json
        end
      when Command::User::MOVE
      else
        raise "undefined command #{command}, #{args}"
      end
    end
  rescue Exception => e
    puts "#{e}\n#{e.backtrace.join("\n")}"
  end


end
