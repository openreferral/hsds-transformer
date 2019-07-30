FROM ruby:2.5.3

RUN gem install bundler -v 1.17.1

RUN mkdir /app

COPY . /app
COPY .env.example /app/.env

WORKDIR /app

RUN bundle install

EXPOSE 4567
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]