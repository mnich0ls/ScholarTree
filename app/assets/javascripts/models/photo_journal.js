var JournalEntry = Backbone.Model.extend({
    urlBase: "/journal_entries",
    url: function(){
        return this.urlBase + "/" + this.id + "/json";
    }
});

var JournalEntryView = Backbone.View.extend({
    tagName: 'div',
    className: 'entry-container col-xs-12 col-sm-3 col-md-2 has-modal-view',
    events: {
        'click': "_handleClick"
    },
    initialize: function(){
        this.template = _.template($('#entry-template').html());
        _.bindAll(this, '_entryFetchSuccess');
    },
    _handleClick: function(){
        var entry = new JournalEntry({id: this.model.get('id')});
        entry.fetch({
            success: this._entryFetchSuccess
        });
    },
    _entryFetchSuccess: function(entry){
        $('#journal-item-modal .modal-header .modal-title').text(entry.get('title'));
        $('#journal-item-modal .modal-body .modal-body-text').text(entry.get('entry'));
        $('#journal-item-modal').modal('toggle');
    },
    render: function(){
        this.$el.html(this.template(this.model.toJSON()));
    }
});

var JournalEntries = Backbone.Collection.extend({
    currentPage: 1,
    currentIndex: 0,
    url: "/photo_journal/entries",
    reachedMaxEntries: false,
    entriesReady: function() {
        return (this.currentIndex < this.length) || this.reachedMaxEntries;
    },
    currentEntry: function() {
        return this.at(this.currentIndex);
    }
});

var Photos = Backbone.Collection.extend({
    currentPage: 1,
    currentIndex: 0,
    url: "/photo_journal/photos",
    reachedMaxPhotos: false,
    photosReady: function() {
        return (this.currentIndex < this.length) || this.reachedMaxPhotos;
    },
    currentPhoto: function(){
        return this.at(this.currentIndex);
    }
});

var PhotoView = Backbone.View.extend({
    tagName: 'div',
    className: 'photo-container col-xs-3 col-md-2 has-modal-view',
    events: {
        'click': "_handleClick"
    },
    initialize: function(){
        this.template = _.template($('#photo-template').html());
    },
    _handleClick: function(){
        var $img = $('<img>');
        $img.attr('src', this.model.get('modalUrl'));
        $img.attr('width', this.model.get('modalWidth'));
        $img.attr('height', this.model.get('modalHeight'));
        $('#journal-item-modal .modal-header .modal-title').text(this.model.get('dateString'));
        $('#journal-item-modal .modal-body .modal-body-text').html($img);
        $('#journal-item-modal').modal('toggle');
    },
    render: function() {
        this.$el.html(this.template(this.model.toJSON()));
    }
});

var Books = Backbone.Collection.extend({
    currentPage: 1,
    currentIndex: 0,
    url: "/photo_journal/books",
    reachedMaxBooks: false,
    booksReady: function() {
        return (this.currentIndex < this.length) || this.reachedMaxBooks;
    },

    currentBook: function() {
        return this.at(this.currentIndex);
    }
});

var BookView = Backbone.View.extend({
    tagName: 'div',
    className: 'book-container col-xs-3 col-md-2 has-modal-view',
    events: {
        'click': '_handleClick'
    },
    initialize: function() {
        this.template = _.template($('#book-template').html());
    },
    _handleClick: function(){
        var $img = $('<img>');
        $img.attr('src', this.model.get('modalUrl'));
        $img.attr('width', this.model.get('modalWidth'));
        $img.attr('height', this.model.get('modalHeight'));
        $('#journal-item-modal .modal-header .modal-title').text(this.model.get('dateString'));
        $('#journal-item-modal .modal-body .modal-body-text').html($img);
        $('#journal-item-modal').modal('toggle');
    },
    render: function() {
        this.$el.html(this.template(this.model.toJSON()));
    }
});

var JournalContainerDataSource = Backbone.Model.extend({
    entries: null,
    photos: null,
    books: null,
    initialize: function() {
        this.entries    = new JournalEntries();
        this.photos     = new Photos();
        this.books      = new Books();
    },
    reset: function() {
        this.entries    = new JournalEntries();
        this.photos     = new Photos();
        this.books      = new Books();
    },
    getNext: function() {
        var all = [];
        if (this.entries.currentEntry() != undefined ) {
            all.push(this.entries.currentEntry());
        }
        if (this.photos.currentPhoto() != undefined) {
            all.push(this.photos.currentPhoto());
        }
        if (this.books.currentBook() != undefined) {
            all.push(this.books.currentBook());
        }

        all.sort(function(a, b) {
            return a.get('date') - b.get('date');
        });

        var next = all[0];

        switch (next.get('type')) {
            case 'book':
                this.books.currentIndex++;
                break;
            case 'photo':
                this.photos.currentIndex++;
                break;
            case 'entry':
                this.entries.currentIndex++;
                break;
        }

        return next;
    }
});

var JournalContainer = Backbone.View.extend({
    el: '#journal-container',
    class: 'row',
    scrollPollId: null,
    initialFetch: true,
    searchQuery: null,
    initialize: function() {
        console.log("journal container: initializing");
        this.model = new JournalContainerDataSource();
        _.bindAll(this, '_entriesFetched', '_photosFetched', '_booksFetched',
            '_destroyed', '_search');
        // listen to page change fired by turbo links
        // this is our chance to free up memory and remove event listeners
        $(document).on("page:change", this._destroyed);
        window.applicationDelegate.registerEventHandler('context-search', this._search, 'Photo Journal');
        window.applicationDelegate.trigger('context-switch', { context: "Photo Journal" });
        console.log("journal container: initialized");
    },
    render: function() {
        this.fetchPage();
    },
    fetchPage: function(){
        var params = {};

        if (this.model.entries.currentIndex >= this.model.entries.length && !this.model.entries.reachedMaxEntries) {
            console.log("fetching more entries. page: " + this.model.entries.currentPage);
            this.model.entries.currentIndex = 0;
            params = {};
            params['page'] = this.model.entries.currentPage;
            if (this.searchQuery != null) {
                params['search-query'] = this.searchQuery;
            }
            this.model.entries.fetch({
                data: params,
                success: this._entriesFetched
            });
            this.model.entries.currentPage++;
        }

        if (this.model.photos.currentIndex >= this.model.photos.length && !this.model.photos.reachedMaxPhotos) {
            console.log("fetching more photos. page: " + this.model.photos.currentPage);
            this.model.photos.currentIndex = 0;
            params = {};
            params['page']      = this.model.photos.currentPage;
            params['size']      = 'medium';
            params['modal_size'] = 'large';
            if (this.searchQuery != null) {
                params['search-query'] = this.searchQuery;
            }
            this.model.photos.fetch({
                data: params,
                success: this._photosFetched
            });
            this.model.photos.currentPage++;
        }

        if (this.model.books.currentIndex >= this.model.books.length && !this.model.books.reachedMaxBooks) {
            console.log("fetching more books. page: " + this.model.books.currentPage);
            this.model.books.currentIndex = 0;
            params = {};
            params['page'] = this.model.books.currentPage;
            params['size']      = 'medium';
            params['modal_size'] = 'large';
            if (this.searchQuery != null) {
                params['search-query'] = this.searchQuery;
            }
            this.model.books.fetch({
                data:       params,
                success:    this._booksFetched
            });
            this.model.books.currentPage++;
        }
    },
    _checkScroll: function(self){
        if (self._nearBottomOfPage()){
            console.log('preparing to load more content');
            self.fetchPage();
        }
    },
    _nearBottomOfPage: function(){
        return this._scrollDistanceFromBottom() < 50;
    },
    _scrollDistanceFromBottom: function(){
        return this._pageHeight() - (window.pageYOffset + self.innerHeight);
    },
    _pageHeight: function(){
        return Math.max(document.body.scrollHeight, document.body.offsetHeight);
    },
    _photosFetched: function(){
        if (this.model.photos.length == 0) {
            this.model.photos.reachedMaxPhotos = true;
        }
        this._newPageFetchSuccess();
    },
    _entriesFetched: function(){
        if (this.model.entries.length == 0) {
            this.model.entries.reachedMaxEntries = true;
        }
        this._newPageFetchSuccess();
    },
    _booksFetched: function() {
        console.log("Books fetched: " + this.model.books.length);
        if (this.model.books.length == 0) {
            this.model.books.reachedMaxBooks = true;
        }
        this._newPageFetchSuccess();
    },
    _newPageFetchSuccess: function(){
        while (this.model.entries.entriesReady() &&
            this.model.photos.photosReady() &&
            this.model.books.booksReady()) {
            if (this.model.entries.reachedMaxEntries &&
                this.model.photos.reachedMaxPhotos &&
                this.model.books.reachedMaxBooks) {
                clearInterval(this.scrollPollId);
                break;
            }

            var next = this.model.getNext();

            if (next.get('type') == 'entry') {
                this._appendEntry(next);
            } else if (next.get('type') == 'photo') {
                this._appendPhoto(next);
            } else if (next.get('type') == 'book') {
                this._appendBook(next)
            } else {
                console.log("Unknown type: " + next.get('type'));
                break;
            }

            if (this.initialFetch) {
                // setup scroll poll interval
                var self = this;
                this.scrollPollId = setInterval(this._checkScroll, 300, self);
                this.initialFetch = false;
            }
        }
    },
    _appendEntry: function(entry) {
        var entryView = new JournalEntryView({model: entry});
        entryView.render();
        this.$el.append(entryView.el);

        // advance the current JournalEntriesCollection index
        this.model.entries.currentIndex++;
    },
    _appendPhoto: function(photo){
        var photoView = new PhotoView({model: photo});
        photoView.render();
        this.$el.append(photoView.el);

        // advance the current index
        this.model.photos.currentIndex++;
    },
    _appendBook: function(book) {
        var bookView = new BookView({model: book});
        bookView.render();
        this.$el.append(bookView.el);
    },
    _search: function(data){
        var searchQuery = data.searchQuery;
        console.log("Photo Journal searching with query: " + searchQuery);
        this.searchQuery = searchQuery;
        this._reset();
    },
    _reset: function(){
        this.model.reset();
        clearInterval(this.scrollPollId);
        this.initialFetch = true;
        this.$el.html('');
        this.render();
    },
    _destroyed: function() {
        if (this.scrollPollId != undefined) {
            clearInterval(this.scrollPollId);
            console.log("Photo Journal removed scroll poll interval");
            window.applicationDelegate.removeEventHandler('context-search', this._search, 'Photo Journal');
            $(document).off("page:change", this._destroyed);
        }
    }
});