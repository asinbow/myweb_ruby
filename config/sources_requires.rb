

def require_entire_directory(directory, recursive=true)
  failed = []
  Dir.entries(directory).each do |path|
    next if ['.', '..'].include?(path)
    path = File.join(directory, path)
    next if File.symlink?(path)
    if File.directory?(path)
      require_entire_directory(path, true) if recursive
      next
    end
    begin
      require(path) if path.end_with?('.rb')
    rescue Exception => e
      failed.push(path)
    end
  end
  failed.each do |path|
    require(path)
  end
end

SOURCE_COMMON_PATH = File.join(ROOT_PATH, 'source', 'common')
SERVER_ROOT_PATH = File.join(ROOT_PATH, 'source', SERVER_TYPE)

[SOURCE_COMMON_PATH, SERVER_ROOT_PATH].each do |directory|
  require_entire_directory(directory)
end


