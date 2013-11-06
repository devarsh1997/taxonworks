source 'https://rubygems.org'
ruby '2.0.0'

# This is interesting.
# gem 'rack-webconsole', git: 'https://github.com/grappendorf/rack-webconsole.git'

win_os = false

if $LOAD_PATH[0] =~ /[A-Za-z]:[\/\\]/
  win_os = true
  os = 'Windows'
else
  os = '*nix/os x'
end

puts "\nBundling on #{os}(#{$LOAD_PATH[0]})."

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.1'

# Database
#JDT 20131007
# The ffi gem for Windows 64-bit suffers from the same sort of problem as the mysql2 gem does, WRT Gemfile/bundler:
# the gem says it's name is 'ffi (1.9.0)', but the bundler resolves the requirement as 'ffi (1.9.0-x86-mingw32)',
# so we have both a Windows/*nix problem (x86-mingw32)
# the current fix is to add a line to the Gemfile.lock file to augment the file with the answer which is given by
# the ffi gem when asked what it's name is.  Thus, we make the following substitution:
#
#     ffi (1.9.3-x86-mingw32)
# becomes
#     ffi (1.9.3-x86-mingw32)
#     ffi (1.9.3-x64-mingw32)
#
# The pg gem suffers a similar problem, but with different specifics:
#
#     pg (0.17.0-x86-mingw32)
# becomes
#     pg (0.17.0-x86-mingw32)
#     pg (0.17.0-x64-mingw32)
#
#

gem 'ffi-geos'
gem 'rgeo-shapefile'
gem 'pg', '~> 0.17.0'
gem 'activerecord-postgis-adapter'

# Build instances from factories
gem "factory_girl_rails", "~> 4.0"

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 1.3'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster.
# Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.0'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :test do
  gem "rspec"
  gem 'coveralls', '~> 0.7', require: false
end

gem 'debugger', group: [:development, :test] if not win_os

group :development do 
  gem 'awesome_print'
end

gem 'rspec-rails', group: [:development, :test]

gem 'awesome_nested_set',  
  tag: '3.0.0.rc.2', 
  git: 'http://github.com/collectiveidea/awesome_nested_set.git'

# gem for decoding & encoding .bib files (BibTex bibliography files)
gem 'bibtex-ruby'

# Ordering records
gem 'acts_as_list'

# Use ActiveModel has_secure_password
#
# The bcrypt-ruby gem suffers a problem similar to that of the mysql2 gem, but with different specifics:
#
#     bcrypt-ruby (3.1.2-x86-mingw32)
# becomes
#     bcrypt-ruby (3.0.1-x86-mingw32)
#     bcrypt-ruby (3.0.1-x64-mingw32)
# 11/4/13 - I think it now needs to be the following:
#     bcrypt-ruby (3.1.2-x64-mingw32)
#     bcrypt-ruby (3.1.2-x86-mingw32)


gem 'bcrypt-ruby', '~> 3.1.2'

# gem for dumping DwC-A archives
gem "dwc-archive", "~> 0.9.6" if not win_os

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# 
