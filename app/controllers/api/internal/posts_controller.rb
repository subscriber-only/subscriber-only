# frozen_string_literal: true

class Api::Internal::PostsController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_with_bearer

  def show
    post = Posts.find_post(params[:public_token], params[:post_url])
    unless Posts.readable?(post, current_user.reader)
      render status: :forbidden, json: { message: "Not subscribed to author." }
      return
    end
    render json: post
  end

  private

  attr_reader :current_user

  def authenticate_with_bearer
    access_token = authenticate_with_http_token do |token, _options|
      AccessToken.find_by(token:)
    end
    request_http_token_authentication and return unless access_token

    @current_user = access_token.user
    access_token.update!(last_used_on: Time.current)
  end
end
