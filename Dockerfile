
FROM ruby:3.3.4

WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install

COPY . .
EXPOSE 9292

# Configure the main process to run when running the image
CMD ["sh", "start_app.sh"]