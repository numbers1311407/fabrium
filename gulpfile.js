var gulp = require('gulp')
  , browserify = require('browserify')
  , source = require('vinyl-source-stream')

var libs = [
  'jquery', 
  'angular'
];


gulp.task("bundle:vendor", function () {
  var b = browserify();

  libs.forEach(function (lib) {
    b.require(lib, {expose: lib});
  });

  return b.bundle()
    .pipe(source("vendor.js"))
    .pipe(gulp.dest('app/assets/javascripts/bundled'));
});


gulp.task("bundle:application", function () {
  var b = browserify({
    entries: ['./app/assets/javascripts/index.js'], 
    extensions: ['.js']
  });

  libs.forEach(function (lib) {
    b.external(lib);
  });

  return b.bundle()
    .pipe(source("application.js"))
    .pipe(gulp.dest('./app/assets/javascripts/bundled'));
});


gulp.task("bundle", ["bundle:vendor", "bundle:application"]);
gulp.task("default", ["bundle"]);

gulp.task('watch', function() {
  gulp.watch([
    './app/assets/javascripts/**/*.js', 
    '!./app/assets/javascripts/bundled/*'
  ], [
    'bundle:application'
  ]);
});
