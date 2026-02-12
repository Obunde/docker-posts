# Align with Ruby 3.3.0, the version of the text
FROM ruby:3.1.4
 
RUN wget --quiet -O - /tmp/pubkey.gpg https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
 
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client yarn
RUN mkdir /blog_app
WORKDIR /blog_app
COPY Gemfile /blog_app/Gemfile
COPY Gemfile.lock /blog_app/Gemfile.lock
RUN gem install nokogiri --platform=ruby
RUN bundle config set force_ruby_platform true
RUN bundle install
COPY . /blog_app

# Precompile Rails assets
RUN RAILS_ENV=production bundle exec rails assets:precompile

# Run every time the container is started.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000
 
# rails s Execution.
CMD ["rails", "server", "-b", "0.0.0.0"]