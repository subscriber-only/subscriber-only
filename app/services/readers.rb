# frozen_string_literal: true

module Readers
  extend self

  def create_reader(user)
    Reader.create!(user:)
  end
end
