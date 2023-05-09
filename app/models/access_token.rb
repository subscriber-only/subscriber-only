# frozen_string_literal: true

# == Schema Information
#
# Table name: access_tokens
#
#  id           :bigint           not null, primary key
#  code         :string
#  last_used_on :datetime
#  token        :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_access_tokens_on_code     (code) UNIQUE
#  index_access_tokens_on_token    (token) UNIQUE
#  index_access_tokens_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class AccessToken < ApplicationRecord
  has_secure_token :code
  has_secure_token

  belongs_to :user
end
