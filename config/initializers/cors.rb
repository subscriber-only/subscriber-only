# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins do |source, _env|
      parsed_source = URI(source)
      Site.exists?(domain: parsed_source.host)
    end
    resource "/api/internal/access_tokens", methods: [:post]
    resource "/api/internal/posts", methods: [:get], headers: "Authorization"

    # These rules are only used in development.
    origins "*"
    resource "/so.js"
  end
end
