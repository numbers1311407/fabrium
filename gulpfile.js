var gulp = require('gulp')
  , browserify = require('browserify')
  , source = require('vinyl-source-stream')

var libs = [
  'jquery', 
  'angular'
];


gulp.task("vendor", function () {
  var b = browserify();

  libs.forEach(function (lib) {
    b.require(lib, {expose: lib});
  });

  return b.bundle()
    .pipe(source("vendor.js"))
    .pipe(gulp.dest('app/assets/javascripts/'));
});


gulp.task("bundle", function () {
  var b = browserify({
    entries: ['./app/assets/javascripts/bundle/index.js'], 
    extensions: ['.js']
  });

  libs.forEach(function (lib) {
    b.external(lib);
  });

  return b.bundle()
    .pipe(source("bundle.js"))
    .pipe(gulp.dest('./app/assets/javascripts/'));
});


gulp.task("browserify", ["vendor", "bundle"]);


gulp.task('watch', function() {
  gulp.watch('./app/assets/javascripts/bundle/**', ['bundle']);
});
