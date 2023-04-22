# frozen_string_literal: true

class ApplicationController < ActionController::Base
  default_form_builder ApplicationFormBuilder

  before_action :authenticate_user!

  layout :layout_by_resource

  protected

  def authenticate_with_sign_up!
    return if user_signed_in?

    store_location_for(:user, request.fullpath) if storable_location?
    redirect_to new_user_registration_path
  end

  def not_found
    raise ActionController::RoutingError, "Not Found"
  end

  private

  def layout_by_resource
    if devise_controller? && resource_name == :user
      "centered"
    elsif devise_controller? && resource_name == :admin
      false
    else
      "navbar"
    end
  end

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? &&
      !request.xhr?
  end
end
