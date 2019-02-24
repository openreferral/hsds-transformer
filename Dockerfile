FROM ruby:2.5.3

RUN gem install bundler -v 1.17.1

RUN bundle install

COPY .env.example .env
