# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.3.5

FROM ruby:$RUBY_VERSION-slim

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev
# ubuntu-dev-tools
# nodejs git imagemagick libmagickwand-dev libyaml-dev
# gcc
# libffi-dev
# make

ARG BUNDLER_VERSION=2.3.25

# throw errors if Gemfile has been modified since Gemfile.lock
RUN gem install bundler -v ${BUNDLER_VERSION} && bundle config --global allow_offline_install 1 jobs 5

WORKDIR /app

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
