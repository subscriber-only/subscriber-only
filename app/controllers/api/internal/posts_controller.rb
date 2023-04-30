# typed: strict
# frozen_string_literal: true

class Api::Internal::PostsController < ActionController::API
  before_action :authenticate_user!

  sig { void }
  def show
    post = Posts.find_post(params[:public_token], params[:post_url])
    unless Posts.readable?(post, current_user.reader)
      render status: :forbidden, json: { message: "Not subscribed to author." }
      return
    end
    render json: post
  end
end
