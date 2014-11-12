through2       = require 'through2'
gulp           = require 'gulp'
bowerRequireJS = require 'bower-requirejs'

q = require 'q'

module.exports = (globalConfig) ->
  {args, util, tasks, fileRecipes, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util

  {assets, env, dir, pkg, helpers} = project = getProject()
  {files, mainFile, vendorFiles, compiledFiles,  banner, dest, time, $} = helpers

  # bowerRequire =
  #   config: "#{env.configBase}/#{dir.compile}/main.js"
  #   transitive: true

  ### ---------------- TASKS ---------------------------------------------- ###
  fileRecipes.vendor = ->
    files 'vendor', '*'
      .pipe $.if args.verbose, $.using()
      .pipe $.size title: 'vendor'
      .pipe gulp.dest "#{dir.compile}/components/vendor"

  tasks.add 'compile:vendor', fileRecipes.vendor
