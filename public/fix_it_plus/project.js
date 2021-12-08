window.PROJECT = {"name":"FIX IT +","description":"A web app for transcripts that were automatically generated from speech-to-text software","logo":"/fix_it_plus/assets/img/aapb-logo.png","apiUrl":"","useVendorAudio":true,"transcriptsPerPage":500,"maxLineTimeOverlapMs":-1,"allowTranscriptDownload":false,"gaCode":"UA-60323667-4","adminEmails":["jason.corum@gmail.com","roosa.sadie@gmail.com","caseydaviskaufman@gmail.com","kcariani@gmail.com","rebeccafraimow@gmail.com","rynmarchese@gmail.com","lesliek.bourgeois@gmail.com"],"authProviders":[{"name":"google","label":"Google","path":"/users/auth/google_oauth2"}],"consensus":{"maxLineEdits":2,"minLinesForConsensus":2,"minLinesForConsensusNoEdits":2,"minPercentConsensus":0.5,"lineDisplayMethod":"guess","superUserHiearchy":50},"menus":{"header":[{"label":"Browse","url":"/"},{"label":"About","url":"/page/about"}],"footer":[{"label":"Terms and Conditions","url":"/page/toc"},{"label":"MIT License","url":"/page/mit_license"}]},"modals":{"tutorial_edit":{"title":"Transcript Editor Tutorial","displayMethod":"once","doneLabel":"Finished","pages":[{"label":"Editing","file":"ed_tutorial_1.md"},{"label":"Conventions","file":"ed_tutorial_2.md"},{"label":"Commands","file":"ed_tutorial_3.md"},{"label":"Have fun!","file":"ed_tutorial_6.md"}]}},"controls":[{"id":"toggle-play","action":"lineToggle","label":"Play/Pause","keyCode":32,"key":"[shift] + [space]","keyLabel":"Shift + Space Bar","keyDescription":"Hold shift and press space bar to play, pause, or re-play a line","shift":true},{"id":"next-line","action":"lineNext","label":"Next Line","keyCode":[13,40],"key":"[\u0026#8595;] OR [enter]","keyLabel":"Down Arrow or Enter Key","keyDescription":"Press the down arrow key or enter to go to next line"},{"id":"previous-line","action":"linePrevious","label":"Prev Line","keyCode":38,"key":"\u0026#8593;","keyLabel":"Up Arrow","keyDescription":"Press the up arrow key to go to previous line"},{"id":"previous-word","action":"wordPrevious","label":"Prev Word","keyCode":37,"key":"[shift] + [\u0026#8592;]","keyLabel":"Shift + Left Arrow","keyDescription":"Hold shift and press the left arrow key to move to previous word","shift":true},{"id":"next-word","action":"wordNext","label":"Next Word","keyCode":39,"key":"[shift] + [\u0026#8594;]","keyLabel":"Shift + Right Arrow","keyDescription":"Hold shift and press the right arrow key to move to next word","shift":true}],"pages":{"about.md":"\u003ch1\u003eAbout\u003c/h1\u003e\n\n\u003cp\u003eWe need you to help ensure that public media remains accessible—not just today\u0026#39;s broadcasts, but the archive all the way back to the beginning.\u003c/p\u003e\n\n\u003cp\u003eAfter a brief moment on the air, most public broadcasting programs are filed away and languish on shelves, sometimes for decades. The American Archive of Public Broadcasting (AAPB), a collaboration between public media powerhouse WGBH and the Library of Congress, believes this treasure trove of public television and radio programs should be preserved and made available to the American people. For the past 4 years, we\u0026#39;ve been hard at work, digitizing thousands of broadcast hours from public media\u0026#39;s 60+ year legacy, to provide public access to this rich and colorful history, and preserve it for future generations at the Library of Congress. And now, we need your help to make the content in this deep archive easier to search and find.\u003c/p\u003e\n\n\u003cp\u003eWith funding from the Institute of Museum and Library Services, the AAPB has launched FIX IT+, our own instance of the New York Public Library\u0026#39;s Transcript Editor tool. FIX IT+ users can correct transcripts for any of the historic programs available in the AAPB\u0026#39;s Online Reading Room. Find a program of interest in the archive and help make the program accessible and discoverable by following along the computer-generated transcript, making corrections along the way.\u003c/p\u003e\n\n\u003cp\u003eHelp us preserve history for future generations. Your corrections will be made available in public media\u0026#39;s largest digital archive at americanarchive.org\u003c/p\u003e\n\n\u003ch1\u003eAbout the AAPB\u003c/h1\u003e\n\n\u003cp\u003eThe American Archive of Public Broadcasting (AAPB) is a collaboration between the Library of Congress and the WGBH Educational Foundation to coordinate a national effort to preserve at-risk public media before its content is lost to posterity and provide a central web portal for access to the unique programming that public stations have aired over the past 60 years. To date, over 40,000 hours of television and radio programming contributed by more than 100 public media organizations and archives across the United States have been digitized for long-term preservation and access. The entire collection is available on location at WGBH and the Library of Congress, and more than 18,000 programs are available online at \u003ca href=\"https://americanarchive.org/\"\u003eamericanarchive.org\u003c/a\u003e.\u003c/p\u003e\n\n\u003ch1\u003eAbout IMLS\u003c/h1\u003e\n\n\u003cp\u003eThis project was made possible in part by the Institute of Museum and Library Services [IMLS Grant No. LG-71-15-0208-15]. The Institute of Museum and Library Services is celebrating its 20th Anniversary. IMLS is the primary source of federal support for the nation\u0026#39;s 123,000 libraries and 35,000 museums. Our mission has been to inspire libraries and museums to advance innovation, lifelong learning, and cultural and civic engagement. For the past 20 years, our grant making, policy development, and research has helped libraries and museums deliver valuable services that make it possible for communities and individuals to thrive. To learn more, visit \u003ca href=\"https://www.imls.gov/\"\u003ewww.imls.gov\u003c/a\u003e and follow us on \u003ca href=\"https://www.facebook.com/USIMLS\"\u003eFacebook\u003c/a\u003e, \u003ca href=\"https://twitter.com/us_imls\"\u003eTwitter\u003c/a\u003e and \u003ca href=\"https://www.instagram.com/us_imls\"\u003eInstagram\u003c/a\u003e.\u003c/p\u003e\n\n\u003cp\u003eThe views, findings, conclusions or recommendations expressed in this website do not necessarily represent those of the Institute of Museum and Library Services.\u003c/p\u003e\n","ed_tutorial_1.md":"\u003ch1\u003eWelcome!\u003c/h1\u003e\n\n\u003cp\u003eThe transcript you are about to read was computer generated using speech-to-text software, so there are probably errors. This tool will allow you to listen to the recording while you edit its transcript. Here\u0026#39;s an example:\u003c/p\u003e\n\n\u003cvideo src=\"https://s3.amazonaws.com/togetherwelisten.nypl.org/video/twl_sample.mp4\" preload=\"auto\" class=\"toggle-sound sample-video\" autoplay loop muted poster=\"https://s3.amazonaws.com/togetherwelisten.nypl.org/img/twl_sample.png\"\u003e\u003c/video\u003e\n\n\u003cp class=\"caption\"\u003eAn example of how the transcript editor works (click for sound)\u003c/p\u003e\n\n\u003cp\u003e\u003cspan class=\"highlight\"\u003eAll your edits will be automatically saved\u003c/span\u003e but may not be immediately visible by others. Once enough editors agree on a corrected transcript line, we\u0026#39;ll lock that line for editing and have it displayed in our official transcripts.\u003c/p\u003e\n","ed_tutorial_2.md":"\u003ch1\u003eTranscription Conventions\u003c/h1\u003e\n\n\u003cp\u003eWe have one central guideline:\n\u003cstrong class=\"highlight\"\u003eUse your best judgment to transcribe the recording.\u003c/strong\u003e\u003c/p\u003e\n\n\u003cp\u003eFor common tricky transcriptions, we have a handy list of conventions. Quickly access this reference by selecting the Conventions button on the top of the page.\u003c/p\u003e\n\n\u003cvideo src=\"https://s3.amazonaws.com/togetherwelisten.nypl.org/video/twl_sample_conventions.mp4\" preload=\"auto\" class=\"toggle-sound sample-video\" autoplay loop muted\u003e\u003c/video\u003e\n","ed_tutorial_3.md":"\u003ch1\u003eCommands\u003c/h1\u003e\n\n\u003cp\u003eUse the tool\u0026#39;s commands navigate the interview\u0026#39;s audio and transcript. These commands are available in the toolbar along the bottom of the screen and with the following keyboard shortcuts.\u003c/p\u003e\n\n\u003ctable class=\"table-commands\"\u003e\n    \u003c% _.each(project.controls, function(control) { %\u003e\n    \u003ctr\u003e\n        \u003ctd\u003e\u003c%= control.keyLabel %\u003e\u003c/td\u003e\n        \u003ctd\u003e\u003c%= control.keyDescription %\u003e\u003c/td\u003e\n    \u003c/tr\u003e\n    \u003c% }) %\u003e\n\u003c/table\u003e\n","ed_tutorial_5.md":"\u003ch1\u003eVerify\u003c/h1\u003e\n\n\u003cp\u003e\u003cspan class=\"reviewing\"\u003eLines highlighted in orange\u003c/span\u003e await verification. Click on the line and select the best transcription from those presented. Once enough contributors agree on the correct transcription, the line will be finalized.\u003c/p\u003e\n\n\u003cvideo src=\"https://s3.amazonaws.com/togetherwelisten.nypl.org/video/twl_sample_verify.mp4\" preload=\"auto\" class=\"toggle-sound sample-video\" autoplay loop muted\u003e\u003c/video\u003e\n","ed_tutorial_6.md":"\u003ch1\u003eHave Fun!\u003c/h1\u003e\n\n\u003cp\u003eStart editing this interview or select another from \u003ca href=\"/\"\u003eBrowse\u003c/a\u003e. This tutorial will always be available in the navigation above.\u003c/p\u003e\n\n\u003cp\u003eSelect \u0026quot;Track Changes\u0026quot; to log in using a Google or Facebook account to keep track of all your edits. \u003cstrong\u003eYou do not need to log in to participate.\u003c/strong\u003e\u003c/p\u003e\n\n\u003cp\u003eRemember the golden rule: \u003cstrong class=\"highlight\"\u003eUse your best judgment to transcribe as you hear\u003c/strong\u003e.\u003c/p\u003e\n\n\u003cp\u003eThank you for your help making thousands of historic public broadcasting programs accessible!\u003c/p\u003e\n","home.md":"\u003cdiv class=\"banner\"\u003e\n\u003cdiv class=\"container\" role=\"banner\"\u003e\n\u003ch1\u003e\u003cimg class=\"logo-lg\" src=\"/fix_it_plus/assets/img/AAPB_1Line_color_rgb.png\" alt=\"FIX IT +\" title=\"American Archive of Public Broadcasting Transcript Editor\" /\u003e\u003c/h1\u003e\n\u003ch2\u003eHelp ensure that public media remains accessible to all!\u003c/h2\u003e\n\u003c/div\u003e\n\n\u003cp\u003e\u003c/div\u003e\n\u003cdiv class=\"container\" role=\"contentinfo\"\u003e\n\u003cp\u003eHelp the \u003ca href=\"https://americanarchive.org/\"\u003eAmerican Archive of Public Broadcasting\u003c/a\u003e fix computer-generated transcripts from thousands of historic public broadcasting programs from across the country.\u003c/p\u003e\u003c/p\u003e\n\n\u003cvideo src=\"https://s3.amazonaws.com/transcript-editor/assets/twl_sample.mp4\" preload=\"auto\" class=\"toggle-sound sample-video\" autoplay loop muted poster=\"https://s3.amazonaws.com/transcript-editor/assets/twl_sample.png\"\u003e\u003c/video\u003e\n\n\u003cp class=\"caption\"\u003eAn example of how the transcript editor works (click for sound)\u003c/p\u003e\n\n\u003cp\u003eSelect a program to get started.\u003c/p\u003e\n\n\u003cp\u003e\u003c/div\u003e\u003c/p\u003e\n","mit_license.md":"\u003ch2\u003eThe MIT License (MIT)\u003c/h2\u003e\n\n\u003cp\u003eCopyright (c) 2016 The New York Public Library\u003c/p\u003e\n\n\u003cp\u003ePermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \u0026quot;Software\u0026quot;), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\u003c/p\u003e\n\n\u003cp\u003eThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\u003c/p\u003e\n\n\u003cp\u003eTHE SOFTWARE IS PROVIDED \u0026quot;AS IS\u0026quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\u003c/p\u003e\n","footer.md":"\u003cp\u003ePowered By \u003ca href=\"https://github.com/NYPL/transcript-editor\"\u003eOpen Transcript Editor\u003c/a\u003e with generous support from:\u003c/p\u003e\n\n\u003cp\u003e\u003ca href=\"http://www.knightfoundation.org/grants/201551666/\"\u003e\u003cimg src=\"/oral-history/assets/img/knightfoundation_logo.png\" alt=\"Knight Foundation\" /\u003e\u003c/a\u003e\u003c/p\u003e\n","transcript_finished.md":"\u003cp\u003e\u003ca href=\"#finished\" class=\"button large transcript-finished\" role=\"button\"\u003eI am finished with this transcript!\u003c/a\u003e\u003c/p\u003e\n\n\u003cdiv class=\"show-when-finished\" aria-hidden=\"true\"\u003e\n  \u003cp\u003eThank you so much for your contributions! Your edits have been saved and will now be reviewed by others. The final transcript is one step closer completion!\u003c/p\u003e\n\n  \u003ca href=\"/\" class=\"button large\" role=\"button\"\u003eBrowse More Transcripts\u003c/a\u003e\n\u003c/div\u003e\n","toc.md":"\u003ch1\u003eTerms and Conditions\u003c/h1\u003e\n\n\u003cp\u003eTHE FOLLOWING TERMS AND CONDITIONS GOVERN YOUR USE OF THE SITE. PLEASE READ THESE TERMS OF USE CAREFULLY BEFORE USING THIS SITE.\u003c/p\u003e\n\n\u003cp\u003eWGBH Educational Foundation (“WGBH”), on behalf of the American Archive of Public Broadcasting, which is a collaboration between WGBH and the Library of Congress, has created and maintains this FIX IT website (the “Site”). This Site is governed by the \u003ca href=\"http://americanarchive.org/legal/tou\"\u003eTerms of Use\u003c/a\u003e (the “Terms”) and \u003ca href=\"http://americanarchive.org/legal/privacy\"\u003ePrivacy Policy\u003c/a\u003e (the “Policy”) of the American Archive for Public Broadcasting located at americanarchive.org. By using the Site you agree to be bound by the Terms and Policy. If you do not agree to the Term and Policy you must exit the Site and you may not use the Site or any of its features. Your acceptance of the Terms upon your first visit to the Site constitutes acceptance to the Terms on all of your subsequent visits to the Site.\u003c/p\u003e\n\n\u003cp\u003eIn addition to the Terms and the Policy, the following additional terms shall apply to the Site (the “Supplemental Terms”). In the event of any conflict between the Supplemental Terms and the Terms or the Policy, then the Supplemental Terms shall take priority, with all other provisions of the Terms and the Policy remaining in full effect.\u003c/p\u003e\n\n\u003cp\u003eA. Registration\nYou accept all responsibility for the use of any third party login function or API that you use to register for the Site and consent to information sharing by and between the providers of such services and WGBH which may include your name and contact information. You are solely responsible for all activities that occur through your account. You further acknowledge that you may receive emails pertaining to promotional suggested topics for FIX IT games.\u003c/p\u003e\n\n\u003cp\u003eB. Restrictions on Use of Site and Content\nYou must be at least thirteen (13) years of age to register for the Site and to submit any User Generated Content (defined by the Terms and below).\u003c/p\u003e\n\n\u003cp\u003eYou agree that use of the Site’s features and transcription games results in the creation of derivative works and that all rights associated with such transcription and results of said games remains the sole property of WGBH, the contributing station, or other rights holder for the material being transcribed.\u003c/p\u003e\n\n\u003cp\u003eC. User Generated Content (UGC):\nYou acknowledge that WGBH, the contributing station, or other rights holder for the material being transcribed as determined by WGBH, is the owner of all content generated through your use of the transcription games located on the site (“User Generated Content” or “UGC”) and that you may not control WGBH’s use of the content. WGBH is not obligated to use your UGC.\u003c/p\u003e\n\n\u003cp\u003eYou acknowledge that WGBH assumes no responsibility or liability arising from UGC that unreasonably differs from the source material, or for any error, defamation, libel, omission, obscenity, danger or inaccuracy contained in the same.\u003c/p\u003e\n\n\u003cp\u003eYou agree to use reasonable effort to ensure accuracy in your use of the transcription games which shall include utilizing the provided instructions for the same, and shall not use the games and UGC as an avenue to engage in any behavior which may be off-topic, contains personal attacks or expletives or is otherwise abusive, threatening, unlawful, harassing, discriminatory, libelous, obscene, false, pornographic, that infringes on the rights of a third party, or as a means of advertising or promoting any off topic matter.\u003c/p\u003e\n\n\u003cp\u003eD. Links to Third Party Sites\nThis site contains links to affiliated and unaffiliated websites. Such sites are subject to their own terms and conditions. Please review the terms and conditions specific to each website that you intend to make use of and make sure you comply with the applicable rules. You agree that WGBH shall have no liability for damaged, broken, or misleading links. Links are provided for convenience only and WGBH makes no representation or warranty and bears no responsibility for accuracy or content of any externally linked site. Your use of such sites is at your sole risk.\u003c/p\u003e\n","transcript_edit.md":"\u003ch2\u003eInstructions\u003c/h2\u003e\n\n\u003cp\u003eThe following transcript was automatically generated using speech-to-text software, so there are probably errors. This tool will allow you to listen while you edit the transcript. For your convenience (we hope), the audio will automatically pause after each line.\u003c/p\u003e\n\n\u003cp\u003eUse the keyboard shortcuts or buttons in the toolbar below to navigate the transcript and audio. \u003cspan class=\"highlight\"\u003eAll your edits will be automatically saved\u003c/span\u003e but may not be immediately visible by others. Once enough people agree on the text of a particular line, that line will be visible to all and no longer editable.\u003c/p\u003e\n\n\u003cp\u003e\u003c% if (transcript.hasLinesInReview) { %\u003e\nThe transcript contains lines that are \u0026quot;in review\u0026quot; (\u003cspan class=\"reviewing\"\u003ehighlighted in orange\u003c/span\u003e) which means you cannot edit it, but can select the best transcription from a list of submitted edits.\n\u003c% } %\u003e\n\u003c% if (transcript.hasLinesCompleted) { %\u003e\nThe transcript \u003c% if (transcript.hasLinesInReview) { %\u003ealso \u003c% } %\u003econtains lines that are \u0026quot;completed\u0026quot; (\u003cspan class=\"completed\"\u003ehighlighted in green\u003c/span\u003e) which means they have been corrected by others and can no longer be edited, but you can still listen to them.\n\u003c% } %\u003e\u003c/p\u003e\n\n\u003cp class=\"text-center\"\u003e\u003ca href=\"#tutorial\" data-modal=\"tutorial_edit\" class=\"button large modal-invoke tutorial-link\" role=\"button\"\u003eView A Tutorial\u003c/a\u003e \u003cspan class=\"separator\"\u003e- or -\u003c/span\u003e \u003ca href=\"#start\" class=\"button large start-play disabled\" role=\"button\"\u003eGet Started\u003c/a\u003e\u003c/p\u003e\n","transcription_conventions.md":"\u003ctable class=\"table-conventions\"\u003e\n  \u003cthead\u003e\n    \u003ctr\u003e\n      \u003cth colspan=\"2\"\u003eTranscription Conventions\u003c/th\u003e\n      \u003cth\u003eExamples\u003c/th\u003e\n    \u003c/tr\u003e\n  \u003c/thead\u003e\n  \u003ctbody\u003e\n    \u003ctr\u003e\n      \u003ctd\u003eGeneral Guidelines\u003c/td\u003e\n      \u003ctd\u003eTranscripts are searched for specific and complete keywords. Focus on transcribing the substance of the conversation rather than speech inflections such as 'um' or partial words.\u003c/td\u003e\n      \u003ctd\u003e\u003c/td\u003e\n    \u003c/tr\u003e\n    \u003ctr\u003e\n      \u003ctd\u003eFilled Pauses \u0026amp; Hesitations\u003c/td\u003e\n      \u003ctd\u003eOmit adding\u003c/td\u003e\n      \u003ctd\u003e“ah”, “eh”, “um”\u003c/td\u003e\n    \u003c/tr\u003e\n    \u003ctr\u003e\n      \u003ctd\u003eNoise\u003c/td\u003e\n      \u003ctd\u003eTranscribe in brackets; use descriptive language\u003c/td\u003e\n      \u003ctd\u003e[Intro music], “And then we [door slam]”, “So cold! [Brrrrr]”\u003c/td\u003e\n    \u003c/tr\u003e\n    \u003ctr\u003e\n      \u003ctd\u003eHard-to-understand\u003c/td\u003e\n      \u003ctd\u003eFor speech that is difficult or impossible to understand, use brackets before and after\u003c/td\u003e\n      \u003ctd\u003e“And she told me that [inaudible] should just leave?”\u003c/td\u003e\n    \u003c/tr\u003e\n    \u003ctr\u003e\n      \u003ctd\u003eNames\u003c/td\u003e\n      \u003ctd\u003eFor names that are difficult to transcribe, use quotation marks before and after\u003c/td\u003e\n      \u003ctd\u003e\"Christina ?Mimis?\"\u003c/td\u003e\n    \u003c/tr\u003e\n    \u003ctr\u003e\n      \u003ctd\u003ePartial words\u003c/td\u003e\n      \u003ctd\u003eIf someone stops speaking in the middle of a word, transcribe the completed word\u003c/td\u003e\n      \u003ctd\u003e“Tes- Testing”, “Absolu- Absolutely”\u003c/td\u003e\n    \u003c/tr\u003e\n  \u003c/tbody\u003e\n\u003c/table\u003e\n"}};