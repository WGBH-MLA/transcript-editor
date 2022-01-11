// Core Transcript view to be extended
app.views.Transcript = app.views.Base.extend({

  current_line_i: -1,

  centerOn: function($el){
    var offset = $el.offset().top,
        height = $el.height(),
        windowHeight = $(window).height(),
        animationDuration = 500,
        animationPadding = 100,
        timeSinceLastAction = 9999,
        currentTime = +new Date(),
        scrollOffset;

    // determine time since last action to prevent too many queued animations
    if (this.lastCenterActionTime) {
      timeSinceLastAction = currentTime - this.lastCenterActionTime;
    }
    this.lastCenterActionTime = currentTime;

    // determine scroll offset
    if (height < windowHeight) {
      scrollOffset = offset - ((windowHeight / 2) - (height / 2));

    } else {
      scrollOffset = offset;
    }

    // user is clicking rapidly; don't animate
    if (timeSinceLastAction < (animationDuration+animationPadding)) {
      $('html, body').scrollTop(scrollOffset);
    } else {
      $('html, body').animate({scrollTop: scrollOffset}, animationDuration);
    }

  },

  checkForStartTime: function(){
    if (!this.data.queryParams || !this.data.queryParams.t) return false;

    var seconds = UTIL.getSeconds(this.data.queryParams.t);
    if (!seconds) return false;

    var select_line_i = 0;
    _.each(this.data.transcript.lines, function(line, i){
      var line_seconds = UTIL.getSeconds(UTIL.formatTime(line.start_time/1000));
      if (line_seconds <= seconds) select_line_i = i;
    });

    this.lineSelect(select_line_i);

  },

  fitInput: function($input){
    var fontSize = parseInt($input.css('font-size')),
        maxWidth = $input.width() + 5;

    // store the original font size
    if (!$input.attr('original-font-size')) $input.attr('original-font-size', fontSize);

    // see how big the text is at the default size
    var textWidth = $input.getTextSize().width;
    if (textWidth > maxWidth) {
        // the extra .8 here makes up for some over-measures
        fontSize = fontSize * maxWidth / textWidth * 0.8;
    }

    $input.css({fontSize: fontSize + 'px'});
  },

  fitInputReset: function($input){
    // store the original font size
    if ($input.attr('original-font-size')) {
      $input.css({fontSize: $input.attr('original-font-size') + 'px'});
    }
  },

  lineNext: function(){
    this.lineSelect(this.current_line_i + 1);
  },

  linePrevious: function(){
    this.lineSelect(this.current_line_i - 1);
  },

  lineSave: function(i){
    // override me
  },

  lineSelect: function(i){
    // check if in bounds
    var lines = this.data.transcript.lines;
    // the last one
    if (i >= lines.length) {
      this.onLineOff(this.current_line_i);
      PubSub.publish('transcript.finished', true);
      return false;
    }
    if (i < 0 || i==this.current_line_i) return false;

    this.onLineOff(this.current_line_i);

    // select line
    this.current_line_i = i;
    this.current_line = this.data.transcript.lines[i];

    // update UI
    $('.line.active').removeClass('active');
    var $active = $('.line[sequence="'+i+'"]').first();
    $active.addClass('active');
    this.centerOn($active);

    // focus on input
    var $input = $active.find('input');
    if ($input.length) $input.first().focus();

    // fit input
    this.fitInput($input);

    // play audio
    this.pause_at_time = this.current_line.end_time * 0.001;
    this.playerPlay(this.current_line.start_time);
  },

  lineSubmit: function(){
    this.lineNext();
  },

  lineToggle: function(){
    // not started yet, initialize to first line
    if (this.current_line_i < 0) {
      this.lineSelect(0);

    // replay the line if end-of-line reached
    } else if (this.pause_at_time !== undefined && this.player.currentTime >= this.pause_at_time && !this.player.playing) {
      this.playerPlay(this.current_line.start_time);

    // otherwise, just toggle play
    } else {
      this.playerToggle();
    }
  },

  listenForAuth: function(){
    var _this = this;

    // check auth sign in
    PubSub.subscribe('auth.oAuthSignIn.success', function(ev, msg) {
      _this.refresh();
    });

    // check sign out
    PubSub.subscribe('auth.signOut.success', function(ev, msg) {
      _this.refresh();
    });
  },

  loadAudio: function(){
    // Player already loaded
    if (this.player) {

      // Transcript audio already loaded
      if ($(this.player).attr('data-transcript') == ""+this.data.transcript.id) {
        this.onAudioLoad();
        return false;
      }
      $(this.player).remove();
    }

    var _this = this,
      audio_urls = this.data.project.useVendorAudio && this.data.transcript.vendor_audio_urls.length ? this.data.transcript.vendor_audio_urls : [this.data.transcript.audio_url];

    // build audio string
    var audio_string = '<audio data-transcript="'+this.data.transcript.id+'" preload>';
    _.each(audio_urls, function(url){
      var ext = url.substr(url.lastIndexOf('.') + 1),
          type = ext;
      audio_string += '<source src="'+url+'" type="audio/mpeg">';
    });
    audio_string += '</audio>';

    // create audio object
    var $audio = $(audio_string);
    this.player = $audio[0];

    // wait for audio to start to load
    this.player.onloadstart = function(){
      if (!_this.player_loaded) {
        _this.player_loaded = true;
        _this.onAudioLoad();
      }
    };

    // wait for it to load
    // this.player.oncanplay = function(){
    //   if (!_this.player_loaded) {
    //     _this.player_loaded = true;
    //     _this.onAudioLoad();
    //   }
    // };

    // check for time update
    this.player.ontimeupdate = function() {
      _this.onTimeUpdate();
    };

    // check for buffer time
    this.player.onwaiting = function(){
      _this.message('Buffering audio...');
      _this.playerState('buffering');
    };

  },

  loadListeners: function(){ /* override me */ },

  loadTranscript: function(){
    var _this = this;

    this.$el.addClass('loading');

    this.model.fetch({
      success: function(model, response, options){
        _this.onTranscriptLoad(model);
      },
      error: function(model, response, options){
        console.log( 'ugh error', response )

        $(window).trigger('alert', ['Whoops! We seem to have trouble loading this transcript. Please try again by refreshing your browser or come back later!']);
      }
    });
  },

  loadUserProgress: function(){ /* override me */ },

  message: function(text){
    // $('#transcript-notifications').text(text);
  },

  messageHide: function(text){
    // if ($('#transcript-notifications').text()==text) {
    //   $('#transcript-notifications').text('');
    // }
  },

  onAudioLoad: function(){ /* override me */ },

  onLineOff: function(i){
    // close all modals
    PubSub.publish('modals.dismiss', true);

    // save line always
    this.lineSave(i);

    // reset input
    var $input = $('.line[sequence="'+i+'"] input').first();
    this.fitInputReset($input);
  },

  onTranscriptLoad: function(transcript){ /* override me */ },

  onTimeUpdate: function(){ /* override me */ },

  parseTranscript: function(){
    var _this = this,
        lines = this.data.transcript.lines,
        user_edits = this.data.transcript.user_edits,
        line_statuses = this.data.transcript.transcript_line_statuses,
        speakers = this.data.transcript.speakers || [],
        superUserHiearchy = PROJECT.consensus.superUserHiearchy,
        user_role = this.data.transcript.user_role,
        user_flags = this.data.transcript.user_flags,
        maxLineTimeOverlapMs = PROJECT.maxLineTimeOverlapMs,
        allowTranscriptDownload = PROJECT.allowTranscriptDownload;

    // map edits for easy lookup
    var user_edits_map = _.object(_.map(user_edits, function(edit) {
      return [""+edit.transcript_line_id, edit.text]
    }));

    // map statuses for easy lookup
    var line_statuses_map = _.object(_.map(line_statuses, function(status) {
      return [""+status.id, status]
    }));

    // add multiple speaker option
    var speaker_options = _.map(speakers, _.clone);
    if (speakers.length > 1) {
      speaker_options.push({id: -1, name: "Multiple Speakers"});
    }
    this.data.transcript.speaker_options = speaker_options;

    // map speakers for easy lookup
    var speakers_map = _.object(_.map(speaker_options, function(speaker) {
      return [""+speaker.id, speaker]
    }));
    var speaker_ids = _.pluck(speaker_options, 'id');

    // map flags for easy lookup
    var user_flags_map = _.object(_.map(user_flags, function(flag) {
      return [""+flag.transcript_line_id, flag]
    }));

    // check to see if download is allowed
    this.data.transcript.can_download = allowTranscriptDownload && this.data.transcript.can_download;

    // process each line
    _.each(lines, function(line, i){
      // add user text to lines
      var user_text = "";
      if (_.has(user_edits_map, ""+line.id)) {
        user_text = user_edits_map[""+line.id];
      }
      _this.data.transcript.lines[i].user_text = user_text;

      // add statuses to lines
      var status = line_statuses[0];
      if (_.has(line_statuses_map, ""+line.transcript_line_status_id)) {
        status = line_statuses_map[""+line.transcript_line_status_id];
      }
      _this.data.transcript.lines[i].status = status;

      // determine display text; default to original
      var display_text = line.original_text;
      // show final text if final
      if (line.text && status.name=="completed") display_text = line.text;
      // otherwise, show user's text
      else if (user_text) display_text = user_text;
      // otherwise show guess text
      else if (PROJECT.consensus.lineDisplayMethod=="guess" && line.guess_text) display_text = line.guess_text;
      // set the display text
      _this.data.transcript.lines[i].display_text = display_text;

      // determine if text is editable
      var is_editable = true;
      // input is locked when reviewing/completed/flagged/archived
      if (_.contains(["reviewing","completed","flagged","archived"], status.name)) is_editable = false;
      // in review, but user submitted, so may edit
      if (status.name=="reviewing" && user_text) is_editable = true;
      // admins/mods can always edit
      if (user_role && user_role.hiearchy >= superUserHiearchy) is_editable = true;
      _this.data.transcript.lines[i].is_editable = is_editable;

      // determine if text is available
      var is_available = true;
      // input is available when not completed/archived
      if (_.contains(["completed","archived"], status.name)) is_available = false;
      _this.data.transcript.lines[i].is_available = is_available;

      // check for speaker
      var speaker = false;
      var speaker_pos = -1;
      if (_.has(speakers_map, ""+line.speaker_id)) {
        speaker = speakers_map[""+line.speaker_id];
        speaker_pos = speaker_ids.indexOf(speaker.id);
      }
      _this.data.transcript.lines[i].speaker = speaker;
      _this.data.transcript.lines[i].speaker_pos = speaker_pos;
      _this.data.transcript.lines[i].has_speakers = speakers.length > 1 ? true : false;

      // check for flag
      var user_flag = {flag_type_id: 0, text: ""};
      if (_.has(user_flags_map, ""+line.id)) {
        user_flag = user_flags_map[""+line.id];
      }
      _this.data.transcript.lines[i].user_flag = user_flag;

      // can user resolve a flag
      var can_resolve = false;
      if (user_role && user_role.hiearchy >= superUserHiearchy) can_resolve = true;
      _this.data.transcript.lines[i].can_resolve = can_resolve;

      // adjust timestamps overlap
      if (maxLineTimeOverlapMs >= 0 && i > 0) {
        var prevLine = _this.data.transcript.lines[i-1];
        var overlapMs = prevLine.end_time - line.start_time;
        // overlap is larger than threshold
        if (overlapMs > maxLineTimeOverlapMs) {
          // var adjustMs = Math.round((overlapMs - maxLineTimeOverlapMs) / 2);
          var paddingMs = 0;
          _this.data.transcript.lines[i-1].end_time = _this.data.transcript.lines[i].start_time + paddingMs;
          _this.data.transcript.lines[i].start_time = _this.data.transcript.lines[i].start_time - paddingMs;
        }
      }
    });

    // add data about lines that are being reviewed
    if (this.data.transcript.percent_reviewing > 0) this.data.transcript.hasLinesInReview = true;
    if (this.data.transcript.percent_completed > 0) this.data.transcript.hasLinesCompleted = true;
  },

  playerPause: function(){
    if (this.player.playing) {
      this.player.pause();
      this.message('Paused');
      this.playerState('paused');
    }
  },

  playerPlay: function(ms){

    // set time if passed
    if (ms !== undefined) {
      this.player.currentTime = ms * 0.001;
    }

    if (!this.player.playing) {
      this.player.play();
    }
  },

  playerState: function(state) {
    if (this.state==state) return false;
    this.state = state;
    this.$el.attr('state', state);
    PubSub.publish('player.state.change', state);
  },

  playerToggle: function(){
    if (this.player.playing) {
      this.playerPause();

    } else {
      this.playerPlay();
    }
  },

  refresh: function(){
    this.current_line_i = -1;

    this.loadTranscript();
  },

  render: function(){
    this.$el.html(this.template(this.data));
    this.renderLines();
    this.loadUserProgress();
  },

  renderLines: function(){
    var $container = this.$el.find('#transcript-lines'),
        $lines = $('<div>');

    if (!$container.length) return false;
    $container.empty();

    var speakers = this.data.transcript.speaker_options;
    var transcript_id = this.data.transcript.id;
    var flag_types = this.data.transcript.flag_types;
    _.each(this.data.transcript.lines, function(line) {
      var lineView = new app.views.TranscriptLine({
        transcript_id: transcript_id,
        line: line,
        speakers: speakers,
        flag_types: flag_types
      });
      $lines.append(lineView.$el);
    });
    $container.append($lines);
  },

  start: function(){
    this.$('.start-play').addClass('disabled');

    var selectLine = 0,
        lines = this.data.transcript.lines;

    // Find the first line that is editable
    $.each(lines, function(i, line){
      if (line.is_editable) {
        selectLine = i;
        return false;
      }
    });

    this.lineSelect(selectLine);
  },

  submitEdit: function(data){
    var _this = this;
    this.message('Saving changes...');

    $.post(API_URL + "/transcript_edits.json", {transcript_edit: data}, function(resp) {
      _this.message('Changes saved.');
    });

    PubSub.publish('transcript.edit.submit', data);
  }

});
