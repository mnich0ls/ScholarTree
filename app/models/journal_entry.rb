class JournalEntry < ActiveRecord::Base
  belongs_to :journal

  attr_accessible :journal_id, :entry, :description, :latitude, :longitude

  def snippet
    snippet = self.entry[0..200].strip
    if snippet.length < self.entry.length
      snippet += '...'
    end
    return snippet
  end
end
