#!/usr/bin/env coffee


Liftoff =       require 'liftoff'
argv =          require('minimist')(process.argv.slice 2)
chalk =         require 'chalk'
commander =     require 'commander'
winston =       require 'winston'
tildify =       require 'tildify'
notifier =      require 'node-notifier'
exec =          require 'exec'
rest =          require 'restler'
inquire =       require 'inquirer'
Orchestrator =  require 'orchestrator'
_ =             require 'lodash'

{logger, notify, execute} = require './util'
defaultAssets = require '../config/assets'
defaultDirs =
  client: 'client'
  server: 'server'
  compile: 'compile'
  build: 'build'
  deploy: 'deploy'
  docs: 'docs'


pkg = require '../package'

# TODO: allow other files to add config to global private object


config = {}
assets = []

###
Configure Liftoff
###

Smasher = new Liftoff
  name: 'smash'
  processTitle: 'smasher'
  moduleName: 'smasher'
  configName: 'smashfile'
  extensions: require('interpret').jsVariants

Smasher.on 'require', (name) ->
  logger.verbose 'Requiring external module', chalk.magenta(name)

Smasher.on 'requireFail', (name) ->
  logger.warn 'Failed to load external module', chalk.magenta(name)


# Use Liftoff to find and parse local project config
Smasher.launch
  cwd: argv.cwd
  configPath: argv.myappfile
  require: argv.require
  completion: argv.completion
  (env)->
    logger.verbose 'Working in directory', chalk.magenta chalk.underline tildify env.cwd
    logger.verbose 'Using Smashfile', chalk.magenta chalk.underline tildify env.configPath

    if !env.configPath
      logger.error chalk.red 'No SMASHFILE found'
      process.exit 1

    process.chdir(env.configBase)
    project = require env.configPath

    # collect asset definitions

    for asset in project.assets
      # load preconfigured assets by name
      if typeof asset is 'string'
        if defaultAssets[asset]?
          logger.verbose "Adding asset type:", chalk.magenta.bold asset
          assets[asset] = defaultAssets[asset]
        else
          logger.warn chalk.red "Asset type: \"#{asset}\" not recognized. Please provide a definition."

      # use an asset definition object specified in Smashfile
      else
        logger.verbose "Adding custom asset definition:", chalk.red.bold asset.name
        logger.verbose asset
        assets[asset.ext] = asset

    config.assets = assets
    config.args = argv
    config.tasks = new Orchestrator()
    config.pkg = pkg

    if project.dir
      config.dir = _.defaults project.dir, defaultDirs
    else
      config.dir = defaultDirs

module.exports = config