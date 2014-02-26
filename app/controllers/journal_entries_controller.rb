class JournalEntriesController < JournalController
  def index
    @user = current_user
  end

  def new
    @journal_entry = JournalEntry.new
    @journals = Journal.where('user' => current_user)
  end

  def create
    @journal_entry = JournalEntry.new(params.require(:journal_entry).permit(:description, :entry, :journal_id))
    @journal_entry.save
    redirect_to journal_entry_url(@journal_entry)
  end

  def show
    @journal_entry = JournalEntry.find(params[:id])
    if @journal_entry.journal.user != current_user
      raise "error"
    end
    @next_journal_entry = JournalEntry.joins(:journal).where('journals.user_id' => current_user)
      .where("journal_entries.created_at > ?", @journal_entry.created_at).order(created_at: :asc)[0]
    @previous_journal_entry = JournalEntry.joins(:journal).where('journals.user_id' => current_user)
      .where("journal_entries.created_at < ?", @journal_entry.created_at).order(created_at: :desc)[0]
  end

  def edit
    @journal_entry = JournalEntry.find(params[:id])
    if @journal_entry.journal.user != current_user
      raise "error"
    end
  end

  def update
    if @journal_entry.journal.user != current_user
      raise "error"
    end
    @journal_entry = JournalEntry.find(params[:id])
    @journal_entry.update(params.require(:journal_entry).permit(:description, :entry, :journal_id))
    redirect_to journal_entry_url(@journal_entry)
  end
end