

def require_entire_directory(directory, recursive=true)
  Dir.entries(directory).each do |path|
    next if ['.', '..'].include?(path)
    path = File.join(directory, path)
    next if File.symlink?(path)
    if File.directory?(path)
      require_entire_directory(path, true) if recursive
      next
    end
    require(path) if path.end_with?('.rb')
  end
end

SERVER_TYPE = ENV['SERVER_TYPE']
SERVER_ROOT_PATH = File.join(ROOT_PATH, 'source', SERVER_TYPE)
require_entire_directory(SERVER_ROOT_PATH)

