# frozen_string_literal: true

module AccessTokens
  extend self

  def authorize_url(url, user)
    access_token = AccessToken.create!(user:)

    uri = URI.parse(url)
    params = uri.query ? CGI.parse(uri.query) : {}
    params["code"] = access_token.code

    uri.query = URI.encode_www_form(params)
    uri.to_s
  end

  def delete_all(user)
    AccessToken.where(user:).destroy_all
  end
end
