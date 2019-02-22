app.collections.Transcripts = Backbone.Collection.extend({

  initialize: function(params) {
    var defaults = {
      endpoint: '/transcripts.json'
    };
    this.options = _.extend({}, defaults, params);

    this.params = {page: 1};
    if (this.options.params) this.params = _.extend({}, this.params, this.options.params);
  },

  getPage: function(){
    return this.params.page;
  },

  getParam: function(name){
    return this.params[name];
  },

  getParams: function(){
    return this.params;
  },

  hasAllPages: function(){
    return !this.hasMorePages();
  },

  hasMorePages: function(){
    return (this.params.page * this.per_page < this.total);
  },

  nextPage: function(){
    this.params.page += 1;
  },

  parse: function(resp){
    this.params.page = resp.current_page;
    this.per_page = resp.per_page;
    this.total = resp.total_entries;

    var entries = [];
    _.each(resp.entries, function(t, i){
      t.completeness = t.percent_completed + t.percent_edited * 0.01;
      entries.push(t);
    });

    return entries;
  },

  setParams: function(params){
    var _this = this;

    _.each(params, function(value, key){
      if (value=="ALL" || !value.length) {
        _this.params = _.omit(_this.params, key);
      } else {
        _this.params[key] = value;
      }
    });
  },

  url: function() {
    var params = '?' + $.param(this.params);
    return API_URL + this.options.endpoint + params;
  }

});
