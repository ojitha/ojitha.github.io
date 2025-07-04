# Use Ruby 3.0 for better Jekyll compatibility
FROM ruby:3.0

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Install bundler
RUN gem install bundler:2.3.26

# Configure bundle
RUN bundle config set --local path 'vendor/bundle'
RUN bundle config set --local without 'production'

# Copy Gemfile and Gemfile.lock (if it exists) first for better caching
COPY Gemfile* ./

# Clear any existing lock file to avoid version conflicts
RUN rm -f Gemfile.lock

# Install gems
RUN bundle install

# Note: We don't copy the rest of the app here since we're using volumes in docker-compose
# The volume mount will provide the source code at runtime

# Expose ports
EXPOSE 4000 35729

# Default command
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--livereload", "--force_polling"]