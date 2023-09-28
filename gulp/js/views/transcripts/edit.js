function getCookie(cname) {
  let name = cname + "=";
  let decodedCookie = decodeURIComponent(document.cookie);
  let ca = decodedCookie.split(';');
  for(let i = 0; i <ca.length; i++) {
    let c = ca[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
}

function setCookie(cname, cvalue) {
  const d = new Date();
  d.setTime(d.getTime() + (100 * 24 * 60 * 60 * 1000));
  let expires = "expires="+d.toUTCString();
  document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
}

app.views.TranscriptEdit = app.views.Transcript.extend({
  template: _.template(TEMPLATES['transcript_edit.ejs']),

  initialize: function(data){
    this.data = data;

    this.loadConventions();
    this.loadTranscript();
    // this.loadTutorial();
    this.listenForAuth();

    this.addPipListener()
  },

  finished: function(){
    this.$('.transcript-finished').addClass('disabled');
    this.$('.show-when-finished').addClass('active');
    $(window).trigger('scroll-to', [$('#completion-content'), 100]);
  },

  addPipListener: function(){
    document.addEventListener("scroll", (e) => {

      const rect = document.getElementById("transcript-header").getBoundingClientRect();

      const windowHeight = (window.innerHeight || document.documentElement.clientHeight);
      const windowWidth = (window.innerWidth || document.documentElement.clientWidth);

      const vertInView = (rect.top <= windowHeight) && ((rect.top + rect.height) >= 0);
      const horInView = (rect.left <= windowWidth) && ((rect.left + rect.width) >= 0);

      if(vertInView && horInView){
        // player in view
        // document.getElementById("video")
        // console.log( 'can see!' )
        // if(document.pictureInPictureElement){
        //   document.exitPictureInPicture()
        // }
        document.getElementById("video-player").classList.remove("pip")
      } else {
        // palyer not in view
        // document.getElementById("video")
        // console.log( 'cant see!' )
        // document.getElementById("video-player").children[0].requestPictureInPicture()
        document.getElementById("video-player").classList.add("pip")
      }

    })
  },

  addMinmaxClick: function(){
    var minmax = document.getElementById("minmax")
    if(minmax){
      var p = document.getElementById("video-player")
      minmax.addEventListener("click", function(){
        let arrow = minmax.innerHTML

        if(arrow == "▾"){
          arrow = "▴"
          p.classList.add("min")
        } else {
          arrow = "▾"
          p.classList.remove("min")
        }

        minmax.innerHTML = arrow
      })      
    }    
  },

  addAutoplayClick: function(){
    var autoplayButton = document.getElementById("autoplay")
    autoplayButton.addEventListener("click", function(e){
      var autoplay = getCookie("fixit-autoplay")
      if(!autoplay || autoplay == "n"){
        autoplayButton.innerHTML = "on"
        setCookie("fixit-autoplay", "y")
      } else {
        autoplayButton.innerHTML = "off"
        setCookie("fixit-autoplay", "n")
      }
    })
  },

  lineEditDelete: function(i){
    if (i < 0) return false;

    var $input = $('.line[sequence="'+i+'"] .text-input').first();
    if (!$input.length) return false;
    var line = this.data.transcript.lines[i];

    // display the original text
    $input.val(line.display_text);

    // update UI
    $input.attr('user-value', '');
    $input.closest('.line').removeClass('user-edited');

    // submit edit
    this.submitEdit({transcript_id: this.data.transcript.id, transcript_line_id: line.id, text: '', is_deleted: 1, is_new: false});
  },

  lineSave: function(i){
    if (i < 0) return false;

    var $input = $('.line[sequence="'+i+'"] .text-input').first();
    if (!$input.length) return false;

    var line = this.data.transcript.lines[i];
    var text = $input.val();
    var userText = $input.attr('user-value');

    // implicit save; save even when user has not edited original text
    // only save if line is editable
    if (text != userText && line.is_editable) {
      var is_new = !$input.closest('.line').hasClass('user-edited');

      // update UI
      $input.attr('user-value', text);
      $input.closest('.line').addClass('user-edited');

      // submit edit
      this.submitEdit({transcript_id: this.data.transcript.id, transcript_line_id: line.id, text: text, is_deleted: 0, is_new: is_new});
    }
  },

  lineVerify: function(data){
    var line = data.line,
        text = data.text;

    var $input = $('.line[sequence="'+line.sequence+'"] .text-input').first();
    if (!$input.length) return false;
    var is_new = !$input.closest('.line').hasClass('user-edited');

    // update UI
    $input.val(text);
    $input.attr('user-value', text);
    $input.closest('.line').addClass('user-edited');

    // submit edit
    this.submitEdit({transcript_id: this.data.transcript.id, transcript_line_id: line.id, text: text, is_deleted: 0, is_new: is_new});
  },

  loadAnalytics: function(){
    this.$el.on('click', '.conventions-link', function(){
      ANALYTICS.event('transcript', 'invoke-conventions');
    });

    this.$el.on('click', '.tutorial-link', function(){
      ANALYTICS.event('transcript', 'invoke-tutorial');
    });
  },

  loadCompletionContent: function(){
    this.data.completion_content = '';

    if (this.data.project.pages['transcript_finished.md']) {
      var page = new app.views.Page(_.extend({}, {project: this.data.project, page_key: 'transcript_finished.md'}))
      this.data.completion_content = page.toString();
    }
  },

  loadConventions: function(){
    this.data.page_conventions = '';

    if (this.data.project.pages['transcription_conventions.md']) {
      var page = new app.views.Page(_.extend({}, {project: this.data.project, page_key: 'transcription_conventions.md'}))
      this.data.page_conventions = page.toString();
    }
  },

  loadListeners: function(){
    var _this = this,
        controls = this.data.project.controls;

    // add link listeners
    $('.control').on('click.transcript', function(e){
      e.preventDefault();
      var $el = $(this);

      _.each(controls, function(control){
        if ($el.hasClass(control.id)) {
          _this[control.action]();
        }
      });

    });

    // add keyboard listeners
    $(window).on('keydown.transcript', function(e){
      _.each(controls, function(control){
        var keycodes = [control.keyCode];
        if (control.keyCode.constructor === Array) keycodes = control.keyCode;
        if (keycodes.indexOf(e.keyCode)>=0 && (control.shift && e.shiftKey || !control.shift)) {
          e.preventDefault();
          _this[control.action] && _this[control.action]();
          return false;
        }
      });
    });

    // add line listeners
    PubSub.subscribe('transcript.line.select', function(ev, line) {
      _this.lineSelect(line.sequence);
    });
    PubSub.subscribe('transcript.line.submit', function(ev, data){
      _this.lineSubmit();
    });

    // add verify listener
    PubSub.subscribe('transcript.line.verify', function(ev, data) {
      _this.lineVerify(data);
    });

    // add edit delete listener
    PubSub.subscribe('transcript.edit.delete', function(ev, line) {
      _this.lineEditDelete(line.sequence);
    });

    // add transcript finished listener
    PubSub.subscribe('transcript.finished', function(ev) {
      _this.onTranscriptFinished();
    });

    // add player listener
    PubSub.subscribe('player.toggle-play', function(ev, data) {
      _this.lineToggle();
    });

    // add start listener
    this.$el.on('click.transcript', '.start-play', function(e){
      e.preventDefault();
      _this.start();
    });

    // add start listener
    this.$el.on('click.transcript', '.transcript-finished', function(e){
      e.preventDefault();
      _this.finished();
    });

    this.loadAnalytics();
  },

  loadPageContent: function(){
    this.data.page_content = '';

    if (this.data.project.pages['transcript_edit.md']) {
      var page = new app.views.Page(_.extend({}, {transcript: this.data.transcript, project: this.data.project, page_key: 'transcript_edit.md'}))
      this.data.page_content = page.toString();
    }
  },

  loadTutorial: function(){
    var _this = this,
        tutorial = this.data.project.modals['tutorial_edit'];

    // show the tutorial if it hasn't been seen yet or should always be seen
    if (tutorial && (tutorial.displayMethod=="always" || !$.cookie('tutorial_edit-tutorial'))) {
      PubSub.publish('modal.invoke', 'tutorial_edit');
      $.cookie('tutorial_edit-tutorial', 1);
    }
  },

  loadUserProgress: function(){
    var availableLines = _.filter(this.data.transcript.lines, function(line){ return line.is_available; });
    var userProgressView = new app.views.TranscriptUserProgress({lines: availableLines});
    this.$('#transcript-user-progress').append(userProgressView.$el);
  },

  onAudioLoad: function(){
    this.data.debug && console.log("Loaded audio files");

    this.render();
    this.$el.removeClass('loading');
    this.$('.start-play').removeClass('disabled');
    this.loadListeners();
    this.message('Loaded transcript');
    if (!this.loaded) this.loaded = true;
    if (this.queue_start) this.start();
    this.queue_start = false;
    this.checkForStartTime();

    document.getElementById("video-player").appendChild(this.player)

    $(".playback-rate-button").click(function(e) {

      var button = document.getElementById(e.target.id)
      $(".playback-rate-button").removeClass("highlight")
      button.classList.add("highlight")
      document.getElementById("video").playbackRate = button.getAttribute("data-playback-rate")
    })
  },

  onTranscriptFinished: function(){
    this.$('.completion-content').addClass('active');
  },

  onTranscriptLoad: function(transcript){
    this.data.debug && console.log("Transcript", transcript.toJSON());

    PubSub.publish('transcript.load', {
      transcript: transcript.toJSON(),
      action: 'edit',
      label: transcript.get('title')
    });

    this.data.transcript = transcript.toJSON();
    this.parseTranscript();
    this.loadPageContent();
    this.loadCompletionContent();
    this.loadAudio();
  },

  onTimeUpdate: function(){
    if (this.player.playing) this.playerState('playing');
    if (this.pause_at_time !== undefined && this.player.currentTime >= this.pause_at_time) {
      
      var autoplay = getCookie("fixit-autoplay")
      if(!autoplay || autoplay == "n"){
        this.playerPause();
      }
    }
  },

  selectTextRange: function(increment){
    var $input = $('.line.active input').first();
    if (!$input.length) return false;

    var input = $input[0],
        text = input.value.replace(/\s{2,}/g, ' ').trim(),
        words = text.split(/\ +/),
        start = 0,
        end = 0;

    // remove multiple spaces
    if (text.length != input.value.length) {
      var cursorPos = $input.getInputSelection().start;
      $input.val(text);
      $input.setInputPosition(cursorPos);
    }

    // default to select where the cursor is
    var selection = $input.getInputSelection(),
        sub_text = text.substring(0, selection.start),
        sel_index = sub_text.split(/\ +/).length - 2;

    // text is selected
    if (selection.end > selection.start) {
      sel_index++;

    // no text selected
    } else {

      // moving left
      if (increment < 0) sel_index+=2;

      // if beginning of word
      if (selection.start <= 0 || text.charAt(selection.start-1)==' ') {
        if (increment < 0) sel_index--;

      // if end of word
      } else if (selection.start >= text.length-1 || text.charAt(selection.start)==' ') {
        if (increment > 0) sel_index++;
      }
    }

    // determine word selection
    sel_index += increment;
    if (sel_index >= words.length) {
      sel_index = 0;
    }
    if (sel_index < 0) {
      sel_index = words.length - 1;
    }

    // determine start/end of current word
    $.each(words, function(i, w){
      if (i==sel_index) {
        end = start + w.length;
        return false;
      }
      start += w.length + 1;
    });

    if (input.setSelectionRange){
      input.setSelectionRange(start, end);
    }
  },

  wordPrevious: function(){
    this.selectTextRange(-1);
  },

  wordNext: function(){
    this.selectTextRange(1);
  }

});
