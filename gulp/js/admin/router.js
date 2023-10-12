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
    // var data = this._getData(data);
    // var header = new app.views.Header(data);
    // // THIS IS WHERE ADMIN VIEWS GET CALLED AS PARTIALS FOR ADMIN DASHBOARD v NOTE THE app.views.CLASS NAMES
    // // var stats = new app.views.AdminStats(data);
    // // var users = new app.views.AdminUsers(data);
    // // var flags = new app.views.AdminFlags(data);

    // var stats, users, flags = ""
    // var footer = new app.views.Footer(data);

    // render containers for reports
    var dashboard = new app.views.AdminDashboard(data)

    // var $row1 = $('<div class="row"></div>');
    // var $col1 = $('<div class="col"></div>');
    // var $col2 = $('<div class="col"></div>');
    // var $row2 = $('<div class="row"></div>');
    // // $col1.append(stats.$el);
    // // $col2.append(users.$el);
    // // $row1.append($col1).append($col2);

    // $row1.append(dashboard.$el)
    // $row2.append(flags.$el);
    // $('#main').append($row1).append($row2);

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

    var transcriptEditData = JSON.parse($.ajax({async: false, method: "GET", url: "/graph_data.json"}).responseText).data
    // var userActivityData = JSON.parse($.ajax({async: false, method: "GET", url: "/user_graph_data.json"}).responseText).data

    const chart = new Chart("chart", {
      type: "line",
      data: this.chartFormat("Total Edits Per Month", transcriptEditData),
      options: {
        responsive: true,
        // aspectRatio: 16/9,
        maintainAspectRatio: false
      }
    })
    
    // const chart2 = new Chart("chart2", {
    //   type: "line",
    //   data: this.chartFormat("Active Users Per Month", userActivityData),
    //   options: {
    //     responsive: true,
    //     // aspectRatio: 16/9,
    //     maintainAspectRatio: false
    //   }
    // })

    // use *this* this as this in this v
    this.addTimeframesClick = this.addTimeframesClick.bind(this)

    // div.timeframes don't exist until these ^ are called
    this.addTimeframesClick()
    this.addPagingClick()
  },

  chartFormat: function(name, chartData){
    var data = {
      labels: chartData.labels,
      datasets: [
        this.chartDataset(name, chartData.data, '#6fc3e3'),
        // this.chartDataset("Transcript Edit Activity", editActivityData),
        // this.chartDataset("Transcripts Completed", transcriptsCompletedData),
      ]
    };

    return data
  },


        // this.chartDataset("Active Users Per Month", chartData.userActivityData, '#ff0'),



  chartDataset: function(title, data, color) {
    return {
      label: title,
      data: data,
      fill: false,
      borderColor: color,
      tension: 0.1
    }
  },

  addTimeframesClick: function(){
    var dis = this
    $("div.timeframe").click(function(e){
      
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

  _updateReport: function(reportName, timeframe="all", page=0){
    // makes userData => UserData
    var reportPartialClass = reportName.charAt(0).toUpperCase() + reportName.slice(1)

      // get data from API, render partial, add  partial element
    var data = {}
    data[reportName] = this._pullReport(reportName, timeframe, page)
    data["page"] = page
    var reportPartial = new app.views[reportPartialClass](data)
    document.getElementById(reportName).innerHTML = reportPartial.$el[0].innerHTML
  },

  _pullReport: function(reportName, timeframe, page){
    timeframe = "?timeframe=" + timeframe
    var pageQuery = "&page=" + page

    if(reportName == "userData"){
      return JSON.parse($.ajax({async: false, method: "GET", url: "/user_data.json" + timeframe + pageQuery}).responseText).data
    } else if(reportName == "transcriptsCompletedData"){
      return JSON.parse($.ajax({async: false, method: "GET", url: "/transcripts_completed_data.json" + timeframe + pageQuery}).responseText).data

    } else if(reportName == "editActivityData"){
      return JSON.parse($.ajax({async: false, method: "GET", url: "/edit_activity_data.json" + timeframe + pageQuery}).responseText).data
    } else if(reportName == "collectionData"){
      return JSON.parse($.ajax({async: false, method: "GET", url: "/collection_data.json" + timeframe + pageQuery}).responseText).data
    }
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
