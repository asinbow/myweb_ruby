require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/formatter/patternformatter'
require 'log4r/outputter/fileoutputter'
require 'log4r/outputter/consoleoutputters'
require 'log4r/outputter/datefileoutputter'
Log4r::PatternFormatter::DirectiveTable['L'] = '(event.tracer.nil? ? "no trace" : event.tracer.select{|e| e.include? ROOT_PATH}.first(3).map{|e| e.split(File::SEPARATOR)[-1].split(":")[0,2]}.flatten.join(",").gsub("rb,", ""))'
Log4r::PatternFormatter::DirectiveRegexp = /([^%]*)((%-?\d*(\.\d+)?)([cCdgtTmhpMlLxX%]))?(\{.+?\})?(.*)/

cfg=Log4r::YamlConfigurator
cfg['SERVER_ENV']=SERVER_ENV
cfg['ROOT_PATH']=ROOT_PATH
cfg.load_yaml_string ERB.new(File.open(ROOT_PATH + CONFIG_PATH + '/log4r.yml').read).result

LOGGER=Log4r::Logger['default']
MONITOR_LOGGER=Log4r::Logger['monitor']
STATISTICS_LOGGER=Log4r::Logger['statlog']
ERROR_LOGGER=Log4r::Logger['errorlog']
AUDIT_LOGGER=Log4r::Logger['auditlog']

case SERVER_ENV
when 'development'
  LOGGER.level=Log4r::DEBUG
  Log4r::Outputter['stdout'].level=LOGGER.level
  Log4r::Outputter['logfile'].level=LOGGER.level
when 'test'
  LOGGER.level=Log4r::OFF
  Log4r::Outputter['stdout'].level=Log4r::OFF
when 'production'
  LOGGER.level=Log4r::INFO
  Log4r::Outputter['stdout'].level=Log4r::OFF
  Log4r::Outputter['logfile'].level=LOGGER.level
else
  LOGGER.level=Log4r::INFO
  Log4r::Outputter['stdout'].level=Log4r::INFO
end

class Object
  def logger
    LOGGER
  end
  def monlog(subject, *args)
    log = args.join ', '
    log << yield.to_s if block_given? 
    subject += ": " << log unless log.empty?
    MONITOR_LOGGER.info subject
  end
  def statlog(subject, *args)
    log = args.join ', '
    log << yield.to_s if block_given? 
    subject += ": " << log unless log.empty?
    LOGGER.debug subject
    STATISTICS_LOGGER.info subject
  end
  def logerror(error)
    if error.is_a? Exception
      if error.is_a? Exceptions::BaseException
        error_message = "#{error.message}(#{error.class})\n#{error.backtrace[0,3].join("\n")}" 
        logger.warn error_message
        return
      else
        backtrace = error.backtrace.size > 50 ? error.backtrace[0, 20] : error.backtrace
        error_message = "#{error.message}(#{error.class})\n#{backtrace.join("\n")}" 
        unless env_test?
          begin
            Util::MessageUtils.send_mail "Server Error: [#{error.message}] ", error_message
          rescue Exception => e
            logerror "Email error: #{e.message}"
          end
        end
      end
    else
      error_message = error
    end
    logger.error error_message
    ERROR_LOGGER.error error_message
  end
  def alertlog(*args)
    logger.warn WARNING_TEMPLATE % args.map(&:to_s).join(',')
  end

end
WARNING_TEMPLATE = "
\033[31m
======================================================================================
======================================================================================
================================                      ================================
================================   WARNING !!!!!!!!!! ================================
================================                      ================================

%s

================================                      ================================
================================   WARNING !!!!!!!!!! ================================
================================                      ================================
======================================================================================
======================================================================================
\033[0m
"
puts "log initialized"
