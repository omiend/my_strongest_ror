class Employee < ApplicationRecord
  mount_uploader :avatar, AvatarUploader
end
