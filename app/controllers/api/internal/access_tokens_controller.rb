# frozen_string_literal: true

class Api::Internal::AccessTokensController < ActionController::API
  def create
    access_token = AccessToken.find_by!(code: params[:code])
    access_token.update!(code: nil)
    render json: { access_token: access_token.token }
  end
end
