# typed: strict
# frozen_string_literal: true

module Readers
  extend self

  sig { params(user: User).returns(Reader) }
  def create_reader(user)
    Reader.create!(user:)
  end
end
