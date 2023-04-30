# typed: false
# frozen_string_literal: true

class Api::V1::PostsController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_site
  before_action :ensure_setup

  def create
    post = Posts.upsert_post(@site, params[:path], post_params)
    render json: post
  end

  private

  def post_params
    params.require(:post).permit(:path, :title, :content)
  end

  def authenticate_site
    if request.headers["Authorization"].blank?
      render status: :unauthorized, json: {
        message: "You did not provide a secret token. You need to pass the " \
                 "secret token in an Authorization header, using the Bearer " \
                 "scheme (e.g. 'Authorization: Bearer YOUR_SECRET_TOKEN'). " \
                 "See #{new_site_url} for details.",
      }
      return
    end

    site = authenticate_with_http_token do |token, _options|
      Site.find_by(secret_token: token)
    end
    if site.nil?
      render status: :forbidden, json: {
        message: "Invalid secret token provided. Go to #{edit_site_url} for " \
                 "details.",
      }
      return
    end

    @site = site
  end

  def ensure_setup
    return if @site.setup?

    render status: :forbidden, json: {
      message: "You need to fully setup your site before being able to " \
               "upload posts. Go to #{edit_site_url} for details.",
    }
  end
end
