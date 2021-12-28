app.routers.DefaultRouter = Backbone.Router.extend({

  routes: {
    "admin":                "stats",
    "moderator":            "flags"
  },

  before: function(route, params) {

  },

  after: function(route, params) {

  },

  flags: function(){
    var data = this._getData(data);
    var header = new app.views.Header(data);
    var flags = new app.views.AdminFlags(data);
    var footer = new app.views.Footer(data);

    $('#main').append(flags.$el);
  },

  stats: function(){
    var data = this._getData(data);
    var header = new app.views.Header(data);
    var stats = new app.views.AdminStats(data);
    var users = new app.views.AdminUsers(data);
    var flags = new app.views.AdminFlags(data);
    var footer = new app.views.Footer(data);

    var $row1 = $('<div class="row"></div>');
    var $col1 = $('<div class="col"></div>');
    var $col2 = $('<div class="col"></div>');
    var $row2 = $('<div class="row"></div>');
    $col1.append(stats.$el);
    $col2.append(users.$el);
    $row1.append($col1).append($col2);
    $row2.append(flags.$el);
    $('#main').append($row1).append($row2);
  },

  _getData: function(data){
    var user = {};
    if ($.auth.user && $.auth.user.signedIn) {
      user = $.auth.user;
      console.log( 'user!!', user )
    }

    data = data || {};
    data = $.extend({}, {project: PROJECT, user: $.auth.user, debug: DEBUG, route: this._getRouteData()}, data);

    DEBUG && console.log('Route', data.route);

    console.log("HEy! ", data)

    return data;
  },

  _getRouteData: function(){
    var Router = this,
        fragment = Backbone.history.fragment,
        routes = _.pairs(Router.routes),
        route = null, action = null, params = null, matched, path;

    matched = _.find(routes, function(handler) {
      action = _.isRegExp(handler[0]) ? handler[0] : Router._routeToRegExp(handler[0]);
      return action.test(fragment);
    });

    if(matched) {
      params = Router._extractParameters(action, fragment);
      route = matched[0];
      action = matched[1];
    }

    path = fragment ? '/#/' + fragment : '/';

    return {
      route: route,
      action: action,
      fragment : fragment,
      path: path,
      params : params
    };
  }

});
