# typed: false
# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths <<
#   Rails.root.join("node_modules/bootstrap-icons")

Rails.application.config.after_initialize do |application|
  application.config.assets.paths = [
    "app/assets/builds",
    "app/assets/fonts",
    "app/assets/images",
  ]
end
