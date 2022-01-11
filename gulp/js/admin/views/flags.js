app.views.AdminFlags = app.views.Base.extend({

  template: _.template(TEMPLATES['admin_flags.ejs']),

  className: 'flags',

  initialize: function(data){
    this.data = _.extend({}, data);

    this.render();
    this.loadData();
  },

  loadData: function(){
    var _this = this;
    $.getJSON("/admin/flags.json", function(data) {
      _this.renderFlags(data.flags);
    });
  },

  render: function() {
    this.$el.html(this.template(this.data));

    return this;
  },

  renderFlags: function(flags){
    var $flags = this.$('#flags-container');

    $flags.empty();

    _.each(flags, function(flag){
      var flagView = new app.views.FlagItem({flag: flag});
      $flags.append(flagView.$el);
    });
  }

});
