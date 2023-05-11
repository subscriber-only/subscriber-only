# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock "~> 3.17.2"

set :application, "subscriber_only"
set :repo_url, "git@github.com:subscriber-only/subscriber-only.git"

# Default branch is :master
set :branch, "main"

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/srv/www/subscriber_only"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, "config/credentials/production.key"

# Default value for linked_dirs is []
append :linked_dirs, ".bundle", ".yarn/cache", "node_modules", "public/assets",
       "storage", "tmp/cache", "vendor"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :chruby_ruby, "ruby-3.2.1"

set :migration_role, :app

set :assets_manifests, ["public/assets/.manifest.json"]
