class Project < ApplicationRecord
  audited
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :description

  audited associated_with: :owners
  belongs_to :user
  has_many :widgets, :dependent => :destroy
  has_associated_audits
  has_and_belongs_to_many :owners, class_name: 'User'
  has_one :forum

  has_many :favoriter_projects
  has_many :fans, through: :favoriter_projects, :source => :user
  has_many :comments, through: :widgets
  mount_uploader :avatar, AvatarUploader
  validates :avatar, file_size: { less_than: 3.megabytes }
  scope :order_by_fans_count, -> {
  joins(:fans).select('projects.*, COUNT(user_id) as user_count').group('projects.id').order('user_count DESC')
  }
  serialize :tags

  def get_open_hub_data
    ohp = OpenHubProject.find_by_name(self.name)
    self.description = ohp.description
    self.open_hub_image_url = ohp.logo_url
    self.use_open_hub_data = true
    self.use_open_hub_image = true
    self.tags = ohp.tags
  end
  def photo_url
    if use_open_hub_image
      open_hub_image_url  || "/assets/no-image.png"
    elsif !avatar.url.nil?
      avatar.url
    else
      "/assets/no-image.png"
    end
  end

  def photo_url_uploaded
      avatar.url
  end

  def owner?(user)
    self.owners.include?(user)
  end

  def self.search(search)
    if search
      where("name LIKE ? OR description LIKE ? OR tags LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%")
    else
      all
    end
  end
end
