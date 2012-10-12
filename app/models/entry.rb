class Entry < ActiveRecord::Base
  attr_accessible :is_completed, :title, :order

  validates :title, :presence => true
end
