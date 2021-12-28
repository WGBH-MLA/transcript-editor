app.routers.DefaultRouter = Backbone.Router.extend({

  routes: {
    "":                             "index",
    "?*queryString":                "index",
    "transcripts/:id":              "transcriptEdit",
    "transcripts/:id?*queryString": "transcriptEdit",
    "page/:id":                     "pageShow",
    "dashboard":                    "dashboard",
  },

  before: function( route, params ) {
    $('#main').empty().addClass('loading');
  },

  after: function( route, params ) {
    window.scrollTo(0, 0);
  },

  dashboard: function(){
    var data = this._getData(data);
    var header = new app.views.Header(data);
    var main = new app.views.Dashboard(data);
    var footer = new app.views.Footer(data);
    main.$el.attr('role', 'main');
  },

  index: function(queryString) {
    var data = this._getData(data);
    if (queryString) data.queryParams = deparam(queryString);
    var header = new app.views.Header(data);
    var main = new app.views.Home(data);
    var footer = new app.views.Footer(data);
  },

  pageShow: function(id){
    var data = this._getData(data);
    var header = new app.views.Header(data);
    var main = new app.views.Page(_.extend({}, data, {el: '#main', page_key: id}));
    var footer = new app.views.Footer(data);
    main.$el.removeClass('loading').attr('role', 'main');
  },

  transcriptEdit: function(id, queryString) {
    var data = this._getData(data);
    if (queryString) data.queryParams = deparam(queryString);
    var header = new app.views.Header(data);
    var toolbar = new app.views.TranscriptToolbar(_.extend({}, data, {el: '#secondary-navigation', menu: 'transcript_edit'}));
    var modals = new app.views.Modals(data);
    var footer = new app.views.Footer(data);

    var verifyView = new app.views.TranscriptLineVerify(data);
    modals.addModal(verifyView.$el);

    var flagView = new app.views.TranscriptLineFlag(data);
    modals.addModal(flagView.$el);

    var downloadView = new app.views.TranscriptDownload(_.extend({}, data, {transcript_id: id}));
    modals.addModal(downloadView.$el);

    var transcript_model = new app.models.Transcript({id: id});
    var main = new app.views.TranscriptEdit(_.extend({}, data, {el: '#main', model: transcript_model}));
  },

  _getData: function(data){

    var user = {};

    console.log("user says literally anything", $.auth.user)

    if ($.auth.user && $.auth.user.signedIn) {
      user = $.auth.user;
      console.log( 'user says what ', user )
    }



    data = data || {};
    data = $.extend({}, {project: PROJECT, user: user, debug: DEBUG, route: this._getRouteData()}, data);

    DEBUG && console.log('Route', data.route);

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
