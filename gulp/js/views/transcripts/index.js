app.views.TranscriptsIndex = app.views.Base.extend({

  template: _.template(TEMPLATES['transcript_index.ejs']),
  template_list: _.template(TEMPLATES['transcript_list.ejs']),
  template_item: _.template(TEMPLATES['transcript_item.ejs']),

  className: 'transcripts-wrapper',

  events: {
    'click .list-next': 'nextPage'
  },

  initialize: function(data){
    var defaults = {
      queryParams: {}
    };
    this.data = _.extend({}, defaults, data);

    this.render();

    this.$transcripts = this.$('#transcript-results');
    this.$facets = this.$('#transcript-facets');

    // init collection so we can search and facet
    this.transcripts = this.transcripts || new app.collections.Transcripts({
      endpoint: '/search.json',
      params: this.data.queryParams
    });

    if (this.data.queryParams) this.loadParams(this.data.queryParams);
    this.loadTranscripts();
    this.loadCollections();
    this.loadListeners();
  },

  facet: function(){
    var keyword = this.searchKeyword || "";
    PubSub.publish('transcripts.search', keyword);
    return true;
  },

  searchServer: function(keyword) {
    var sort_name = this.sortName || 'title'
    var sort_order = this.sortOrder || 'asc'
    var combined_params = _.extend(this.filters, {'q': keyword, sort_by: sort_name, order: sort_order});
    this.setParams(combined_params);
  },

  setParams: function(params){
    this.$transcripts.empty().addClass('loading');
    params.page = 1;
    this.transcripts.setParams(params);
    this.updateUrlParams();
    this.loadTranscripts();
  },

  filterBy: function(name, value){
    this.filters = this.filters || {};
    this.filters[name] = value;
    this.updateUrlParams();
    this.facet();
  },

  isFaceted: function(){
    return this.filters || this.sortName || this.sortOrder || this.searchKeyword;
  },

  loadCollections: function(){
    var _this = this;

    this.collections = this.collections || this.data.collections;

    this.collections.fetch({
      success: function(collection, response, options){
        _this.renderFacets(collection.toJSON());
      },
      error: function(collection, response, options){
        _this.renderFacets([]);
      }
    });
  },

  setQuery: function(query){
    this.searchKeyword = query;
  },

  loadListeners: function(){
    var _this = this;

    PubSub.subscribe('transcripts.filter', function(ev, filter) {
      _this.setQuery(filter.q);
      _this.filterBy(filter.name, filter.value, filter.q);
    });

    PubSub.subscribe('transcripts.sort', function(ev, sort_option) {
      _this.setQuery(sort_option.q);
      _this.sortBy(sort_option.name, sort_option.order, sort_option.q);
    });

    PubSub.subscribe('transcripts.search', function(ev, keyword) {
      _this.searchServer(keyword);
    });
  },

  loadParams: function(params){
    var _this = this;

    this.filters = this.filters || {};

    _.each(params, function(value, key){
      // sort name
      if (key == 'sort_by') {
        _this.sortName = value;
      }
      // sort order
      else if (key == 'order') {
        _this.sortOrder = value;
      }
      // keyword
      else if (key == 'keyword') {
        _this.searchKeyword = value;
      }
      // otherwise, assume it's a filter
      else {
        _this.filters[key] = value;
      }
    });

    // console.log(this.filters, this.sortName, this.sortOrder, this.searchKeyword)
  },

  // from search.js
  loadTranscripts: function(){
    var _this = this;
    var params = this.data.queryParams;

    this.$transcripts.addClass('loading');
    this.transcripts = this.transcripts || new app.collections.Transcripts({
      endpoint: '/search.json',
      params: params
    });

    this.transcripts.fetch({
      success: function(collection, response, options){
        _this.renderTranscripts(collection);
      },
      error: function(collection, response, options){
        $(window).trigger('alert', ['Whoops! We seem to have trouble loading our transcripts. Please try again by refreshing your browser or come back later!']);
      }
    });
  },

  nextPage: function(e){
    e.preventDefault();
    $(e.currentTarget).remove();
    this.transcripts.nextPage();
    this.loadTranscripts();
  },

  render: function(){
    this.$el.attr('role', 'main');
    this.$el.html(this.template(this.data));
    this.$transcripts = this.$('#transcript-results');
    this.$facets = this.$('#transcript-facets');
    return this;
  },

  renderFacets: function(collections){
    this.facetsView = this.facetsView || new app.views.TranscriptFacets({collections: collections, queryParams: this.data.queryParams});
    this.$facets.html(this.facetsView.render().$el);
  },

  // from search.js
  renderTranscripts: function(transcripts){
    var _this = this;

    var transcriptsData = transcripts.toJSON();

    var list = this.template_list({has_more: transcripts.hasMorePages()});
    var $list = $(list);
    var $target = $list.first();
    var query = transcripts.getParam('q') || '';

    if (transcripts.getPage() > 1) {
      this.$transcripts.append($list);

    } else {
      this.$transcripts.empty();
      if (transcriptsData.length){
        this.$transcripts.html($list);
      } else {
        this.$transcripts.html('<p>No transcripts found!</p>');
      }
    }
    this.$transcripts.removeClass('loading');

    _.each(transcripts.models, function(transcript_model){
      var transcript = transcript_model.attributes;

      var transcriptView = new app.views.TranscriptItem({transcript: transcript});
      $target.append(transcriptView.$el);
    });
  },

  sortBy: function(name, order){
    this.sortName = name;
    this.sortOrder = order;
    this.updateUrlParams();
    this.facet();
  },

  updateUrlParams: function(){
    var data = {};
    // check for sorting
    if (this.sortName && this.sortOrder) {
      data.sort_by = this.sortName;
      data.order = this.sortOrder;
    }

    // check for filters
    if (this.filters) {
      _.each(this.filters, function(value, key){
        data[key] = value;
      });
    }
    // update URL if there's facet data
    if (_.keys(data).length > 0 && window.history) {
      var url = '/' + this.data.route.route + '?' + $.param(data);
      window.history.pushState(data, document.title, url);

    } else if (window.history) {
      var url = '/' + this.data.route.route;
      window.history.pushState(data, document.title, url);
    }
  }
});
