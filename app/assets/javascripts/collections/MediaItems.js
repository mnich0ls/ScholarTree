var MediaItems = Backbone.Collection.extend({
    url : "/media/query",
    model : MediaItem
});