# Open Transcript Editor

**Notice: The original source of this codebase is relatively stable but doesn't seem to be in active development. This forked version has been customized for the needs of the WGBH Media Library and Archives and the README will document our specific processes for getting the editor up and running.**

**Notice: Pop Up Archive (PUA) shut down operations and ended support on 11/28/17. This README has removed all references to PUA as that functionality will no longer function. If needed please visit the [original repo](https://github.com/NYPL/transcript-editor).**

This is an open-source, self-hosted, web-based tool for correcting transcripts that were automatically generated using speech-to-text software. It was developed by [NYPL Labs](http://www.nypl.org/collections/labs) in partnership with [The Moth](http://themoth.org/) and [Pop Up Archive](https://popuparchive.com/) with generous support from the [Knight Foundation](http://www.knightfoundation.org/grants/201551666/).

## TOC

1. [Setting up the editor](#setting-up-the-editor)
2. [Importing your transcripts](#importing-your-transcripts)
3. [Customizing your project](#customizing-your-project)
5. [Transcript Consensus](#transcript-consensus)
6. [Deploying your project](#deploying-your-project-to-production)
7. [Managing your project](#managing-your-project)
8. [Retrieving your finished transcripts](#retrieving-your-finished-transcripts)
9. [Export UIDs by project](#export-uids-by-project)
10. [Contributing](#developers)
11. [License](#license)
12. [Attribution](#attribution)

## Setting up the editor

### Requirements

You will need to have the following installed to run this project on your machine.

- [Git](https://git-scm.com/)
- [Ruby](https://www.ruby-lang.org/en/) - this app has been developed using 2.3.0. Older versions may not work
- [PostgreSQL](http://www.postgresql.org/)

Once everything is installed, clone this repository

```
cd /my/projects/folder
git clone https://github.com/WGBH/transcript-editor.git
cd transcript-editor
```

If you forked this repository, replace the URL with your repository

### Configure Your Project

1. Create `config/database.yml` based on [config/database.sample.yml](config/database.sample.yml) - update this file with your own database credentials
2. Create `config/application.yml` based on [config/application.sample.yml](config/application.sample.yml) - this file contains all your private config credentials such as Pop Up Archive or Google accounts. The only required configuration to start is:
  - **SECRET_KEY_BASE**. You can generate this value by running `rake secret`
  - **PROJECT_ID**. A project id that will be used to identify this project (e.g. my-project). Must be alphanumeric; no spaces or periods; underscores and dashes okay
3. Copy the folder `project/sample-project` and rename it to the **PROJECT_ID** from the previous step (e.g. `project/my-project`).  This folder will contain all the configuration, content, and language for your project.

#### Configure Your Project Details

Your project folder has the following structure:

```
 my-project/
 +-- assets/
 |  +-- css/
 |  +-- img/
 |  +-- js/
 +-- data/
 +-- layouts/
 +-- pages/
 +-- transcripts/
 +-- project.json
 ```

The primary place for project configuration the file `project.json`. For now, we can keep everything as defaults. We will cover the details of this folder in later steps.

### Setup and run the app

1. Run `bundle` - this will install all the necessary gems for this app
2. Run `rake db:setup` to setup the database based on `config/database.yml`
3. Run `rake db:seed` to populate the database with needed fictures and to populate the test database for Minitest suite.
4. Run `rake project:load['my-project']` to load your project folder (replace *my-project* with your project name)
5. Run `rails s` to start your server. Go to [http://localhost:3000/](http://localhost:3000/) to view your project

Your project should load, but since there's no transcripts, all you'll see is a header and blank screen! The next step is to seed the app with some data.

## Importing your transcripts

This section will assume you are using the [American Archive of Public Broadcasting](https://github.com/WGBH/AAPB2) as the data source for importing transcripts.

All of the rake tasks in "Creating a manifest file", "Downloading transcripts", "Converting transcripts", and "Importing transcripts" have been wrapped in to a single process for WGBH AAPB transcripts.

**If you are importing AAPB transcripts in to a project, you can run one rake task:**

```
bundle exec rake aapb:ingest_guids['/path/to/file.txt','my-project']
```

This task will create a manifest file for AAPB records, download, convert, and import the transcripts.

### Creating your Collections

The Collections for the transcript editor need to be created prior to uploading any transcripts or additional data.

In your project folder, you should find an empty .csv file: [project/my-project/data/collections_seeds.csv](project/sample-project/data/collections_seeds.csv).

Create a manifest file where the uid matches the

```
<pbcoreAnnotation annotationType="organization">
```

from the AAPB PBCore. Title is WGBH's only other required field. Load them into the app with this command:

```
rake collections:load['my-project','collections_seeds.csv']
```

Replace `my-project` with your project id and `collections_seeds.csv` with your file's name.

You can always re-run this script with new data and manifest files.

### Creating a manifest file

New audio files and transcripts can be added to this app by creating manifest files in .csv format. These manifest files will contain basic information about your audio, e.g. an internal id, title, description, url to audio file, etc. These files will be used to perform a number of tasks such as uploading new audio for transcription, download processed transcripts, and updating information about your audio.

In your project folder, you should find an empty .csv file: [project/my-project/data/transcripts_seeds.csv](project/sample-project/data/transcripts_seeds.csv). It contains the following columns:

| Column | Description | Required? | Example |
| ------ | ----------- | --------- | ------- |
| uid | a unique identifier for your audio file. Must be alphanumeric; no spaces or periods; underscores and dashes okay. Case sensitive. | Yes | *podcast-123*, *podcast_123*, *123* |
| title | the title that will be displayed for this audio file | Yes | *Podcast About Cats* |
| description | a description that will be displayed for this audio file | No | *This is basically teh best podcast about cats; no dogs allowed* |
| url | a URL that will link back to where the audio is being presented on your website | No | *http://mywebsite.com/podcast-123* |
| audio_url | a public URL to your audio file | Yes, unless you already uploaded audio to Pop Up Archive or already have transcripts | *http://mywebsite.com/podcast-123.mp3* |
| image_url | a public URL to an image representing your audio; square and ~400px is preferred | No | *http://mywebsite.com/podcast-123.jpg* |
| collection | the unique identifier for the collection this audio belongs to (see below for more on this) | No | *cat-collection* |
| vendor | the vendor that will be doing the transcription | Yes, unless you already produced transcripts yourself | *pop_up_archive* |
| vendor_identifier | if already uploaded the audio to Pop Up Archive, put the item id here | Only if you already uploaded audio to Pop Up Archive | *41326* |
| notes | any extra notes that will only be used internally (not public) | No | *this audio contains explicit material* |

Lucky for you, we've got a process to handle all this. The first thing you'll need is a text file of AAPB GUIDs.

Then you can create the manifest file using this command:

```
rake aapb:create_seeds['ids_file_path','my-project']
```

Replace `ids_file_path` with the path to your text file of AAPB GUIDs and `my-project` with your project id. This process creates a csv file in the project's data directory named today's date. The data scraped from .pbcore view of the AAPB web application.

After the file is created, you can load them into the app with this command:

```
rake transcripts:load['my-project','transcripts_seeds.csv']
```

Replace `my-project` with your project id and `transcripts_seeds.csv` with your newly created file's name. You can run this command any number of times after editing the manifest file or with new manifest files. The script will check if the transcript already exists using the `uid` column value.

### Downloading transcripts

Most of our transcripts are phrase level JSON stored in an online object store, so we've created an AAPB transcript downloader. Again you'll need a text file of AAPB GUIDS to run the rake take.

Download the transcripts using this command:

```
rake aapb:download_transcripts['ids_file_path','my-project']
```

Replace `ids_file_path` with the path to your text file and 'my-project' with your project id. This process will: create an `aapb` directory in the project's transcripts' directory if one does not already exist, use the GUID to look for a transcript in the online object store and download it to the 'aapb' directory.

### Converting transcripts

The original transcript-editor was written to support the [WebVTT](https://w3c.github.io/webvtt/) format, a W3C standard for displaying timed text in connection with the HTML5 `<track>` element. This format is extended from the popular [SRT](https://en.wikipedia.org/wiki/SubRip) format.

Since the AAPB transcripts are phrase level JSON we wrote a transcript converter so that they'd play function within the current infrastructure.

Run this task to convert AAPB's phrase level JSON transcripts to WebVTT for the transcript-editor:

```
rake transcripts:convert['transcript_files_path', 'directory' , 'to_format']
```

Replace `transcript_files_path` with the path to a directory containing all the transcripts that you'd like to convert, `directory` with the path of the directory to which you'd like the converted transcripts saved, and `to_format` with the file format to which you'd like the transcripts converted. In our process this would simply be `vtt`.

The converter classes were purposefully written to be fairly easily extended, but right now it only has a reader for AAPB JSON and a converter for WebVTT. But new readers and writers can be plugged in the same process. Any new reader should return a hash in the following format:

```
{ "file_name" => "file_name",
  "parts" => [
    { text: "transcript phrase",
      start_time: "start time of phrase in hundreths of a second", end_time: "end time of phrase in hundreths of a second"
    }...
  ]
}
```

And any new converters should be written to process this same format.

### Importing transcripts

1. Place all your `.vtt` files in folder `/project/my-project/transcripts/webvtt/`
2. Create a manifest file
   - Refer to [this section](#creating-a-manifest-file) to setup a manifest file
   - In the `vendor` column, enter `webvtt` for each transcript
   - In the `vendor_identifier` column, enter the name of the `.vtt` file, e.g. `transcript_1234.vtt`
   - If you have not already, run the `rake transcripts:load['my-project','the_manifest_file.csv']` task on your manifest file to create entries for your transcripts
3. Finally, run `rake webvtt:read['my-project']` which will import all the `.vtt` files that have not already been processed

## Deleting transcripts

To make it easier to mass delete AAPB transcripts that have been erroneously uploaded, we created a rake task to remove a list of AAPB GUIDS in a text file.

```
bundle exec rake aapb:delete_guids['/path/to/file.txt']
```

## Customizing your project

All project customization should happen within your project directory (e.g. `/project/my-project/`). Changes made anywhere else may result in code conflicts when updating your app with new code.

Whenever you make a change to your project directory, you must run the following rake task to see it in the app:

```
rake project:load['my-project']
```

### Activating user accounts

This app currently supports logging in through Google or Facebook accounts (via [OAuth2](https://en.wikipedia.org/wiki/OAuth)).  You can activate this by the following:

#### Instructions for Google Account activation

1. Log in to your Google account and visit [https://console.developers.google.com/](https://console.developers.google.com/); complete any registration steps required
2. Once you are logged into your Developer dashboard, [create a project](https://console.developers.google.com/project)
3. In your project's dashboard click *enable and manage Google APIs*.  You must enable at least *Contacts API* and *Google+ API*
4. Click the *Credentials* tab of your project dashboard, *Create credentials* for an *OAuth client ID* and select *Web application*
5. You should make at least two credentials for your Development and Production environments (you can also create one for a Test environment)
6. For development, enter `http://localhost:3000` (or whatever your development URI is) for your *Authorized Javascript origins* and `http://localhost:3000/omniauth/google_oauth2/callback` for your *Authorized redirect URIs*
7. For production, enter the same values, but replace `http://localhost:3000` with your production URI e.g. `https://myproject.com`
8. Open up your `config/application.yml`
9. For each development and production, copy the values listed for *Client ID* and *Client secret* into the appropriate key-value entry, e.g.

```
development:
 GOOGLE_CLIENT_ID: 1234567890-abcdefghijklmnop.apps.googleusercontent.com
 GOOGLE_CLIENT_SECRET: aAbBcCdDeEfFgGhHiIjKlLmM
production:
 GOOGLE_CLIENT_ID: 0987654321-ghijklmnopabcdef.apps.googleusercontent.com
 GOOGLE_CLIENT_SECRET: gGhHiIjKlLmMaAbBcCdDeEfF
```

10. Google login is now enabled in the Rails app. Now we need to enable it in the UI. Open up `project/my-project/project.json`.  Under `auth_providers` enter:

```
 "authProviders": [
   {
     "name": "google",
     "label": "Google",
     "path": "/auth/google_oauth2"
   }
 ],
```

11. Run `rake project:load['my-project']` to refresh this config in the interface
12. Finally, restart your server and visit `http://localhost:3000`.  Now you should see the option to sign in via Google.

### Adding speakers

**Notice: Speaker functionality is not being used in our instance, but retaining documentation for potential future use.**

Sometimes your audio will contain multiple speakers. If you already know who are speaking, you can seed your transcripts with the speakers. Your users could then choose which speaker is speaking on any given line.

In your project folder, you should find an empty .csv file: [project/my-project/data/speakers_seeds.csv](project/sample-project/data/speakers_seeds.csv). It contains just two columns: *transcript_uid* and *name*. Simply create one speaker per line, where *transcript_uid* is the transcript's uid and *name* is the name of the speaker.

Once you fill out the speakers this file, you can load them into the app with this command:

```
rake speakers:load['my-project','speakers_seeds.csv']
```

### Custom content

#### Pages

This app let's you create an arbitrary number of pages that you may link from the navigation menu or within other pages.  All pages are found within:

```
project/
+-- my-project/
|  +-- pages/
```

- All pages are written in [Markdown](https://daringfireball.net/projects/markdown/syntax), but since Markdown supports HTML, you can use HTML syntax as well.
- If you create a page called `faq.md`, you can access it via URL `http://localhost:3000/page/faq`
- Subdirectories are supported, but the URL will always respond to just the filename, e.g. for the file `project/my-project/pages/misc/faq.md`, the URL will still be `http://localhost:3000/page/faq`
- You can embed assets in your markdown. For example
  - Place an image in assets folder like `project/my-project/assets/img/graphic.jpg`
  - You can refer to it in a page like this: `<img src="/my-project/assets/img/graphic.jpg" />`
- There are a few pages that the app comes with:
  - `home.md` - contains the content that shows up on the homepage
  - `transcript_edit.md` - contains the content that shows up on the top of all transcript editor pages
  - `transcript_conventions.md` - contains the transcript conventions that show up in the drop-down on all transcript editor pages

#### Menus

In your `project/my-project/project.json` file, there is an entry called `menus`.  These will contain all the available menus that will be displayed in the app.  Here are the available menus:

- `header` - this is the persistent menu that shows up on the top of all pages
- `transcript_edit` - this is the menu that shows up below the main header menu if you are on a transcript editor page
- `footer` - this is the persistent menu that shows up on the bottom of all pages

Each menu will contain a number of entries (or no entries). It may look like this:

```
"header": [
  {"label": "Browse", "url": "/"},
  {"label": "About", "url": "/page/about"},
  {"label": "Main Website", "url": "http://otherwebsite.com/"}
],
```

The `label` is what will show up in the menu, and the URL is what that label links to. It can link to a page within the app or an external page.

Sometimes you only want to have a link show up on certain pages. You can accomplish this like so:

```
"header": [
  {"label": "Browse", "url": "/"},
  {"label": "About", "url": "/page/about"},
  {"label": "Help", "url": "/page/help", "validRoutes": ["transcripts/:id"]}
],
```

In the above case, the `Help` link will only show up on transcript editor pages. You can see a list of available routes in the app's [router.js file](gulp/js/router.js)

#### Modals

Sometimes you don't want to redirect a user to a different page, but want to have the content show up in a pop-up modal. You can define modals in your `project.json` file like this:

```
"modals": {
  "help_modal": {
    "title": "A Brief Guide",
    "doneLabel": "Close",
    "page": {"file": "help.md"}
  },
  "tutorial_modal": {
    "title": "A Brief Tutorial",
    "doneLabel": "Finished",
    "pages": [
      {"label": "Editing", "file": "tutorial_1.md"},
      {"label": "Conventions", "file": "tutorial_2.md"},
      {"label": "Commands", "file": "tutorial_3.md"}
    ]
  }
},
```

This will create two modals:

1. `help_modal` which contains the content of just one page: `project/my-project/pages/help.md`
2. `tutorial_modal` which contains tabbed content of three pages

You can invoke a modal from within a menu like so:

```
"menus": {
  "header": [
    {"label": "Browse", "url": "/"},
    {"label": "About", "url": "/page/about"},
    {"label": "Help", "modal": "help_modal"}
  ],
  ...
},
```

### Custom assets, styling, and functionality

You would probably want to customize the look and feel of your app. You can accomplish this by overriding the default CSS styling with a project CSS file:

```
project/
+-- my-project/
|  +-- assets/
|     +-- css/
|        +-- styles.css
```

These styles will override any existing styles in the app. Similarly, you can add additional javascript functionality via custom js:

```
project/
+-- my-project/
|  +-- assets/
|     +-- js/
|        +-- custom.js
```

Sometimes you may want to include additional files or tags in your app such as custom external font services, analytics, or meta tags. You can simply edit this page:

```
project/
+-- my-project/
|  +-- layouts/
|     +-- index.html
```

Be careful not to edit the existing app structure within the `#app` element. Also, there are a few javascript and css files that the app depends on that you shouldn't delete.

Be sure to run the project rake task if you make any changes:

```
rake project:load['my-project']
```

## Transcript Consensus

Even though this app could be used by just one individual, this app was designed to allow multiple users to correct the same transcript simultaneously. The goal is to improve quality by having many users look at each line of text. This app contains a configurable "consensus" algorithm that looks for where users agree and disagree, and makes an informed decision about which submission is best.

### How does consensus work?

Consensus is essentially when a certain threshold of users agree that a certain line of a transcript contains the correct text. This is a bit more complicated than it seems. Consider the following three lines of text submitted by three separate users:

1. "Hi, my name is Jane Doe."
2. "hi my name is Jane Doe"
3. "Hi, my name is Jane Do."

Let's assume we need more than 50% of users to agree on a particular line of text--in this case, **we need 2 of the 3 users to agree**. The first two lines essentially say the same thing, but the first line contains capitalization and punctuation. The first thing the consensus algorithm does is "normalize" the text by removing punctuation and making everything the same case (it also removes extra whitespace and removes hesitations like "uhh" and "ummm").  So then the submissions will look like this:

1. "hi my name is jane doe"
2. "hi my name is jane doe"
3. "hi my name is jane do"

So based on our requirement for at least 2 of 3 users to agree, it looks like the first 2 users agree and we have reached consensus. Now we have to choose which submission is "better" out of the 2:

1. "Hi, my name is Jane Doe."
2. "hi my name is Jane Doe"

Even though this can get rather subjective in some cases, the algorithm favors the following:

- line contains capitalization
- line contains punctuation
- line contains numbers (since the default convention is to transcribe a number and numerals, e.g. "3" not three)
- line is submitted by a registered user
- line contains hesitations (since the default convention is to transcribe as you hear it, e.g. uhh, umm)

Therefore, between our 2 options, the chosen text will be **"Hi, my name is Jane Doe."**.  This line now has reached consensus and is now considered "complete."

### Settling conflicts

The previous example demonstrates the ideal case where a line automatically reaches consensus. But there will be many cases where users simply don't agree and arbitration will be required. Since this app is built for large audio collections where the project creator may not have the resources to manually settle disputes, arbitration is built into the app itself.

The project creator can set a limit to how many submissions are allowed for a particular line. Let's say that number is **5** and the submissions are as follows:

1. "Hi, my name is John Hardtospell."
2. "hi my name is John hearttospell"
3. "Hi, my name is John Harttospell."
4. "Hi, my name is John Hard2spell."
5. "hi my name is John Hardtospel"

Since this line reached 5 submissions but did not reach consensus (like in the previous example), it will go into **"review mode"**. When this happens, **users can no longer submit new transcriptions** but must choose the best among the 5 existing choices/submissions.

Let's say that a 6th user chooses option 1; their "vote" counts as another submission with that options's text. So let's say more users vote as follows:

1. "Hi, my name is John Hardtospell." (+5 votes)
2. "hi my name is John hearttospell"
3. "Hi, my name is John Harttospell." (+1 vote)
4. "Hi, my name is John Hard2spell."
5. "hi my name is John Hardtospel"

If we still have the same consensus rules as before (50% must agree), **option 1** will be chosen as the correct text since it has 6 of the 11 total submissions.

### The stages of consensus

There are generally 4 stages a line of text can possibly go through:

1. **Initialized**: this contains the original text that the speech-to-text software created
2. **Edited**: the line has received submissions, but not enough to reach consensus
3. **In Review**: the line has reached enough submissions for consensus, but not enough users agree to reach consensus, so it must be [reviewed by others](#settling-conflicts)
4. **Complete**: the line has reached consensus and is no longer editable.

Similarly, an entire transcript has similar stages, but is generally just an aggregate of the lines that it is made up of. So a transcript is only **Complete** when all of its lines are **Complete**.

### Configuring consensus

All of a project's consensus rules are defined in the `project.json` file like so:

```
"consensus": {
  "maxLineEdits": 5,
  "minLinesForConsensus": 3,
  "minPercentConsensus": 0.34,
  "minLinesForConsensusNoEdits": 5,
  "lineDisplayMethod": "original"
},
...
```

Here are what each property means:

- **maxLineEdits** - This is the maximum number of submissions for a particular line. If a line did not reach consensus when it reaches this number, it will go into [review mode](#settling-conflicts). Since the line will be locked to new submissions after this number is reached, the number should be reasonably high enough so least one of the submissions is probably correct.
- **minLinesForConsensus** - The minimum number of submissions required for a line to reach consensus. If you are expecting a lot of spam, you can increase this number. If you are using this tool internally and/or you trust all users of this tool, you can set this number to **1**, meaning a single user's submission is final.
- **minPercentConsensus** - The threshold for determining if a line reached consensus. For example, if this number is **0.5**, at least 50% of users must agree in order for a line to reach consensus.
- **minLinesForConsensusNoEdits** - Sometimes users submit a line with no edits, i.e. presses enter on a line that contains the original computer text. This may be intended or not: the original text may be correct or the user may just be navigating away from the line. In order to reduce false positives, this property allows you to configure how many "no-edit" submissions are required for it to be considered for consensus. For example, if the number is **5**, at least 5 people must say that the original computer text was correct before it is considered for consensus. Submissions that contain edits are always preferred over no-edit submissions.
- **lineDisplayMethod** - This can either be **original** or **guess**.  If this property is **original**, the user will see the original computer text when they are editing a line that is not locked. If this property is **guess**, the user will see what the app thinks is the "best guess" thus far based on the existing submissions. The advantage of showing the **original** is that all submissions are made independently since they do not see other users' submissions. It also ensures spam submissions are not seen by others. The advantage of **guess** is that consensus is more likely to be reached quicker since users are essentially looking at user submissions which would likely be more quality that the computer transcriptions.

Be sure to run the project rake task if you make any changes:

```
rake project:load['my-project']
```

If you edit the consensus rules *after* you have received edits, you can retroactively apply the new rules to the existing edits with the following tasks:

```
rake transcript_lines:recalculate
rake transcripts:recalculate
```

## Deploying your project to production

### WGBH

The full release script is currently saved in the WGBH MLA wiki in the MLA Staff Pages section. The document is called "NYPL Transcript Editor Deployment."

Broad overview steps are:

1. Provision a server on AWS.
2. Run the [MLA Playbook for transcript-editor](https://github.com/WGBH/mla-playbooks)
3. Install and set up Postgres 9.6.
4. Run the [transcript-editor_deploy] Capistrano deployment](https://github.com/WGBH/transcript-editor_deploy)
5. Intall and run Gulp.

### Heroku

**Notice: We are not deploying our code with Heroku, but keeping this section for potential future use.**

This example will use [Heroku](https://www.heroku.com/) to deploy the app to production, though the process would be similar for other hosting solutions. The commands assume you have [Heroku Toolbelt](https://toolbelt.heroku.com/) installed.

Before you start, if you used Pop Up Archive to generate your transcripts, make sure your manifest files are up-to-date to make sure your production server knows how to download the transcripts from Pop Up Archive.  Run these commands:

```
rake collections:update_file['my-project,'collections_seeds.csv']
rake transcripts:update_file['my-project','transcripts_seeds.csv']
```

Replace `my-project` and `.csv` files with your project key and manifest files. Commit the updated manifest files to your repository and continue.

1. Create a new [Heroku](https://heroku.com) app:

   ```
   heroku apps:create my-app-name
   heroku git:remote -a my-app-name
   ```

   (Only run the 2nd command if you already have an app setup)

2. Provision a PostgreSQL database:

   ```
   heroku addons:create heroku-postgresql:hobby-dev
   heroku pg:wait
   heroku config -s | grep HEROKU_POSTGRESQL
   ```

   Replace `hobby-dev` with your [database plan of choice](https://devcenter.heroku.com/articles/heroku-postgres-plans). This example uses the free "Hobby Dev" plan. Note that you should choose a higher plan (e.g. `standard-0`) for production; Hobby Dev has a row limit of 10,000 and a maximum of 20 connections. You can always [upgrade](https://devcenter.heroku.com/articles/upgrading-heroku-postgres-databases) an existing database.

3. Update your environment variables

   ```
   figaro heroku:set -e production
   ```

   This sets environment variables from `config/application.yml` in your production environment

4. Deploy the code and run rake tasks

   ```
   git push heroku master
   heroku run rake db:migrate
   heroku run rake db:seed
   ```

5. Next you'll need to populate your transcripts. The last command will download your transcripts from Pop Up Archive. You can run these commands however many times you like if you update your manifest file or transcripts become available.

   ```
   heroku run rake collections:load['my-project','collections_seeds.csv']
   heroku run rake transcripts:load['my-project','transcripts_seeds.csv']
   heroku run rake pua:download['my-project']
   ```

## Managing your project

This tool has the concept of "user roles", though currently only supports three types of users:

1. **Guests** - These are anonymous users that did not register. They can make contributions to transcripts, but they will not be able to track their progress between sessions. Their contributions also weigh slightly less than registered users during consensus calculations.
2. **Registered Users** - These are the same as guests, but they are able to track their editing progress between any session or computer if they are signed in. They do this by [signing in via Google or Facebook](#activating-user-accounts). Their contributions weigh slightly more than anonymous users during consensus calculations.
3. **Admins** - These are users that are explicitly configured to be administrators of the tool. Their privileges/capabilities include:
  - All their edits are considered "complete" and do not have to go through the usual process of consensus.
  - They can edit lines that have status "completed"
  - They can resolve flags. If a user thinks that a line that is completed/locked still contains errors, they can flag it with a type (misspelling, repeated word, missing word, etc) and comment.
  - They have access to the admin dashboard. This gives them basic statistics about overall edits, user registrations, top users, and flags.

### Configuring Admins

You can add admins by editing your `project.json` file like so:

```
"adminEmails": [
  "janedoe@myorg.org",
  "johndoe@myorg.org",
  ...
],
...
```

Make sure these email addresses correspond to the email addresses that the user signs in with (i.e. Google or Facebook.) When the user signs in using this email address, they will be able to access their dashboard by clicking the drop-down menu on the top right side of the app.

## Export UIDs by project

Sometimes you just need all the transcript UIDs for a project, so we built a rake task for that: `rake transcripts:export_uids['my-project']`.

## Retrieving your finished transcripts

Each transcript will be available to download in three formats: plain text, captions ([WebVTT](https://w3c.github.io/webvtt/) - based on SRT), and JSON. These are available at any stage of the transcription process regardless of how "complete" it is. They are available via the UI by clicking "Download this transcript." Users can choose whether they want to include speakers, timestamps, or raw edits depending on which format they choose.

### Enabling/Disabling transcript downloads

You can enable/disable transcript downloads by setting `allowTranscriptDownload` to `true` or `false` in your `project.json` file like so:

```
"allowTranscriptDownload": true,
...
```

You can also enable/disable individual transcript downloads by setting `can_download` to `1` or `0` in the `transcripts` table in the database.

### Downloading transcripts in bulk

The app has an endpoint that enables programmatic access to transcripts:

`GET /transcript_files.json?updated_after=yyyy-mm-dd&page=1`

This will get all the transcript files that were updated after a certain date. This is useful if you want to periodically update transcripts that you display on another website.

## Developers

Coming soon... this section will walk through how the codebase is organized and how you can contribute to this codebase.

## License

See [LICENSE](LICENSE).

## Attribution

Though it’s not required, if you would like to credit us as the source we recommend using the following statement and links:
>Powered by the [Open Transcript Editor](https://github.com/NYPL/transcript-editor/) created by [The New York Public Library](nypl.org) with generous support from the [Knight Prototype Fund](http://www.knightfoundation.org/grants/201551666/).
