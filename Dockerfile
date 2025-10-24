# Tested for the ruby:3.3.4
FROM ruby:3.1

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

# Install bundler (use a compatible version with github-pages)
RUN gem install bundler:2.4.22

# Configure bundle to use a directory that won't be overridden by volume mounts
RUN bundle config set --global path '/usr/local/bundle'
RUN bundle config set --global without 'production'

# Create a script to handle gem installation at runtime
COPY <<EOF /usr/local/bin/entrypoint.sh
#!/bin/bash
set -e

# Ensure we're in the app directory
cd /app

# Install gems if Gemfile exists and gems aren't already installed
if [ -f Gemfile ]; then
    echo "Installing gems..."
    bundle check || bundle install
fi

# Execute the main command
exec "\$@"
EOF

RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose ports
EXPOSE 4000 35729

# Use the entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default command
CMD ["bundle", "exec", "jekyll", "serve", \
     "--incremental", \
     "--limit_posts", "1", \
     "--host", "0.0.0.0", \
     "--livereload", \
     "--force_polling", \
     "--livereload-port", "35729", \
     "--trace", \
     "--drafts"]