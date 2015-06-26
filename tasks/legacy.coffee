gulp = require 'gulp'
concat = require 'gulp-concat'
coffee = require 'gulp-coffee'
glob = require 'glob'
gutil = require 'gulp-util'
flatten = require 'gulp-flatten'
fs = require 'fs-extra'
async = require 'async'
spawn = require('child_process').spawn

gulp.task 'legacy:scripts', (step) ->
  gulp.src(glob.sync('./lib/**'), {base: './'})
    .pipe coffee(bare: true).on('error', gutil.log)
    .pipe flatten()
    .pipe gulp.dest('./dev')

gulp.task 'legacy:concat', ->
  gulp.src ['./dev/legacy_deps.js', './dev/championify.js']
    .pipe concat('championify.js')
    .pipe gulp.dest('./dev/')

  return gulp.src ['./dev/legacy_deps.js', './dev/helpers.js']
    .pipe concat('helpers.js')
    .pipe gulp.dest('./dev/')

gulp.task 'legacy:run', (step) ->
  ls = spawn('./node_modules/.bin/coffee', ['./dev/legacy/legacy.coffee'])
  ls.stdout.on 'data', (data) -> console.log data
  ls.stderr.on 'data', (data) -> console.log data
  ls.on 'close', (code) -> step()
