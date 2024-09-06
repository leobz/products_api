echo "Running Sidekiq in the background..."
REDIS_URL="redis://127.0.0.1:6379/0" bundle exec sidekiq -C config/sidekiq.yml -r ./app.rb &

echo "Running the app..."
rackup