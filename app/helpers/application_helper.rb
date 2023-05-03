# frozen_string_literal: true

module ApplicationHelper
  def icon(name, width: 32, height: 32, class: "")
    klass = class_names("bi", binding.local_variable_get(:class))
    tag.svg(class: klass, width:, height:, fill: "currentColor") do
      svg_path = asset_path("bootstrap-icons.svg")
      tag.use(nil, "xlink:href": "#{svg_path}##{name}")
    end
  end

  def stripe_publishable_key
    Rails.application.credentials.dig(:stripe, :publishable_key)
  end
end
