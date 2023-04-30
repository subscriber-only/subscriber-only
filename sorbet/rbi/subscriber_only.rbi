# typed: true
# frozen_string_literal: true

class Module
  include T::Sig
end

class ActionController::Base
  sig { returns(T::Boolean) }
  def user_signed_in?; end

  sig { returns(Symbol) }
  def resource_name; end

  sig { returns(User) }
  def current_user; end
end

class ActionController::API
  sig { returns(T::Boolean) }
  def user_signed_in?; end

  sig { returns(Symbol) }
  def resource_name; end

  sig { returns(User) }
  def current_user; end
end
