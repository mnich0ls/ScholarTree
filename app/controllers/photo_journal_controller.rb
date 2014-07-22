class PhotoJournalController < AuthenticatedController
  def show
    entries = JournalEntry.paginate(:page => params[:page], :per_page => 6)
    @entries = []
    entries.each do |entry|
      snippet = entry.entry[0..200]
      if snippet.length < entry.entry.length
        snippet += '...'
      end
      @entries.push(
        "title" => entry.description,
        "snippet" => snippet
      )
    end
  end
end
