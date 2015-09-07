var bower = require('bower');
var concat = require('gulp-concat');
var gulp = require('gulp');
var gutil = require('gulp-util');
var rename = require('gulp-rename');
var runSequence = require('run-sequence');
var sass = require('gulp-sass');
var sh = require('shelljs');
var shell = require('gulp-shell');
var wait = require('gulp-wait');


var paths = {};

gulp.task('update', function () {
    runSequence('clean-src', 'copy-ios', 'copy-android', 'copy-android-activities','copy-android-util');
});

gulp.task('clean-src', function () {
    return gulp
        .src('')
        .pipe(shell([
            'rm -rf src/ios/* src/android/*'
        ]))
});

gulp.task('copy-ios', function(){
    return gulp.src('./ionic/platforms/ios/CustomCamera/Plugins/com.jobnimbus.customcamera/*').pipe(gulp.dest('./src/ios/'))
});

gulp.task('copy-android', function(){
    return gulp.src('./ionic/platforms/android/src/com/jobnimbus/customCamera/*').pipe(gulp.dest('./src/android/'))
});

gulp.task('copy-android-util', function(){
    return gulp.src('./ionic/platforms/android/src/com/jobnimbus/customCamera/util/*').pipe(gulp.dest('./src/android/util/'))
});

gulp.task('copy-android-activities', function(){
    return gulp.src('./ionic/platforms/android/res/layout/*').pipe(gulp.dest('./src/android/'))
});

