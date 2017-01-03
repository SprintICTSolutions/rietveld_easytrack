FROM ruby:2.3

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y redis-server && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install

COPY . /usr/src/app

EXPOSE 3000

ENV RAILS_ENV staging
CMD rm /usr/src/app/tmp/pids/server.pid; rails db:migrate; redis-server --daemonize yes; bundle exec sidekiq -d -L /usr/src/app/log/sidekiq.log; bundle exec passenger start -e $RAILS_ENV
