echo "Running Sidekiq in the background..."
REDIS_URL="redis://127.0.0.1:6379/0" bundle exec sidekiq -C config/sidekiq.yml -r ./app.rb &


pid_file="server.pid"

# stops the server if it is already running
if [ -e "$pid_file" ]; then
  pid=$(cat "$pid_file")
  kill -9 "$pid"
  wait "$pid"
  rm "$pid_file"
fi

echo "Running the app..."
rackup --host 0.0.0.0 -P "$pid_file"