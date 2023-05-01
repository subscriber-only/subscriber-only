# typed: false
# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "plato@subscriber-only.com"
  layout "mailer"
end
