# frozen_string_literal: true

# Override the javascript:build task from jsbundling-rails.
Rake::Task["javascript:build"].clear

namespace :javascript do
  desc "Build your JavaScript bundle"
  task :build do
    sh "yarn install --immutable --immutable-cache && yarn build"
  end
end

Rake::Task["javascript:build"].enhance(["js:routes"])

if Rake::Task.task_defined?("assets:precompile")
  Rake::Task["assets:precompile"].enhance(["javascript:build"])
end

if Rake::Task.task_defined?("test:prepare")
  Rake::Task["test:prepare"].enhance(["javascript:build"])
elsif Rake::Task.task_defined?("spec:prepare")
  Rake::Task["spec:prepare"].enhance(["javascript:build"])
elsif Rake::Task.task_defined?("db:test:prepare")
  Rake::Task["db:test:prepare"].enhance(["javascript:build"])
end
