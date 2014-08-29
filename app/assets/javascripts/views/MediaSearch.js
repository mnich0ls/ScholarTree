var MediaSearch = Backbone.View.extend({
    el : '#media-search-container',
    model : null,
    class : 'div',
    events: {'submit .search-query': 'performSearch'},
    initialize : function() {
        this.model = new MediaItems;
        this.template = _.template($('#media-search-template').html());
        this.resultsTemplate = _.template($('#media-search-results-template').html());
        _.bindAll(this, 'performSearch', 'renderResults');
        // why doesn't this fire when the collection is first fetched?
        this.listenTo(this.model, 'change reset', this.renderResults);
    },
    render : function() {
        this.$el.append(this.template());
        return this;
    },
    renderResults : function() {
        this.model.each(function(mediaItem){
            if (mediaItem.get('type') == undefined || mediaItem.get('type') == null) {
                mediaItem.set('typeClass', '');
            } else if (mediaItem.get('type') == 'ebook') {
                mediaItem.set('typeClass', 'glyphicon glyphicon-book');
            } else if (mediaItem.get('type') == 'audiobook') {
                mediaItem.set('typeClass', 'glyphicon glyphicon-headphones');
            } else if (mediaItem.get('type') == 'track') {
                mediaItem.set('typeClass', 'glyphicon glyphicon-music');
            } else if (mediaItem.get('type') == 'movie') {
                mediaItem.set('typeClass', 'glyphicon glyphicon-book');
            } else {
                mediaItem.set('typeClass', '');
            }
        });
        this.$('.results').html(this.resultsTemplate({mediaItems: this.model.toJSON()}));
    },
    performSearch: function(event) {
        event.preventDefault();
        var target = $(event.target);
        var searchQuery = target.find('.search-query').val();
        var type        = target.find('input:checked').val();
        this.model.fetch({
            data: {
                query   : searchQuery,
                type    : type
            },
            success: this.renderResults
        });
    }
});