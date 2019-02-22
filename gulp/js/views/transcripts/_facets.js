app.views.TranscriptFacets = app.views.Base.extend({

  template: _.template(TEMPLATES['transcript_facets.ejs']),

  events: {
    "click .filter-by": "filterFromEl",
    "click .sort-by": "sortFromEl",
    "submit .search-form": "searchFromForm",
    "keyup .search-form input": "searchFromInput"
  },

  initialize: function(data){
    this.data = _.extend({
      disableSearch: false,
      disableSort: false
    }, data);

    this.initFacets();

    // turn sticky on
    $(window).trigger('sticky-on', ['#header']);
  },

  filter: function(name, value, query){
    PubSub.publish('transcripts.filter', {name: name, value: value, q: query});
  },

  filterFromEl: function(e){
    var $el = $(e.currentTarget);
    var query = this.getQuery();
    // send query through msg because listener doesnt have this.searchKeyword
    this.filter($el.attr('data-filter'), $el.attr('data-value'), query);
  },

  getQuery: function(){
    return $('#search-form input#search-input').val();
  },

  initFacets: function(){
    // set defaults
    var active_collection_id = 'ALL';
    var active_sort = 'title';
    var active_order = 'asc';
    var active_keyword = '';

    // check for query params
    if (this.data.queryParams) {
      var params = this.data.queryParams;
      if (params.sort_by) active_sort = params.sort_by;
      if (params.order) active_order = params.order;
      if (params.collection_id) active_collection_id = params.collection_id;
      if (params.q) active_keyword = params.q;
    }

    // add an "all collections" options
    if (this.data.collections.length) {
      var all_collections = {
        id: 'ALL',
        title: 'All Collections'
      };
      this.data.collections.unshift(all_collections);
      this.data.collections = _.map(this.data.collections, function(c){
        c.active = false;
        if (c.id == active_collection_id) c.active = true;
        return c;
      });
      this.data.active_collection = _.findWhere(this.data.collections, {active: true});
    }

    // set sort option
    this.data.sort_options = [
      {id: 'title_asc', name: 'title', order: 'asc', label: 'Title (A to Z)'},
      {id: 'title_desc', name: 'title', order: 'desc', label: 'Title (Z to A)'},
      {id: 'completeness_desc', name: 'completeness', order: 'desc', label: 'Completeness (most to least)'},
      {id: 'completeness_asc', name: 'completeness', order: 'asc', label: 'Completeness (least to most)'},
      {id: 'duration_asc', name: 'duration', order: 'asc', label: 'Duration (short to long)'},
      {id: 'duration_desc', name: 'duration', order: 'desc', label: 'Duration (long to short)'},
      {id: 'collection_asc', name: 'collection_id', order: 'asc', label: 'Collection'}
    ];
    this.data.sort_options = _.map(this.data.sort_options, function(option){
      option.active = false;
      if (option.name == active_sort && option.order == active_order) option.active = true;
      return option;
    });
    this.data.active_sort = _.findWhere(this.data.sort_options, {active: true});

    // set keyword
    this.data.active_keyword = active_keyword;
  },

  render: function(){
    this.$el.html(this.template(this.data));
    return this;
  },

  search: function(keyword){
    PubSub.publish('transcripts.search', keyword);
  },

  searchFromForm: function(e){
    e.preventDefault();
    var $form = $(e.currentTarget),
        keyword = $form.find('input[name="keyword"]').val();

    keyword = keyword.trim().toLowerCase();
    this.search(keyword);
  },

  // refresh search if empty (nice function name!)
  searchFromInput: function(e){
    var $input = $(e.currentTarget),
        keyword = $input.val();

    keyword = keyword.trim();

    // only submit if empty
    if (!keyword.length)
      this.search(keyword);
  },

  sortTranscripts: function(name, order, query){
    PubSub.publish('transcripts.sort', {name: name, order: order, q: query});
  },

  sortFromEl: function(e){
    var $el = $(e.currentTarget);
    var query = this.getQuery();
    // send query through msg because listener doesnt have this.searchKeyword
    this.sortTranscripts($el.attr('data-sort'), $el.attr('data-order'), query);
  }
});
