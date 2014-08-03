var JournalEntries = Backbone.Collection.extend({
    currentPage: 1,
    currentIndex: 0,
    url: "/photo_journal/entries",
    reachedMaxEntries: false,
    entriesReady: function() {
        return (this.currentIndex <= this.length - 1) || this.reachedMaxEntries;
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
        return (this.currentIndex <= this.length - 1) || this.reachedMaxPhotos;
    },
    currentPhoto: function(){
        return this.at(this.currentIndex);
    }
});

var PhotoView = Backbone.View.extend({
    tagName: 'div',
    className: 'photo-container span2',
    initialize: function(){
        this.template = _.template($('#photo-template').html());
    },
    render: function() {
        this.$el.html(this.template(this.model.toJSON()));
    }
});

var JournalEntryView = Backbone.View.extend({
    tagName: 'div',
    className: 'entry-container span2',
    initialize: function(){
        this.template = _.template($('#entry-template').html());
    },
    render: function(){
        this.$el.html(this.template(this.model.toJSON()));
    }
});

var JournalContainerDataSource = Backbone.Model.extend({
    entries: null,
    photos: null,
    initialize: function(){
        this.entries = new JournalEntries();
        this.photos = new Photos();
    }
});

var JournalContainer = Backbone.View.extend({
    el: '#journal-container',
    class: 'row',
    entriesPerRow: 3,
    scrollPollId: null,
    initialFetch: true,
    initialize: function() {
        console.log("journal container: initializing");
        this.model = new JournalContainerDataSource();
        this.rowTempalte = _.template($('#entry-row-template').html());
        // insert empty row
        //this.$el.append(this.rowTempalte({}));

        console.log("journal container: initialized");
        _.bindAll(this, '_entriesFetched', '_photosFetched');
    },
    render: function() {
        this.fetchPage();
    },
    fetchPage: function(){
        if (this.model.entries.currentIndex >= this.model.entries.length) {
            console.log("fetching more entries");
            this.model.entries.currentIndex = 0;
            this.model.entries.fetch({
                data: {page: this.model.entries.currentPage},
                success: this._entriesFetched
            });
            this.model.entries.currentPage++;
        }

        if (this.model.photos.currentIndex >= this.model.photos.length) {
            console.log("fetching more photos");
            this.model.photos.currentIndex = 0;
            this.model.photos.fetch({
                data: {page: this.model.photos.currentPage},
                success: this._photosFetched
            });
            this.model.photos.currentPage++;
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
        console.log("photos: " + this.model.photos.length);
        if (this.model.photos.length == 0) {
            this.model.photos.reachedMaxPhotos = true;
        }
        this._newPageFetchSuccess();
    },
    _entriesFetched: function(){
        console.log("entries: " + this.model.entries.length);
        if (this.model.entries.length == 0) {
            this.model.entries.reachedMaxEntries = true;
        }
        this._newPageFetchSuccess();
    },
    _newPageFetchSuccess: function(){
        while (this.model.entries.entriesReady() &&
            this.model.photos.photosReady()) {
            if (this.model.entries.reachedMaxEntries && this.model.photos.reachedMaxPhotos) {
                clearInterval(this.scrollPollId);
                break;
            }
            var currentEntry = this.model.entries.currentEntry();
            var currentPhoto = this.model.photos.currentPhoto();
            if (currentEntry == undefined) {
                this._appendPhoto(currentPhoto);
            } else if (currentPhoto == undefined) {
                this._appendEntry(currentEntry)
            } else if (currentEntry.get('date') < currentPhoto.get('date')) {
                this._appendEntry(currentEntry);
            } else {
                this._appendPhoto(currentPhoto);
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
        this._getCurrentRow().append(entryView.el);

        // advance the current JournalEntriesCollection index
        this.model.entries.currentIndex++;
    },
    _appendPhoto: function(photo){
        var photoView = new PhotoView({model: photo});
        photoView.render();
        this._getCurrentRow().append(photoView.el);

        // advance the current index
        this.model.photos.currentIndex++;
    },
    _getCurrentRow: function(){
        // get the last row
//        var $row = this.$('.entry-row').last();
//        if ($row.children().length == this.entriesPerRow) {
//            // if the row is full, create new row
//            $row = $(this.rowTempalte({}));
//            this.$el.append($row);
//        }
//        return $row;
        return this.$el
    }
});