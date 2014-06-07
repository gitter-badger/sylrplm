#
require 'rufus/scheduler'

#
# fichier de log specifique
#
logfile       = File.join(Rails.root, 'log', 'sylrplm.log')
LOG           = Logger.new(logfile, 'daily')
# Install custom formatter!
LOG.formatter = Classes::AppClasses::LogFormatter.new
#@logger.datetime_format = "%Y-%m-%d %H:%M:%S"
#DEBUG INFO WARN ERROR FATAL
LOG.level  = case Rails.env
when "development"
	Logger::DEBUG
when "test"
	Logger::DEBUG
when "production"
	Logger::DEBUG
end
LOG.info("sylrplm"){"Lancement SYLRPLM"}
LOG.progname="Constantes"
LOG.info {"Constantes du module SYLRPLM:"}
SYLRPLM.constants.sort.each do |c|
	v = SYLRPLM.const_get(c)
	LOG.debug("Constantes"){"#{c}\t\t= #{v}"}
end
LOG.info ("sylrplm"){"env=#{Rails.env.inspect} loglevel=#{LOG.level}"}
LOG.info ("sylrplm"){"--------------------------------------------"}

scheduler = Rufus::Scheduler.start_new
puts '*** Starting Scheduler ***'
#scheduler.cron '0 21 * * 1-5' do
# every day of the week at 21:00
scheduler.cron '*/5 7-21 * * 1-5' do
# every 5 mn of each hour during the week
	Notification.notify_all(nil)
#Rake.application[:notify].invoke
#Rake::Task["notify"].invoke
end

