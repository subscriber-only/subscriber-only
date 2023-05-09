# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name("plato@subscriber-only.com",
                                        "Plato | Subscriber Only")
  layout "mailer"
end
