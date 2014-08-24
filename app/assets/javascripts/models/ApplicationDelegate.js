var ApplicationDelegate = Backbone.Model.extend({
    eventBus: _.clone(Backbone.Events),
    initialize: function() {
        _.bindAll(this, 'appSearch', 'contextSearch');
        this.eventBus.on('context-switch', this.contextSwitch);
        $(document).on('submit', '#application-search-query', this.appSearch);
        $(document).on('submit', '#context-search-query', this.contextSearch);
        console.log("Application context initialized");
        $(document).on("page:change", function(){
            $(".context-navbar").autoHidingNavbar({showOnBottom: false});
        });
        $(document).on("page:before-change", function(){
            $(".context-navbar").autoHidingNavbar('destroy');
        })
    },
    appSearch: function(e) {
        e.preventDefault();
        var searchQuery = $(event.target).find('.search-query').val();
        console.log("Triggering application search event with query: " + searchQuery);
        this.eventBus.trigger('application-search', {
            searchQuery: searchQuery
        });
    },
    contextSearch: function(e) {
        e.preventDefault();
        var searchQuery = $(event.target).find('.search-query').val();
        console.log("Triggering context search event with query: " + searchQuery);
        this.eventBus.trigger('context-search', {
            searchQuery: searchQuery
        });
    },
    registerEventHandler: function(eventName, handler, context) {
        console.log(context + " registered for events: " + eventName);
        this.eventBus.on(eventName, handler);
    },
    removeEventHandler: function(eventName, handler, context) {
        console.log(context + " unregistered for events: " + eventName);
        this.eventBus.off(eventName, handler);
    },
    trigger: function(eventName, data){
        this.eventBus.trigger(eventName, data);
    },
    contextSwitch: function(data) {
        $('.context-navbar-context-title').text(data.context);
    }
});