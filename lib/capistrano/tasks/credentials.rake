# frozen_string_literal: true

namespace :deploy do
  namespace :check do
    before :linked_files, :set_production_key do
      on roles(:app), in: :sequence, wait: 10 do
        unless test("[ -f #{shared_path}/config/credentials/production.key ]")
          upload! "config/credentials/production.key",
                  "#{shared_path}/config/credentials/production.key"
        end
      end
    end
  end
end
