source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.3'
# Use sqlite3 as the database for Active Record
gem 'mysql2', '~> 0.3.13'
# Use Puma as the app server
gem 'puma', '~> 3.12'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

################################################################################
# add on gem's
################################################################################
gem 'dotenv-rails'         # 環境変数

gem 'devise'       # 認証機能周り

gem 'jquery-rails'       # BootstrapがjQueryに依存しているため
gem 'bootstrap-sass'     # Bootstrap本体
gem 'autoprefixer-rails' # 自動でベンダープレフィックスをつけてくれる
gem 'simple_form'        # フォーム簡易作成

gem 'carrierwave' # 画像アップロード用
gem 'fog-aws'     # AWS S3連携用
gem 'rmagick'     # 画像処理用

gem 'wkhtmltopdf-binary' # PDF生成
gem 'wicked_pdf'         # PDF生成

group :development do
  gem 'letter_opener_web'  # localhostで送付されたメールを確認出来るツール
  gem 'better_errors'        # デバッグで利用
  gem 'binding_of_caller'    # デバッグで利用
  gem 'pry-byebug'           # デバッグを実施(Ruby 2.0以降で動作する)
end
