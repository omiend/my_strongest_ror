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
