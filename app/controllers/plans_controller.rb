# typed: false
# frozen_string_literal: true

class PlansController < ApplicationController
  before_action -> { @site = current_user.site }

  def edit
    @plan = @site.current_plan
  end

  def create
    ret_code, @plan = Plans.update_plan(plan_params, @site)

    if ret_code == :ok
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_site_path }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def plan_params
    params.require(:plan).permit(
      :monthly_price,
      :monthly_price_currency,
      :yearly_price,
      :yearly_price_currency,
    )
  end
end
