const {
    src,
    dest,
    parallel,
    series,
    watch
} = require('gulp');

// Load plugins

const uglify = require('gulp-uglify');
const rename = require('gulp-rename');
const sass = require('gulp-sass');
// const autoprefixer = require('gulp-autoprefixer');
const cssnano = require('gulp-cssnano');
const concat = require('gulp-concat');
const clean = require('gulp-clean');
// const imagemin = require('gulp-imagemin');
const changed = require('gulp-changed');
// for templates
const map = require('vinyl-map');
const path = require('path');
const include = require('gulp-include');
// const browsersync = require('browser-sync').create();

// Clean assets

function clear() {
    return src('./public/assets/*', {
            read: false
        })
        .pipe(clean());
}

// JS function 

function defaultjs() {
    const source = ['./gulp/js/default.js']

    return src(source)
        // .pipe(changed(source))
        .pipe(include())
        .pipe(concat('default.js'), {newLine: "\n\n"})
        // .pipe(uglify())
        .pipe(rename({
            extname: '.min.js'
        }))
        .pipe(dest('./public/assets/js/'))
}

function adminjs() {
    const source = ['./gulp/js/admin.js']

    return src(source)
        // .pipe(changed(source))
        .pipe(include())
        .pipe(concat('admin.js'), {newLine: "\n\n"})
        // .pipe(uglify())
        .pipe(rename({
            extname: '.min.js'
        }))
        .pipe(dest('./public/assets/js/'))
}

// CSS function 

function css() {
    const source = './gulp/scss/**/*.scss';

    return src(source)
        // .pipe(changed(source))
        .pipe(sass())
        .pipe(rename({
            extname: '.min.css'
        }))
        .pipe(cssnano())
        .pipe(dest('./public/assets/css/'))
}

function templates() {
  const source = './gulp/templates/**/*.ejs';

  return src(source)
      .pipe(changed(source))
       .pipe(map(function(contents, filename){
          contents = contents.toString();
          var name = 'TEMPLATES';
          filename = path.basename(filename);

          contents = 'window.'+name+'=window.'+name+' || {}; window.'+name+'["'+filename+'"] = \'' + contents.replace(/'/g, "\\'").replace(/(\r\n|\n|\r)/gm,"") + '\';'
          return contents;
      }))
      .pipe(concat('templates.js'))
      // .pipe(uglify())
      .pipe(dest('./public/assets/js/'))
}

function cacheBust() {
  var cbString = new Date().getTime()
  const source = './public/*html';

  return src(source)
      .pipe(map(function(contents, filename) {
        contents = contents.toString().replace(/v=\d+/g, function() {
            return "v=" + cbString
        })
        return contents
      }))
      .pipe(dest("./public/"))
}

// Optimize images

// function img() {
//     return src('./src/img/*')
//         .pipe(imagemin())
//         .pipe(dest('./assets/img'));
// }

// Watch files

// function watchFiles() {
//     watch('./src/scss/*', css);
//     watch('./src/js/*', js);
//     watch('./src/img/*', img);
// }

// BrowserSync

// function browserSync() {
//     browsersync.init({
//         server: {
//             baseDir: './'
//         },
//         port: 3000
//     });
// }

// Tasks to define the execution of the functions simultaneously or in series

// exports.watch = parallel(watchFiles, browserSync);
exports.default = series(clear, parallel(defaultjs, adminjs, css, templates, cacheBust));
    