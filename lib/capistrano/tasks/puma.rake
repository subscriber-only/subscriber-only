# frozen_string_literal: true

namespace :puma do
  desc "Restart Puma"
  task :restart do
    on roles(:app) do
      execute :systemctl, "restart puma"
    end
  end
end

after "deploy:finished", "puma:restart"
