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

      if(typeof $.cookie().authHeaders !== 'undefined'){
        let cookieData = JSON.parse($.cookie().authHeaders)
        xhr.setRequestHeader('access-token', cookieData['access-token'])
        xhr.setRequestHeader('client', cookieData['client'])
        xhr.setRequestHeader('token-type', cookieData['token-type'])
        xhr.setRequestHeader('expiry', cookieData['expiry'])
        xhr.setRequestHeader('uid', cookieData['uid'])
      }

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
