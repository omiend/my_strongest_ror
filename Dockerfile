FROM ruby:2.4.1

RUN apt-get update -qq \
    && apt-get install -y build-essential libpq-dev nodejs imagemagick libmagick++-dev \
    && apt-get install fonts-ipa* \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /employees

WORKDIR /employees

ADD Gemfile /employees/Gemfile

ADD Gemfile.lock /employees/Gemfile.lock

RUN bundle install

ADD . /employees

RUN cd /employees
