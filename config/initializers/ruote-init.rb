require 'ruote/sylrplm/sylrplm'
# make changes when needed
#
# you may use another persistent storage for example or include a worker so that
# you don't have to run it in a separate instance
#
# See http://ruote.rubyforge.org/configuration.html for configuration options of
# ruote.
module SYLRPLM

ActiveRecord::Base.configurations = Rails.application.config.database_configuration
db_config=ActiveRecord::Base.configurations[Rails.env]
puts db_config
pg_db_config={}
pg_db_config["dbname"]=db_config["database"]
pg_db_config["user"]=db_config["username"]
pg_db_config["password"]=db_config["password"]
puts "#{__FILE__}:pg_db_config=#{pg_db_config}"

pg_connection = PG.connect(pg_db_config)
begin
	table_name='ruote_docs'
	Ruote::Postgres.create_table(pg_connection, true, table_name)
	storage_opts={"pg_table_name" => table_name}
	RUOTE_STORAGE=Ruote::Postgres::Storage.new(pg_connection, storage_opts)
	puts "#{__FILE__}:RUOTE_STORAGE=#{RUOTE_STORAGE}"
	pg_worker=Ruote::Worker.new(RUOTE_STORAGE)
	RuoteKit.engine  = Ruote::Dashboard.new(pg_worker)
rescue Exception=>e
	puts "#{__FILE__} Error:#{e}"
end



# By default, there is a running worker when you start the Rails server. That is
# convenient in development, but may be (or not) a problem in deployment.
#
# Please keep in mind that there should always be a running worker or schedules
# may get triggered to late. Some deployments (like Passenger) won't guarantee
# the Rails server process is running all the time, so that there's no always-on
# worker. Also beware that the Ruote::HashStorage only supports one worker.
#
# If you don't want to start a worker thread within your Rails server process,
# replace the line before this comment with the following:
#
# RuoteKit.engine = Ruote::Engine.new(RUOTE_STORAGE)
#
# To run a worker in its own process, there's a rake task available:
#
#     rake ruote:run_worker
#
# Stop the task by pressing Ctrl+C

unless $RAKE_TASK # don't register participants in rake tasks
  RuoteKit.engine.register do
    # register your own participants using the participant method
    # Example: participant 'alice', Ruote::StorageParticipant see
    # http://ruote.rubyforge.org/participants.html for more info
	puts "#{__FILE__}:loading participants"
	# only enter this block if the engine is running
	participant 'plm', Ruote::PlmParticipant
    # register the catchall storage participant named '.+'
    catchall
  end
end
puts "#{__FILE__}:>>>list of participants"
RuoteKit.engine.participant_list.each { |pe| puts "#{pe}" }
puts "#{__FILE__}:<<<list of participants"
#
# when true, the engine will be very noisy (stdout)
RuoteKit.engine.context.logger.noisy = false

end