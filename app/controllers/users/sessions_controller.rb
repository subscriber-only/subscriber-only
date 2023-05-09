# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    super do |user|
      return_to = params.dig(:user, :return_to)
      if return_to.present?
        flash[:notice] = nil
        return_to = AccessTokens.authorize_url(return_to, user)
        redirect_to return_to, allow_other_host: true
        return
      end
    end
  end

  # DELETE /resource/sign_out
  def destroy
    AccessTokens.delete_all(current_user)
    super
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:return_to])
  end

  def require_no_authentication
    assert_is_devise_resource!
    return unless is_navigational_format?

    no_input = devise_mapping.no_input_strategies
    authenticated = if no_input.present?
      args = no_input.dup.push(scope: resource_name)
      warden.authenticate?(*args)
    else
      warden.authenticated?(resource_name)
    end
    resource = warden.user(resource_name)

    return if !authenticated || !resource

    return_to = if params[:return_to].present?
      AccessTokens.authorize_url(params[:return_to], resource)
    else
      after_sign_in_path_for(resource)
    end
    redirect_to return_to, allow_other_host: true
  end
end
