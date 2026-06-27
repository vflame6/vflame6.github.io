# frozen_string_literal: true

source "https://rubygems.org"

# Pinned to the 7.5.x series. This repo overrides Chirpy includes (head, sidebar,
# topbar, footer) but ships no _sass, so the theme's CSS/JS comes from the gem.
# A newer minor (e.g. 7.6) changes that CSS/JS and breaks the frozen overrides —
# and since Gemfile.lock is git-ignored, CI resolves the newest allowed version on
# every build. `~> 7.5.0` allows 7.5.x patches but holds the minor. Re-sync the
# overrides from the gem before bumping to 7.6+.
gem "jekyll-theme-chirpy", "~> 7.5.0"

gem "jekyll-paginate-v2"

gem "html-proofer", "~> 5.0", group: :test

platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

gem "wdm", "~> 0.2.0", :platforms => [:mingw, :x64_mingw, :mswin]

gem 'jekyll-compose', group: [:jekyll_plugins]
