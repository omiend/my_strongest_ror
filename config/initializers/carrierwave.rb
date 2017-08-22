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
  # CloudFrontのDomainName or CNAME(例: http://xxx.cloudfront.net)
  # CDNを使わない場合は、S3バケットの絶対パス(例: https://s3-us-west-2.amazonaws.com/<backet>)
  config.asset_host = ENV['S3_ASSET_HOST']
end
