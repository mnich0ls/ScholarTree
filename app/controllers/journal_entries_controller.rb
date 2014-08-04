require 'json'
require 'date'

class JournalEntriesController < AuthenticatedController
  def index
    @user = current_user
    @journal = Journal.where('user' => current_user)[0]
    render layout: 'full_screen'
  end

  def new
    @journal_entry = JournalEntry.new
    @journals = Journal.where('user' => current_user)
  end

  def create
    @journal_entry = JournalEntry.new(params.require(:journal_entry).permit(:description, :entry, :journal_id, :latitude, :longitude))
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
    @journal_entry = JournalEntry.find(params[:id])
    if @journal_entry.journal.user != current_user
      raise "error"
    end
    @journal_entry.update(params.require(:journal_entry).permit(:description, :entry, :journal_id))
    redirect_to journal_entry_url(@journal_entry)
  end

  def calendar_events_json

    startDate = DateTime.strptime(params[:start], '%s')
    endDate   = DateTime.strptime(params[:end], '%s')

    entries = JournalEntry.joins(:journal).where('journals.user_id' => current_user)
      .where('journal_entries.created_at >= ? AND journal_entries.created_at <= ?', startDate, endDate)

    events = []
    entries.each do |entry|
      snippet = entry.entry[0..200]
      if snippet.length != entry.entry.length
        snippet += '...'
      end
        events.push(
            {
                "start" => entry.created_at,
                "url"   => journal_entry_url(entry),
                "backgroundColor" => 'green',
                "title" => entry.description.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => '?'}),
                "snippet" => snippet.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => '?'})
            }
        )
    end

    render json: (JSON.generate(events))
  end

  def entry_json
    journal_entry = JournalEntry.find(params[:id])
    if journal_entry.journal.user != current_user
      logger.info("entry not owned by user")
      raise "error"
    end
    @journal_entry = {
        'id'  => journal_entry.id,
        'title' => journal_entry.description,
        'entry' => journal_entry.entry
    }
    render json: (JSON.generate(@journal_entry))
  end
end
