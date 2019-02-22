var gulp = require('gulp');

// config
var config = require('./gulp/config');

// utilities
var concat = require('gulp-concat');
var include = require('gulp-include');
var map = require('vinyl-map');
var path = require('path');
var rename = require('gulp-rename');

// Sass compilation

var sass = require('gulp-sass');

gulp.task('sass', function () {
  gulp.src(config.sass.src)
    .pipe(sass.sync().on('error', sass.logError))
    .pipe(sass(config.sass.opt))
    .pipe(gulp.dest(config.sass.dest));
});

// Javascript compilation

var uglify = require('gulp-uglify');

gulp.task('js', function() {
  gulp.src(config.include.src)
    // include non-minified version
    .pipe(include(config.include.opt).on('error', console.error.bind(console)))
    .pipe(gulp.dest(config.include.dest))
    // and the minified version
    .pipe(uglify(config.uglify.opt).on('error', console.error.bind(console)))
    .pipe(rename({ extname: '.min.js' }))
    .pipe(gulp.dest(config.uglify.dest));
});

// Templates

gulp.task('templates', function() {
  gulp.src(config.templates.src)
    .pipe(map(function(contents, filename){
      contents = contents.toString();
      var name = config.templates.variable;
      filename = path.basename(filename);

      contents = 'window.'+name+'=window.'+name+' || {}; window.'+name+'["'+filename+'"] = \'' + contents.replace(/'/g, "\\'").replace(/(\r\n|\n|\r)/gm,"") + '\';';
      return contents;
    }))
    .pipe(concat(config.templates.outputFile))
    .pipe(gulp.dest(config.templates.dest));
});

gulp.task('build', ['sass', 'js', 'templates']);

// Watchers

gulp.task('watch', function () {
  gulp.watch(config.sass.src, ['sass']);
  gulp.watch(config.uglify.src, ['js']);
  gulp.watch(config.templates.src, ['templates']);
});

gulp.task('default', ['watch', 'sass', 'js', 'templates']);
