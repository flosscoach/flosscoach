class Project < ActiveRecord::Base

	belongs_to :languages
	belongs_to :operational_systems
	belongs_to :tools
	belongs_to :users
	has_many	:project_admin


def self.search(search)
  if search
    Project.where('name LIKE ?', "%#{search}%")
  else
    Project.all
  end
end


end
