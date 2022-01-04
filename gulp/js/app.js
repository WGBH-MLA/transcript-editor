window.API_URL = PROJECT.apiUrl || window.location.protocol + '//' + window.location.hostname;
if (window.location.port && !PROJECT.apiUrl) window.API_URL += ':' + window.location.port

window.DEBUG = false;

window.app = {
  models: {},
  collections: {},
  views: {},
  routers: {},
  initialize: function(){
    // init auth
    var auth_provider_paths = _.object(_.map(PROJECT.authProviders, function(provider) { return [provider.name, provider.path]; }));
    $.auth.configure({
      apiUrl: API_URL,
      authProviderPaths: auth_provider_paths,
    });

    // explicitly add auth headers toe very request so that admin data api (*.json) requests use auth correctly
    $.ajaxSetup({ beforeSend: function(xhr) {
      xhr.setRequestHeader('access-token', JSON.parse($.cookie().authHeaders)['access-token'])
      xhr.setRequestHeader('client', JSON.parse($.cookie().authHeaders)['client'])
      xhr.setRequestHeader('token-type', JSON.parse($.cookie().authHeaders)['token-type'])
      xhr.setRequestHeader('expiry', JSON.parse($.cookie().authHeaders)['expiry'])
      xhr.setRequestHeader('uid', JSON.parse($.cookie().authHeaders)['uid'] )
    }});

    // Debug
    DEBUG && console.log("Project", PROJECT);
    PubSub.subscribe('auth.validation.success', function(ev, user) {
      DEBUG && console.log('User', user);
    });

    // Force a hard refresh after sign in/out
    PubSub.subscribe('auth.oAuthSignIn.success', function(ev, msg) {
      window.location.reload(true);
    });
    PubSub.subscribe('auth.signOut.success', function(ev, msg) {
      window.location.reload(true);
    });

    // load the main router
    var mainRouter = new app.routers.DefaultRouter();

    // Enable pushState for compatible browsers
    var enablePushState = true;
    var pushState = !!(enablePushState && window.history && window.history.pushState);

    // Start backbone history
    Backbone.history = Backbone.history || new Backbone.History({});
    Backbone.history.start({
      pushState:pushState
    });

    // Backbone.history.start();
  }
};

// Init backbone app
$(function(){
  app.initialize();
});
