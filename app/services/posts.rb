# typed: strict
# frozen_string_literal: true

module Posts
  extend self

  sig do
    params(site: Site, path: String, post_params: ActionController::Parameters)
      .returns(Post)
  end
  def upsert_post(site, path, post_params)
    post = Post.find_or_initialize_by(site:, path:)
    post.update!(post_params)
    post
  end

  sig { params(public_token: String, url: String).returns(Post) }
  def find_post(public_token, url)
    parsed_url = URI.parse(url)
    Post.joins(:site)
      .find_by!(path: parsed_url.path, site: { public_token: })
  end

  sig { params(post: Post, reader: T.nilable(Reader)).returns(T::Boolean) }
  def readable?(post, reader)
    Subscription.exists?(
      reader:, site: post.site, status: %w[active user_canceled],
    ) || reader&.user&.site == post.site
  end
end
