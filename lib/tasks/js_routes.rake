# frozen_string_literal: true

Rake::Task["javascript:build"].enhance(["js:routes"])
