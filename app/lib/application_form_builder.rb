# typed: false
# frozen_string_literal: true

class ApplicationFormBuilder < ActionView::Helpers::FormBuilder
  def field_errors(method)
    return unless errors?(method)

    # rubocop:disable Rails/OutputSafety
    @template.tag.div(
      @object.errors.full_messages_for(method).join("<br />").html_safe,
      class: "invalid-feedback",
    )
    # rubocop:enable Rails/OutputSafety
  end

  private

  def errors?(method)
    return false unless @object.respond_to?(:errors)

    @object.errors.key?(method)
  end
end
