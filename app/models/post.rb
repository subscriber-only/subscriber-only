# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: posts
#
#  id         :bigint           not null, primary key
#  content    :text             not null
#  path       :string           not null
#  title      :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  site_id    :bigint           not null
#
# Indexes
#
#  index_posts_on_site_id           (site_id)
#  index_posts_on_site_id_and_path  (site_id,path) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (site_id => sites.id)
#
class Post < ApplicationRecord
  belongs_to :site
end
