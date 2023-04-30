# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: readers
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_readers_on_user_id  (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Reader < ApplicationRecord
  belongs_to :user

  has_many :subscriptions, dependent: :destroy

  delegate :email, to: :user
end
