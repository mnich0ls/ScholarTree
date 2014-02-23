class JournalEntriesController < JournalController
  def index
    @user = current_user
  end

  def new
    @journal_entry = JournalEntry.new
  end

  def create
    @journal_entry = JournalEntry.new(params.require(:journal_entry).permit(:description, :entry))
    @journal_entry.save
    redirect_to journal_entries_path
  end
end