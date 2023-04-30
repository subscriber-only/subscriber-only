# typed: false
# frozen_string_literal: true

class SitesController < ApplicationController
  prepend_before_action :authenticate_with_sign_up!, only: :new

  before_action :redirect_if_present, only: %i[new create]

  def new
    @site = Site.new
  end

  def edit
    @site = Site.find_by(user: current_user)
    redirect_to action: :new if @site.blank?
  end

  def create
    @site = Site.new(site_params.merge(user: current_user))

    if @site.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_site_path }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @site = Site.find_by!(user: current_user)

    if @site.update(site_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_site_path }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def site_params
    params.require(:site).permit(:name, :domain)
  end

  def redirect_if_present
    redirect_to action: :edit if current_user.site.present?
  end
end
