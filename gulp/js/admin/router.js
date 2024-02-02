function chartFormat(name, chartData, color){
  var data = {
    labels: chartData.labels,
    datasets: [
      this.chartDataset(name, chartData.data, color)
    ]
  };

  return data
}
function chartDataset(title, data, color) {
  return {
    label: title,
    data: data,
    fill: false,
    borderColor: color,
    tension: 0.1
  }
}

app.routers.DefaultRouter = Backbone.Router.extend({

  routes: {
    "dashboard":            "dashboard",
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

  dashboard: function(){
    // render containers for reports
    var dashboard = new app.views.AdminDashboard(data)

    // doesnt really *get* anything v
    var data = this._getData(data);
    var header = new app.views.Header(data)

    // var dashboard = new app.views.AdminDashboard(data)

    var $container = document.createElement("div")
    var footer = new app.views.Footer(data)

    $('#main').append(dashboard.$el)

    this._updateReport("userData")
    this._updateReport("transcriptsCompletedData")
    this._updateReport("editActivityData")
    this._updateReport("collectionData")

    $.ajax({method: "GET", url: "/graph_data.json"}).done(function(response) {
      var transcriptActivityData = response.data
      const transcriptChart = new Chart("chart-transcript", {
        type: "line",
        data: chartFormat("Total Edits Per Month", transcriptActivityData, "#6fc3e3"),
        options: {
          responsive: true,
          // aspectRatio: 16/9,
          maintainAspectRatio: false
        }
      })

      // delete spinner after we get some chart data
      document.getElementById("graph-spinner").remove()
    })

    $.ajax({method: "GET", url: "/user_graph_data.json"}).done(function(response){
      var userActivityData = response.data
      const userChart = new Chart("chart-user", {
        type: "line",
        data: chartFormat("Active Users Per Month", userActivityData, "#efa731"),
        options: {
          responsive: true,
          // aspectRatio: 16/9,
          maintainAspectRatio: false
        }
      })
    })

    // use *this* this as this in this v
    this.addTimeframesClick = this.addTimeframesClick.bind(this)

    this.addTimeframesClick()
    this.addPagingClick()
    this.addGraphsClick()
  },

  addTimeframesClick: function(){
    var dis = this
    $("div.timeframe").click(function(e){

      console.log( 'is this running' )
      
      var selectedTimeframe = $(this).attr("data-timeframe")
      // which report are we re-running
      var selectedReport = $(this).parent().parent().attr("id")
      dis._updateReport(selectedReport, selectedTimeframe)

      // old elements disappear, so need to reattach click event
      $("#" + selectedReport + " div.timeframe").removeClass("active")
      $("#" + e.target.id).addClass("active")

      dis.addTimeframesClick()
      dis.addPagingClick()
    })

  },

  addGraphsClick: function(){
    var dis = this
    $("div.chart-tab").click(function(e){
      
      $("div.chart-tab").removeClass("active")
      $("#" + e.target.id).addClass("active")

      $("div.chart-container").addClass("hidden")
      $("#" + e.target.id.replace("-tab", "") + "-container").removeClass("hidden")
    })

  },

  addPagingClick: function(){
    var dis = this
    $("div.paging div div.enabled").click(function(e){
      
      var selectedPage = parseInt($(this).attr("data-page"))
      // which report are we re-running
      var selectedReport = $(this).parent().parent().parent().attr("id")

      // look for which timeframe tab is active within this report
      var selectedTimeframe = $("#"+selectedReport + " div.timeframe.active").attr("data-timeframe")
      dis._updateReport(selectedReport, selectedTimeframe, selectedPage)

      $("#" + selectedReport + " div.timeframe").removeClass("active")
      $("#" + selectedReport + "-" + selectedTimeframe).addClass("active")

      // old elements disappear, so need to reattach click events
      dis.addTimeframesClick()
      dis.addPagingClick()
    })
  },

  _updateReport: async function(reportName, timeframe="all", page=0){
    timeframe = "?timeframe=" + timeframe
    var pageQuery = "&page=" + page

    var endpoint
    if(reportName == "userData"){
      endpoint = "/user_data.json"
    } else if(reportName == "transcriptsCompletedData"){
      endpoint = "/transcripts_completed_data.json"
    } else if(reportName == "editActivityData"){
      endpoint = "/edit_activity_data.json"
    } else if(reportName == "collectionData"){
      endpoint = "/collection_data.json"
    }

    // $.ajax({method: "GET", url: endpoint + timeframe + pageQuery}).done(function(response){

    //   var reportData = response.data

    //   var data = {}
    //   data[reportName] = reportData
    //   data["page"] = page
  
    //   // makes userData => UserData
    //   var reportPartialClass = reportName.charAt(0).toUpperCase() + reportName.slice(1)
    //   console.log( `now Im getting ${reportPartialClass}` )
    //   var reportPartial = new app.views[reportPartialClass](data)
    //   document.getElementById(reportName).innerHTML = reportPartial.$el[0].innerHTML
    // }).fail(function(e) {
    //   alert( `ouch! ${e}` )
    // })

    fetch(endpoint + timeframe + pageQuery, {method: "GET"}).then( (response) => response.json()).then((response) => {
      var reportData = response.data

      var data = {}
      data[reportName] = reportData
      data["page"] = page
  
      // makes userData => UserData
      var reportPartialClass = reportName.charAt(0).toUpperCase() + reportName.slice(1)
      console.log( `now Im getting ${reportPartialClass}` )
      var reportPartial = new app.views[reportPartialClass](data)
      document.getElementById(reportName).innerHTML = reportPartial.$el[0].innerHTML
    })








  },

  _getData: function(data){
    var user = {};
    if ($.auth.user && $.auth.user.signedIn) {
      user = $.auth.user;
    }

    data = data || {};
    data = $.extend({}, {project: PROJECT, user: $.auth.user, debug: DEBUG, route: this._getRouteData()}, data);

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
