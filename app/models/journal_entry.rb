class JournalEntry < ActiveRecord::Base
  belongs_to :journal

  attr_accessible :journal_id, :entry, :description, :latitude, :longitude
end
