worker_processes 3
timeout 30
preload_app true
 
before_fork do |server, worker|
  # Replace with MongoDB or whatever
  if defined?(Sequel::Model)
    Sequel::Model.db.disconnect
  end
  
  sleep 1
end
  
after_fork do |server, worker|
  # Replace with MongoDB or whatever
  if defined?(Sequel::Model)
    Sequel::Model.db.connect(ENV['DATABASE_URL'])
  end
end
