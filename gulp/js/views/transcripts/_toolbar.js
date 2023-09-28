app.views.TranscriptToolbar = app.views.Base.extend({

  template: _.template(TEMPLATES['transcript_toolbar.ejs']),

  initialize: function(data){
    this.data = _.extend({}, data);

    this.loadControls();
    this.loadListeners();
    this.loadMenu();

    this.render();
  },

  loadControls: function(){
    var controls = this.data.controls || this.data.project.controls;
    this.data.controls = _.map(controls, _.clone);

    this.data.controls = _.map(this.data.controls, function(control){
      var key = control.key;
      // change brackets to spans
      if (key.indexOf('[') >= 0 && key.indexOf(']') >= 0) {
        control.key = control.key.replace(/\[/g, '<span title="'+control.keyLabel+'">').replace(/\]/g, '</span>');
      } else {
        control.key = '<span title="'+control.keyLabel+'">' + control.key + '</span>';
      }
      return control;
    });

    // add one for playback rate control
    this.data.control_width_percent = 1.0 / (this.data.controls.length + 2) * 100;
  },

  loadListeners: function(){
    var _this = this;

    // listen for player state change
    PubSub.subscribe('player.state.change', function(ev, state) {
      _this.$el.attr('state', state);
    });
  },

  loadMenu: function(){
    var menu = this.data.menu,
        menus = this.data.project.menus;

    this.data.menu = "";

    if (menu && menus[menu] && menus[menu].length) {
      var data = _.extend({}, this.data, {tagName: "div", menu_key: "transcript_edit"});
      var menuView = new app.views.Menu(data);
      this.data.menu = menuView.toString();
    }
  },

  render: function(){
    this.$el.html(this.template(this.data));
  }

});
