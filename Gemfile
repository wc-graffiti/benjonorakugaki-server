source 'https://rubygems.org'
ruby '2.0.0'
#ruby-gemset=railstutorial_rails_4_0

gem 'rails', '4.0.5'


gem 'therubyracer'
gem 'sass-rails', '4.0.5'
gem 'uglifier', '2.1.1'
gem 'coffee-rails', '4.0.1'
gem 'jquery-rails', '3.0.4'
gem 'turbolinks', '1.1.1'
gem 'jbuilder', '1.0.2'

# ImageMagick
gem 'rmagick'
gem 'carrierwave'
gem 'ruby-filemagic'
gem 'carrierwave-magic'

# Grape, Jbuilder
gem 'grape'
gem 'grape-jbuilder'

# HAML
gem 'haml-rails'

# Bootstrap
gem 'less-rails' # Railsでlessを使えるようにする。Bootstrapがlessで書かれているため
gem 'twitter-bootstrap-rails' # Bootstrapの本体

# Database gem
# develop, test => SQLite
# production    => PostgreSQL
group :development, :test do
  gem 'sqlite3', '1.3.8'
end

group :production do
  gem 'pg', '0.15.1'  
  gem 'unicorn'
end

group :doc do
  gem 'sdoc', '0.3.20', require: false
end
