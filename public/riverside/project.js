window.PROJECT = {"name":"Riverside Transcript Editor","description":"A web app for transcripts that were automatically generated from speech-to-text software","logo":"/riverside/assets/img/riverside-icon.png","apiUrl":"","useVendorAudio":true,"transcriptsPerPage":500,"maxLineTimeOverlapMs":-1,"allowTranscriptDownload":false,"gaCode":"UA-60323667-4","adminEmails":["firstadmin555@peabody-fake.com","secondadmin666@peabody-fake.com","kelley.vincent.m@gmail.com","roosa.sadie@gmail.com"],"authProviders":[{"name":"google","label":"Google","path":"/auth/google_oauth2"}],"consensus":{"maxLineEdits":2,"minLinesForConsensus":2,"minLinesForConsensusNoEdits":2,"minPercentConsensus":0.5,"lineDisplayMethod":"guess","superUserHiearchy":50},"menus":{"header":[{"label":"Browse","url":"/"},{"label":"About","url":"/page/about"}],"footer":[{"label":"Terms and Conditions","url":"/page/toc"},{"label":"MIT License","url":"/page/mit_license"}]},"modals":{"tutorial_edit":{"title":"Transcript Editor Tutorial","displayMethod":"once","doneLabel":"Finished","pages":[{"label":"Editing","file":"ed_tutorial_1.md"},{"label":"Conventions","file":"ed_tutorial_2.md"},{"label":"Commands","file":"ed_tutorial_3.md"},{"label":"Have fun!","file":"ed_tutorial_6.md"}]}},"controls":[{"id":"toggle-play","action":"lineToggle","label":"Play/Pause","keyCode":32,"key":"[shift] + [space]","keyLabel":"Shift + Space Bar","keyDescription":"Hold shift and press space bar to play, pause, or re-play a line","shift":true},{"id":"next-line","action":"lineNext","label":"Next Line","keyCode":[13,40],"key":"[\u0026#8595;] OR [enter]","keyLabel":"Down Arrow or Enter Key","keyDescription":"Press the down arrow key or enter to go to next line"},{"id":"previous-line","action":"linePrevious","label":"Prev Line","keyCode":38,"key":"\u0026#8593;","keyLabel":"Up Arrow","keyDescription":"Press the up arrow key to go to previous line"},{"id":"previous-word","action":"wordPrevious","label":"Prev Word","keyCode":37,"key":"[shift] + [\u0026#8592;]","keyLabel":"Shift + Left Arrow","keyDescription":"Hold shift and press the left arrow key to move to previous word","shift":true},{"id":"next-word","action":"wordNext","label":"Next Word","keyCode":39,"key":"[shift] + [\u0026#8594;]","keyLabel":"Shift + Right Arrow","keyDescription":"Hold shift and press the right arrow key to move to next word","shift":true}],"pages":{"about.md":"\u003ch1\u003eAbout\u003c/h1\u003e\n\n\u003cp\u003eThe Council on Library and Information Resources has awarded a grant of $330,000 to digitize, preserve, and make publicly accessible previously unavailable archives of the Peabody Award winning radio station WRVR. \u0026quot;Public Radio as a Tool for Cultural Engagement in New York in the 60s and early 70s: Digitizing the Broadcasts of WRVR-FM Public Radio\u0026quot; is a joint project between The Riverside Church in the City of New York and the American Archive of Public Broadcasting, a collaboration between the Library of Congress and the WGBH Educational Foundation. The collection includes culturally significant non-commercial programming, including interviews, speeches, and musical interpretations on matters such as civil rights, war, and fine arts, from laypersons to famed scholars, including Martin Luther King, Jr., Malcolm X, and Pete Seeger.\u003c/p\u003e\n\n\u003cp\u003ePreservation of these materials will enhance study in many disciplines, including theology/religion, political science, and communications, especially related to American Christianity, homiletics, progressive responses to the Civil Rights movement, contemporary issues of race and sexuality, the cultural impact of the 1960s, and public radio as a tool for cultural engagement and social media precursor.\u003c/p\u003e\n\n\u003cp\u003eThese recordings will be made publicly available at the American Archive of Public Broadcasting (AAPB), a collaboration between the Library of Congress and WGBH. The AAPB coordinates a national effort to preserve at-risk public media before its content is lost to posterity and provide a central web portal for access to the unique programming that public stations have aired over the past 70 years.\u003c/p\u003e\n\n\u003cp\u003eOn this platform, you can help make this collection more accessible to all by correcting computer-generated transcripts of the digitized programs. The corrected transcripts will be made available along-side the media player for the digitized items at \u003ca href=\"http://americanarchive.org\"\u003ehttp://americanarchive.org\u003c/a\u003e.\u003c/p\u003e\n","ed_tutorial_1.md":"\u003ch1\u003eWelcome!\u003c/h1\u003e\n\n\u003cp\u003eThe transcript you are about to read was computer generated using speech-to-text software, so there are probably errors. This tool will allow you to listen to the recording while you edit its transcript. Here\u0026#39;s an example:\u003c/p\u003e\n\n\u003cvideo src=\"https://s3.amazonaws.com/togetherwelisten.nypl.org/video/twl_sample.mp4\" preload=\"auto\" class=\"toggle-sound sample-video\" autoplay loop muted poster=\"https://s3.amazonaws.com/togetherwelisten.nypl.org/img/twl_sample.png\"\u003e\u003c/video\u003e\n\n\u003cp class=\"caption\"\u003eAn example of how the transcript editor works (click for sound)\u003c/p\u003e\n\n\u003cp\u003e\u003cspan class=\"highlight\"\u003eAll your edits will be automatically saved\u003c/span\u003e but may not be immediately visible by others. Once enough editors agree on a corrected transcript line, we\u0026#39;ll lock that line for editing and have it displayed in our official transcripts.\u003c/p\u003e\n","ed_tutorial_2.md":"\u003ch1\u003eTranscription Conventions\u003c/h1\u003e\n\n\u003cp\u003eWe have one central guideline:\n\u003cstrong class=\"highlight\"\u003eUse your best judgment to transcribe the recording.\u003c/strong\u003e\u003c/p\u003e\n\n\u003cp\u003eFor common tricky transcriptions, we have a handy list of conventions. Quickly access this reference by selecting the Conventions button on the top of the page.\u003c/p\u003e\n\n\u003cvideo src=\"https://s3.amazonaws.com/togetherwelisten.nypl.org/video/twl_sample_conventions.mp4\" preload=\"auto\" class=\"toggle-sound sample-video\" autoplay loop muted\u003e\u003c/video\u003e\n","ed_tutorial_3.md":"\u003ch1\u003eCommands\u003c/h1\u003e\n\n\u003cp\u003eUse the tool\u0026#39;s commands navigate the interview\u0026#39;s audio and transcript. These commands are available in the toolbar along the bottom of the screen and with the following keyboard shortcuts.\u003c/p\u003e\n\n\u003ctable class=\"table-commands\"\u003e\n    \u003c% _.each(project.controls, function(control) { %\u003e\n    \u003ctr\u003e\n        \u003ctd\u003e\u003c%= control.keyLabel %\u003e\u003c/td\u003e\n        \u003ctd\u003e\u003c%= control.keyDescription %\u003e\u003c/td\u003e\n    \u003c/tr\u003e\n    \u003c% }) %\u003e\n\u003c/table\u003e\n","ed_tutorial_5.md":"\u003ch1\u003eVerify\u003c/h1\u003e\n\n\u003cp\u003e\u003cspan class=\"reviewing\"\u003eLines highlighted in orange\u003c/span\u003e await verification. Click on the line and select the best transcription from those presented. Once enough contributors agree on the correct transcription, the line will be finalized.\u003c/p\u003e\n\n\u003cvideo src=\"https://s3.amazonaws.com/togetherwelisten.nypl.org/video/twl_sample_verify.mp4\" preload=\"auto\" class=\"toggle-sound sample-video\" autoplay loop muted\u003e\u003c/video\u003e\n","ed_tutorial_6.md":"\u003ch1\u003eHave Fun!\u003c/h1\u003e\n\n\u003cp\u003eStart editing this interview or select another from \u003ca href=\"/\"\u003eBrowse\u003c/a\u003e. This tutorial will always be available in the navigation above.\u003c/p\u003e\n\n\u003cp\u003eSelect \u0026quot;Track Changes\u0026quot; to log in using a Google or Facebook account to keep track of all your edits. \u003cstrong\u003eYou do not need to log in to participate.\u003c/strong\u003e\u003c/p\u003e\n\n\u003cp\u003eRemember the golden rule: \u003cstrong class=\"highlight\"\u003eUse your best judgment to transcribe as you hear\u003c/strong\u003e.\u003c/p\u003e\n\n\u003cp\u003eThank you for your help making thousands of historic public broadcasting programs accessible!\u003c/p\u003e\n","home.md":"\u003cdiv class=\"banner\"\u003e\n\n  \u003cdiv style=\"height: 1em; min-height: 1em;\"\u003e\u003c/div\u003e\n\n  \u003cdiv class=\"container\" role=\"banner\"\u003e\n    \u003ch1\u003e\u003cimg class=\"logo-lg\" src=\"/riverside/assets/img/riverside-bar.png\" alt=\"Riverside\" title=\"Riverside Transcript Editor\" /\u003e\u003c/h1\u003e\n    \u003ch2\u003ePreserving the Historic Broadcasts of WRVR-FM Public Radio\u003c/h2\u003e\n  \u003c/div\u003e\n\u003c/div\u003e\n\n\u003cdiv class=\"container\" role=\"contentinfo\"\u003e\n  \u003cp\u003e\n    Help the The Riverside Church in the City of New York and the American Archive of Public Broadcasting fix computer-generated transcripts from thousands of historic and culturally significant WRVR-FM public radio programs from 1961-1971.\n  \u003c/p\u003e\n\n  \u003cvideo src=\"https://s3.amazonaws.com/transcript-editor/assets/twl_sample.mp4\" preload=\"auto\" class=\"toggle-sound sample-video\" autoplay loop muted poster=\"https://s3.amazonaws.com/transcript-editor/assets/twl_sample.png\"\u003e\u003c/video\u003e\n  \u003cp class=\"caption\"\u003eAn example of how the transcript editor works (click for sound)\u003c/p\u003e\n\n  \u003cp\u003eSelect a program to get started.\u003c/p\u003e\n\u003c/div\u003e\n","mit_license.md":"\u003ch2\u003eThe MIT License (MIT)\u003c/h2\u003e\n\n\u003cp\u003eCopyright (c) 2016 The New York Public Library\u003c/p\u003e\n\n\u003cp\u003ePermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \u0026quot;Software\u0026quot;), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\u003c/p\u003e\n\n\u003cp\u003eThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\u003c/p\u003e\n\n\u003cp\u003eTHE SOFTWARE IS PROVIDED \u0026quot;AS IS\u0026quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\u003c/p\u003e\n","footer.md":"\u003cp\u003ePowered By \u003ca href=\"https://github.com/NYPL/transcript-editor\"\u003eOpen Transcript Editor\u003c/a\u003e with generous support from:\u003c/p\u003e\n\n\u003cp\u003e\u003ca href=\"http://www.knightfoundation.org/grants/201551666/\"\u003e\u003cimg src=\"/oral-history/assets/img/knightfoundation_logo.png\" alt=\"Knight Foundation\" /\u003e\u003c/a\u003e\u003c/p\u003e\n","transcript_finished.md":"\u003cp\u003e\u003ca href=\"#finished\" class=\"button large transcript-finished\" role=\"button\"\u003eI am finished with this transcript!\u003c/a\u003e\u003c/p\u003e\n\n\u003cdiv class=\"show-when-finished\" aria-hidden=\"true\"\u003e\n  \u003cp\u003eThank you so much for your contributions! Your edits have been saved and will now be reviewed by others. The final transcript is one step closer completion!\u003c/p\u003e\n\n  \u003ca href=\"/\" class=\"button large\" role=\"button\"\u003eBrowse More Transcripts\u003c/a\u003e\n\u003c/div\u003e\n","toc.md":"\u003ch1\u003eTerms and Conditions\u003c/h1\u003e\n\n\u003cp\u003eTHE FOLLOWING TERMS AND CONDITIONS GOVERN YOUR USE OF THE SITE. PLEASE READ THESE TERMS OF USE CAREFULLY BEFORE USING THIS SITE.\u003c/p\u003e\n\n\u003cp\u003eReplace with peabody project-appropriate language!\u003c/p\u003e\n","transcript_edit.md":"\u003ch2\u003eInstructions\u003c/h2\u003e\n\n\u003cp\u003eThe following transcript was automatically generated using speech-to-text software, so there are probably errors. This tool will allow you to listen while you edit the transcript. For your convenience (we hope), the audio will automatically pause after each line.\u003c/p\u003e\n\n\u003cp\u003eUse the keyboard shortcuts or buttons in the toolbar below to navigate the transcript and audio. \u003cspan class=\"highlight\"\u003eAll your edits will be automatically saved\u003c/span\u003e but may not be immediately visible by others. Once enough people agree on the text of a particular line, that line will be visible to all and no longer editable.\u003c/p\u003e\n\n\u003cp\u003e\u003c% if (transcript.hasLinesInReview) { %\u003e\nThe transcript contains lines that are \u0026quot;in review\u0026quot; (\u003cspan class=\"reviewing\"\u003ehighlighted in orange\u003c/span\u003e) which means you cannot edit it, but can select the best transcription from a list of submitted edits.\n\u003c% } %\u003e\n\u003c% if (transcript.hasLinesCompleted) { %\u003e\nThe transcript \u003c% if (transcript.hasLinesInReview) { %\u003ealso \u003c% } %\u003econtains lines that are \u0026quot;completed\u0026quot; (\u003cspan class=\"completed\"\u003ehighlighted in green\u003c/span\u003e) which means they have been corrected by others and can no longer be edited, but you can still listen to them.\n\u003c% } %\u003e\u003c/p\u003e\n\n\u003cp class=\"text-center\"\u003e\u003ca href=\"#tutorial\" data-modal=\"tutorial_edit\" class=\"button large modal-invoke tutorial-link\" role=\"button\"\u003eView A Tutorial\u003c/a\u003e \u003cspan class=\"separator\"\u003e- or -\u003c/span\u003e \u003ca href=\"#start\" class=\"button large start-play disabled\" role=\"button\"\u003eGet Started\u003c/a\u003e\u003c/p\u003e\n","transcription_conventions.md":"\u003ctable class=\"table-conventions\"\u003e\n  \u003cthead\u003e\n    \u003ctr\u003e\n      \u003cth colspan=\"2\"\u003eTranscription Conventions\u003c/th\u003e\n      \u003cth\u003eExamples\u003c/th\u003e\n    \u003c/tr\u003e\n  \u003c/thead\u003e\n  \u003ctbody\u003e\n    \u003ctr\u003e\n      \u003ctd\u003eContractions\u003c/td\u003e\n      \u003ctd\u003eTranscribe as you hear them\u003c/td\u003e\n      \u003ctd\u003e“Shoulda”, “Didn’t”\u003c/td\u003e\n    \u003c/tr\u003e\n    \u003ctr\u003e\n      \u003ctd\u003eNumbers\u003c/td\u003e\n      \u003ctd\u003eTranscribe as numerals\u003c/td\u003e\n      \u003ctd\u003e“11 West 40th Street”\u003cbr /\u003e“She was 40 years old.”\u003c/td\u003e\n    \u003c/tr\u003e\n    \u003ctr\u003e\n      \u003ctd\u003eFilled Pauses \u0026amp; Hesitations\u003c/td\u003e\n      \u003ctd\u003eTranscribe as you hear them\u003c/td\u003e\n      \u003ctd\u003e“ah”, “eh”, “um”\u003c/td\u003e\n    \u003c/tr\u003e\n    \u003ctr\u003e\n      \u003ctd\u003eNoise\u003c/td\u003e\n      \u003ctd\u003eTranscribe in brackets; use descriptive language\u003c/td\u003e\n      \u003ctd\u003e“And then we [door slam]”, “So cold! [Brrrrr]”\u003c/td\u003e\n    \u003c/tr\u003e\n    \u003ctr\u003e\n      \u003ctd\u003ePartial words\u003c/td\u003e\n      \u003ctd\u003eIf someone stops speaking in the middle of a word, transcribe as much of the word as they say; follow it with a dash\u003c/td\u003e\n      \u003ctd\u003e“Tes- Testing”, “Absolu- Absolutely”\u003c/td\u003e\n    \u003c/tr\u003e\n    \u003ctr\u003e\n      \u003ctd\u003eHard-to-understand\u003c/td\u003e\n      \u003ctd\u003eFor speech that is difficult or impossible to understand, use question marks before and after\u003c/td\u003e\n      \u003ctd\u003e“And she told me that ?I should just leave?”, “Her name was ?inaudible?”\u003c/td\u003e\n    \u003c/tr\u003e\n  \u003c/tbody\u003e\n\u003c/table\u003e\n"}};