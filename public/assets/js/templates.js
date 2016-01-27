window.TEMPLATES=window.TEMPLATES || {}; window.TEMPLATES["account.ejs"] = '<% if (user.signedIn) { %>  <div class="select">    <div class="select-active" title="Signed in as <%= user.name %>"><%= user.name %></div>    <div class="select-options account-menu menu">      <a href="#sign-out" class="sign-out-link select-option menu-item">Sign out</a>    </div>  </div><% } else { %>  <div class="select">    <div class="select-active">Sign in with</div>    <div class="select-options account-menu menu">      <% _.each(project.auth_providers, function(provider) { %>        <a href="#sign-in-with-<%= provider.name %>" data-provider="<%= provider.name %>" class="auth-link select-option menu-item" data-active="Signing In..."><%= provider.label %></a>      <% }) %>    </div>  </div><% } %>';
window.TEMPLATES=window.TEMPLATES || {}; window.TEMPLATES["menu.ejs"] = '<% if (project.menus && project.menus[menu_key] && project.menus[menu_key].length) { %>  <div class="<%= menu_key %>-menu menu">    <% _.each(project.menus[menu_key], function(item) { %>      <a href="<%= item.url %>" class="menu-item"><%= item.label %></a>    <% }) %>  </div><% } %>';
window.TEMPLATES=window.TEMPLATES || {}; window.TEMPLATES["page.ejs"] = '<% if (project.pages[page_key]) { %>  <div class="<%= page_key %> page">    <%= project.pages[page_key] %>  </div><% } %>';
window.TEMPLATES=window.TEMPLATES || {}; window.TEMPLATES["title.ejs"] = '<% if (project.logo) { %>  <a href="/" title="<%= project.name %>" class="title"><img src="<%= project.logo %>" alt="" class="logo" /></a><% } else { %>  <h1 class="title"><a href="/"><%= project.name %></a></h1><% } %>';
window.TEMPLATES=window.TEMPLATES || {}; window.TEMPLATES["transcript_item.ejs"] = '<a href="#<%= path %>" class="transcript-item">  <div class="item-image" style="background-image: url(<%= image_url %>)"></div>  <div class="item-title"><%= title %></div>  <% if (description) { %>    <div class="item-description"><%= description %></div>  <% } %>  <div class="item-info"><%= UTIL.formatTime(duration) %></div></a>';
window.TEMPLATES=window.TEMPLATES || {}; window.TEMPLATES["transcript_line.ejs"] = '';
window.TEMPLATES=window.TEMPLATES || {}; window.TEMPLATES["transcript_lines.ejs"] = '';
window.TEMPLATES=window.TEMPLATES || {}; window.TEMPLATES["transcript_list.ejs"] = '<div class="transcript-list">  <% _.each(transcripts, function(transcript) { %>    <%= template_item(transcript) %>  <% }) %></div><% if (has_more) { %><a href="#more" class="list-next button">Load More</a><% } %>';