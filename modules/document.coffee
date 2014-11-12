fs =              require 'fs'
open =            require 'open'
gulp =            require 'gulp'                  # streaming build system
_ =               require 'underscore'
chalk =           require 'chalk'
del =       require 'del'


module.exports = (globalConfig) ->
  {args, util, tasks, commander, assumptions, smash, user, platform, getProject} = globalConfig
  {logger, notify, execute} = util


  ### ---------------- COMMANDS ------------------------------------------- ###
  commander
    .command('docs')
    .description('Generate documentation based on source code')
    .action ->
      tasks.start 'docs'


  ### ---------------- TASKS ---------------------------------------------- ###
  tasks.add 'docs', (done) ->
    {assets, env, dir, pkg, helpers} = getProject()

    notify "Groc", "Generating documentation..."

    docsGlob = ["README.md"]
    for key, val of assets
      if val.doc
        docsGlob.push "#{dir.client}/**/*.#{val.ext}"
        docsGlob.push "#{dir.server}**.*.#{val.ext}"

    grocjson = JSON.stringify
      'glob': docsGlob
      'except': [
        "#{dir.client}/components/vendor/**/*"
      ]
      'github':           false
      'out':              dir.docs
      'repository-url':   pkg.repository?.url or ''
      'silent':           !args.verbose?

    # Dynamically generate .groc.json from config
    fs.writeFile "#{env.configBase}/.groc.json", grocjson, 'utf8', ->
      logger.info  chalk.green 'Generated .groc.json from config'

      # Use our copy of Groc to generate documentation for the project
      require("#{env.configBase}/node_modules/fe_build/node_modules/groc").CLI [], (error)->
        process.exit(1) if error
        notify "Groc", "Success!"
        open "#{dir.docs}/index.html"
        done()

  tasks.add 'docs:clean', (cb) ->
    {assets, env, dir, pkg, helpers} = getProject()
    $ = helpers.$
    del [dir.docs]
