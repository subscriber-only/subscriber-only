# frozen_string_literal: true

namespace :good_job do
  desc "Restart GoodJob"
  task :restart do
    on roles(:app) do
      execute :systemctl, "restart good_job"
    end
  end
end

after "deploy:finished", "good_job:restart"
