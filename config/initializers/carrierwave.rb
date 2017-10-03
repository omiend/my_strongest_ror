CarrierWave.configure do |config|
  config.fog_provider = 'fog/aws'
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: ENV['S3_ACCESS_KEY'],
    aws_secret_access_key: ENV['S3_SECRET_ACCESS_KEY'],
    region: ENV['S3_REGION'],
    host: ENV['S3_HOST'],
    endpoint: ENV['S3_ENDPOINT'],
    path_style: true
  }
  config.fog_directory = ENV['S3_BUCKET']
  config.asset_host = ENV['S3_ASSET_HOST']
  config.cache_storage = :fog
  config.cache_dir = "cache"
end
