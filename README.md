## はじめに

６月に新しい会社に来て以来、会社ではRuby on Railsばかり触っている。

RoRの開発・Ruby自体初めてなので~~（本当はScalaやりたい）~~、開発環境構築をやってみたのだが、「これ本当に必要なの？」などなど分からないことだらけで、何度かハマった。

そして、最終的に開発環境構築をおえるまで３日もかかったという非常に厳しい結果に終わった。

今後、新しく入ってくるエンジニアがこんな苦労をしなくても良いように、なるべく簡単に、そして誰もが共通で開発環境を構築出来るスキームを・・・と考えた結果、Dockerを採用するこ。

さて、RoRのいいところは「サービス開発の速さ」だと思っている。そんなRoRを利用して「最近よくありがちな機能を含むサービスを一から作るならば」という観点を元に、Dockerを使った「ぼくがかんがえたさいきょうのRails開発環境」をまとめた。

## 機能

機能は、ざっと下記の通り。

最近のアプリ開発では割りとありがちな内容を想定している。

- ログイン認証周りの機能
- リレーショナル・データベースによる永続化（MySQLを想定）機能
- ローカル環境における、S3相当のサーバー（[minio.io](https://www.minio.io/)を利用）へ画像をアップロードする機能

これらの環境をすべて `docker-compose up` するだけ（さいきょうっぽいところ）で、雛形が立ち上がるようにするのがゴールだった。

## 使い方

ソースは[コチラ](https://github.com/omiend/my_strongest_ror)

#### Docker for Macのインストール

[Docker for Mac](https://www.docker.com/docker-mac)からDocker for Macをインストール。

#### git clone

```
git@github.com:omiend/my_strongest_ror.git
```

#### docker-compose up

```
$ cd employees/docker
$ docker-compose up
```










## 以下は、この環境を構築した時のメモ

## Railsの環境構築

まずはRailsの開発環境をDockerとは別で作成する。が、これは結局Railsの雛形を作りたいためのもの。

もし既存のアプリがあるようであれば、読み飛ばして「Docker周りの環境構築」から読んでも大丈夫だと思う。

#### rbenv

`homebrew` でインストール

```
$ brew install rbenv
```

#### bundler 

`rbenv` でインストール

```
$ rbenv exec gem install bundler
```

#### rails

`rbenv` でインストール

```
$ rbenv exec gem install rails
```

#### Railsアプリケーションの雛形を作成する

`rails` で作成する

`employees` はアプリケーション名

```
$ rails new employees
```

#### Railsアプリケーションの実行

```
$ cd employees/
$ rails s
```

[localhost:3000](http://localhost:3000)にアクセスし、Railsデフォルトのウェルカム画面が表示されればOK。








## かんたんなアプリの作成

例として、従業員を管理するかんたんなアプリを作成する

#### Gemfileの修正

rails5だと、既存でsqlite3を利用するようなので、mysql2に変更。

```
- gem 'sqlite3'
+ gem 'mysql2', '~> 0.3.13'
```

修正したら `bundle install` し直す。

#### database.ymlの修正

mysqlにつなげるための設定。

これは後でdockerのコンテナで稼働するDBに置き換わる予定だが、とりあえず一旦 `localhose(127.0.0.1:3306)` でMySQLが稼働している想定。

```
default: &default
-  adapter: sqlite3
+  adapter: mysql2
+  encoding: utf8
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000

development:
  <<: *default
-  database: db/development.sqlite3
+  database: employees
+  username: root
+  password: 
+  host: 127.0.0.1
+  port: 3306
```

#### DBのSchema作成

Schema定義は、下記SQLでとりあえず。

```
create database employees default character set utf8;
```

#### Modelの作成

`scaffold` で作成してしまう。

```
$ rails g scaffold users name:string age:integer
```

#### マイグレーションの実行

```
$ $ rails db:migrate
```

#### アプリ動作確認

`rails s` で立ち上げ、[localhost:3000](http://localhost:3000/users)にアクセスし、usersテーブルにデータが保存出来る様にフォームが動けばOK。










## ログイン機能の実装

ログイン機能はdeviseを利用。

#### Gemfileの編集

```
gem 'devise'
```

#### bundle install実行

```
$ bundle install
```

deviseについてはネット上に色々情報があるので、詳細はそちらを参照。

僕は下記を参考にさせてもらった。

[[*Rails*] deviseの使い方（rails5版）](http://qiita.com/cigalecigales/items/f4274088f20832252374)











## LetterOpenerWeb の追加

[LetterOpenerWeb](https://github.com/fgrehm/letter_opener_web)は、ローカル環境にて送信したメールをブラウザで確認できるツール。

#### gemの追加

Gemfileに追記

```
group :development, :test do
  gem 'letter_opener_web'  # localhostで送付されたメールを確認出来るツール
end
```

同じく `bundle install` を実行

```
$ docker exec employees_app bundle install
```

#### routing追加

`config/routes.rb` に下記を追加

```
if Rails.env.development?
  mount LetterOpenerWeb::Engine, at: "/letter_opener"
end
```

[localhost:3000](http://localhost:3000/letter_opener)にアクセスすると、ちょっとしたメールクライアントが表示される。

とても便利！










---

以上、ここまでがrailsの基本的なアプリ作成の流れ。











## Docker周りの環境構築

ココからが本番。

作成したアプリを、MacOSにインストールしたRailsではなく、Dockerコンテナ上で動作させるようにする。

#### Docker for Macのインストール

まずは[Docker for Mac](https://www.docker.com/docker-mac)からDocker for Macをインストール。

#### Railsアプリをコンテナ化するためのDockerfileを作成

`employees` ディレクトリ直下に、下記の様なファイルを配置する。

```
FROM ruby:2.4.1
RUN apt-get update -qq \
    && apt-get install -y build-essential libpq-dev nodejs imagemagick libmagick++-dev \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /employees

WORKDIR /employees

ADD Gemfile /employees/Gemfile

ADD Gemfile.lock /employees/Gemfile.lock

RUN bundle install

ADD . /employees

RUN cd /employees
```

[docs.docker.com/compose/rails](https://docs.docker.com/compose/rails/)を参考に作ったもの。

Dockerfileのコマンドは、[docs.docker.jp/engine/reference/builder.html](http://docs.docker.jp/engine/reference/builder.html)を参考にした。

#### Dockerの作業ディレクトリを作成

アプリについては、アプリ用という意味で `employees/` 直下にDockerfileを配置しているが、ソレ以外のサーバー（MySQLとS3）については `employees/docker` ディレクトリにすべてまとめて置きたい。

```
$ mkdir docker
```

#### MySQL用のディレクトリの作成

```
$ mkdir docker/mysql
```

#### MySQL用のDockerfile作成

公式のMySQL Imageを利用するためのもの

```
$ echo -n "FROM mysql:5.7" > docker/mysql/Dockerfile
```

#### 初回起動時に実行してくれるSQLファイルを作成

公式MySQLイメージの機能で、`docker-compose up` 時に指定のSQLを実行してくれる機能を利用するため、下記のディレクトリを作成する。

```
$ mkdir docker/mysql/docker-entrypoint-initdb.d
$ echo -n "create database employees default character set utf8;" > docker/mysql/docker-entrypoint-initdb.d/create_db_s.sql
```

後述の `docker-compose.yaml` にて、当該ディレクトリをコンテナにマウントさせれば、初回起動時にSQLを実行してくれるとのこと。

[参考 - hub.docker.com/_/mysql/](https://hub.docker.com/_/mysql/)

#### MySQLの設定ファイルを作成

`docker-compose up` する時に、コンテナ内にマウントさせる設定ファイル

```
$ mkdir docker/mysql/conf.d
$ touch docker/mysql/conf.d/custom.cnf
```

中身はちょっと適当すぎるのだけど、こんな感じに。

```
[mysqld]
character-set-server=utf8

bind-address  = 0.0.0.0
```

#### MySQL用のディレクトリ構成

ディレクトリ構成はこんな感じ

```
docker/mysql/
├── Dockerfile
├── conf.d
│   └── custom.cnf
└── docker-entrypoint-initdb.d
    └── create_db.sql
```

#### Minio用のディレクトリの作成

minioとは、簡単に言うと「ローカル環境でAmazon S3を立ち上げられる」様なもの。

[minio.io/](https://www.minio.io/)

#### Minio用のディレクトリ作成

```
$ mkdir docker/s3
```

#### Minio用のDockerfile作成

docker公式のMySQL Imageを利用するためのもの

```
$ echo -n "FROM minio/minio:latest" > docker/s3/Dockerfile
```

#### Minio用のディレクトリ構成

ディレクトリ構成はこんな感じ

```
docker/s3/
└── Dockerfile
```

この後のdocker-composeでいろいろやるにはやるのだけど、これだけでS3環境相当のものが作れるのはすごい。

#### docker-composeファイルを作成

全てのDockerfileを従える絡新婦の様なファイル。

```
$ touch docker/docker-compose.yaml
```

中身はこんな感じ。

```docker/docker-compose.yaml
version: '2'
services:
  # MySQLのコンテナを作成するための設定
  employees_db:
    container_name: employees_db
    image: employees_db
    build: ./mysql
    ports:
      - "3306:3306"
    # コンテナ内の環境変数を指定
    environment:
      MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
    # 指定のディレクトリ・ファイルを、コンテナにマウントする
    volumes:
      - "./mysql/docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d"
      - "./mysql/conf.d/:/etc/mysql/conf.d/"
      - db-data:/var/lib/mysql
  # Railsアプリのコンテナを作成するための設定
  employees_app:
    container_name: employees_app
    image: employees_app
    # コンテナ作成に利用するファイル群を指定する（この場合、Dockerfileが存在するディレクトリを指定）
    build: ..
    # stdin_open: true = コンテナの標準入力をオープンしたままにする
    stdin_open: true
    # tty:true = コンテナに疑似TTYを割り当てる
    tty: true
    # コンテナ立ち上げ時に実行するコマンドを指定
    command: bin/rails s -p 3000 -b '0.0.0.0'
    volumes:
      # employees/DcokerfileのRUNコマンドで作成しているディレクトリにマウント
      - ..:/employees
      - bundle:/bundle
    # ポート指定
    ports:
      - "3000:3000"
    environment:
      - "S3_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE"
      - "S3_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
      - "S3_REGION=ap-northeast-1"
      - "S3_HOST=employees_s3"
      - "S3_BUCKET=employees"
      - "S3_ENDPOINT=http://employees_s3:9000"
      - "S3_ASSET_HOST=http://localhost:9000/employees"
    # コンテナ間の依存指定（この場合、employees_dbが立ち上がるまで（ビルドされるまで？）
    # employees_appのコンテナ立ち上げ（ビルド？）は実行されない
    depends_on:
      - employees_db
  employees_s3:
    container_name: employees_s3
    image: employees_s3
    build: ./s3
    stdin_open: true
    tty: true
    command: server /export
    ports:
      - "9000:9000"
    volumes:
      - "./s3:/export"
    environment:
      - "MINIO_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE"
      - "MINIO_SECRET_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

# MySQLのデータや、gemなど、ボリュームとして別管理することが出来る
# コンテナ側でマウントするように設定することで、たとえdocker imageを削除したとしてもデータを引き継ぐ事ができる
volumes:
  db-data:
    driver: local
  bundle:
    driver: local
```

コメント文はもしかしたら僕の認識が間違っているかも知れないので、あしからず。（もし間違っていたら教えて貰いたいッス）

## Dockerコンテナ版アプリケーション起動

#### `docker-compose up`

dockerディレクトリにて、 `docker-compose up` をすると、各種コンテナが立ち上がる。

ガーッとログが出るので、落ち着いたら

```
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                             PORTS                    NAMES
f4e275287cb5        employees_app       "bin/rails s -p 30..."   16 seconds ago      Up 14 seconds                      0.0.0.0:3000->3000/tcp   employees_app
f79473377160        employees_s3        "/usr/bin/docker-e..."   17 seconds ago      Up 15 seconds (health: starting)   0.0.0.0:9000->9000/tcp   employees_s3
bade6d6cf45e        employees_db        "docker-entrypoint..."   17 seconds ago      Up 15 seconds                      0.0.0.0:3306->3306/tcp   employees_db
```

といった感じで確認。

#### マイグレーション

railsのコマンドなどは、 `docker exec` を利用して実行する。

```
$ docker exec employees_app rails db:migrate
== 20170820223339 CreateEmployees: migrating ==================================
-- create_table(:employees)
   -> 0.0443s
== 20170820223339 CreateEmployees: migrated (0.0444s) =========================
```

改めて、[localhost:3000](http://localhost:3000/employees)にアクセスし、employeesテーブルにデータが保存出来る様にフォームが動けばOK。
















## minio(s3)にファイルをアップロードする機能の実装

基本的にS3へのアップロード実装方法を検索すれば、いくらでもでてくる。

minioにおいても同様。

[こちら](http://qiita.com/junara/items/1899f23c091bcee3b058)や[コチラ](http://morizyun.github.io/ruby/rails-function-form-carrierwave-fog-s3.html)を参考にさせていただいた。

#### gemの追加

3つほどgemを利用するので、Gemfileに追記

```
gem 'carrierwave'  # 画像アップロード用
gem 'fog-aws'      # AWS S3連携用
gem 'rmagick'      # 画像処理用
```

同じく `bundle install` を実行

```
$ docker exec employees_app bundle install
```

#### アップローダーの作成

```
$ docker exec employees_app rails g uploader Avatar
```

作成された `uploaders/avatar_uploader.rb` は、少し編集

```
class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  storage :fog

  def store_dir
    "#{mounted_as}/#{model.id}"
  end

  version :thumb do
    process resize_to_fit: [50, 50]
  end

  def extension_whitelist
    %w(jpg jpeg gif png)
  end

  def filename
    "avatar.jpg" if original_filename
  end
end

```

#### carrierwaveの設定ファイルを作成

下記の様に作成する

`config/initializers/carrerwave.rb`

```
CarrierWave.configure do |config|
  config.fog_provider = 'fog/aws'
  config.fog_credentials = {
    provider: 'AWS',
    # AWSアクセスキー
    aws_access_key_id: ENV['S3_ACCESS_KEY'],
    # AWSシークレットキー(間違ってもpublic repositoryにcommitしてはいけない)
    aws_secret_access_key: ENV['S3_SECRET_ACCESS_KEY'],
    # S3リージョン(TOKYO)
    region: ENV['S3_REGION'],
    # S3エンドポイント名(s3-ap-northeast-1.amazonaws.com ※TOKYO)
    host: ENV['S3_HOST'],

    endpoint: ENV['S3_ENDPOINT'],
    path_style: true
  }
  # バケット名
  config.fog_directory = ENV['S3_BUCKET']
  config.asset_host = ENV['S3_ASSET_HOST']
end
```

環境変数は、 `docker-compose.yaml` にて設定済み 

#### カラムを追加

usres Modelに、Avatarというカラムを追加する

```
$ docker exec employees_app rails g migration AddColumnToUsers avatar:string
```

migrateも実行

```
$ docker exec employees_app rails db:migrate
```

#### モデルを修正

`models/user.rb` に下記を追加

```
mount_uploader :avatar, AvatarUploader
```

#### UsersControllerを修正

avatarのパラメーターを受け取れるように、 `controllers/users_consroller.rb` を修正する

```
def user_params
-  params.require(:user).permit(:name, :age)
+  params.require(:user).permit(:name, :age, :avatar)
end
```

#### users/indexを修正する

アップロードした画像の表示をするために、下記の通り追加

`views/users/index.html.erb`

```
<p>
  <%= image_tag @user.avatar.thumb %>
  <%= image_tag @user.avatar %>
</p>
```

#### users_formを修正する

同じく、画像アップロードを受けつけられるように、下記の通りフォームを追加する

`views/users/_form.html.erb`

```
<div class="field">
  <%= form.label :avatar %>
  <%= form.file_field :avatar, id: :user_avatar %>
</div>
```

あとは普通に編集画面で画像を選択して保存すると、minioにアップロードされる。

minioの確認は [localhost:9000/minio/](http://localhost:9000/minio/)にて可能。

`employees/` バケットが作成されているようにしているが、実態は `docker/s3/employees` ディレクトリを作ってあるから。



S3に対して画像アップロードを行う場合、環境変数を変更するだけで良い（プログラムの修正は不要）。
