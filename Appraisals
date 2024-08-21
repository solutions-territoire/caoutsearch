# frozen_string_literal: true

appraise "elasticsearch-8.6" do
  gem "elasticsearch", "~> 8.6.0"
end

appraise "elasticsearch-8.7" do
  gem "elasticsearch", "~> 8.7.0"
end

appraise "elasticsearch-8.8" do
  gem "elasticsearch", "~> 8.8.0"
end

appraise "elasticsearch-8.9" do
  gem "elasticsearch", "~> 8.9.0"
end

appraise "elasticsearch-8.15" do
  gem "elasticsearch", "~> 8.15.0"
end

# Supported versions of Rails:
# https://endoflife.date/rails
#
if Gem::Version.new(RUBY_VERSION) <= Gem::Version.new("3.0")
  appraise "rails-6.1" do
    gem "activesupport", "~> 6.1.x"
    gem "sqlite3", "~> 1.4.0"
  end
end

appraise "rails-7.0" do
  gem "activesupport", "~> 7.0.x"
end

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.1")
  appraise "rails-7.1" do
    gem "activesupport", "~> 7.1.x"
  end

  appraise "rails-7.2" do
    gem "activesupport", "~> 7.2.x"
  end
end
