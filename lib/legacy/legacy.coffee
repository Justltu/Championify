###
NOTES: This is the legacy version of Championify that runs in a terminal.
This has been recreated in order to support older systems and to make it easier to automate
item set updating until the feature is supported on it's own.
This uses the same code on the UI version and doesn't require maintenance unless there's a major change in
Championify.coffee
###

GLOBAL.championify_legacy = true
async = require 'async'
fs = require 'fs'
prompt = require 'prompt'
mkdirp = require 'mkdirp'
moment = require 'moment'
path = require 'path'
open = require 'open'
glob = require 'glob'

championify = require './championify'
hlp = require './helpers'

###*
 * Pretty Console Log
 * @param {String} - Text
 * @param {String} - Color
###
cl = (text, color) ->
  color = color or 'white'
  m = moment().format('HH:mm:ss')
  m = ('['+m+']').bold.cyan + " | "
  if process.platform == 'darwin' and color == 'white'  # GG crappy OSX default white terminal.
    m = m + text
  else
    m = m + (text).bold[color]
  console.log(m)


###*
 * Gives the user a chance to read the output before closing the window.
 ###
enterToExit = ->
  cl 'Press enter to close.'
  prompt.start()
  prompt.get ['enter'], ->
    process.exit(1)

###*
 * Function Check version of Github package.json and local.
 * @callback {Function} Callback.
###
checkVer = (step) ->
  championify.checkVer (needUpdate) ->
    if !needUpdate
      cl 'Your version of Championify is up to date!', 'green'
      return step null
    else
      cl 'This seems to be an old version, let me open the download page for you to get an update!', 'yellow'
      cl "If a new window doesn't open for you, get the latest here.", 'yellow'
      cl "https://github.com/dustinblackman/Championify/releases/latest", 'yellow'
      open('https://github.com/dustinblackman/Championify/releases/latest')
      enterToExit()

###*
 * Get the install path of League of Legends
 * On OSX, we check if League is installed in /Applications.
 * If not we ask the user to drag their League Of Legends.app in to the terminal window and take it from there.

 * On Windows, we check if the application is being run next to lol.launcher.exe.
 * If it isn't, we check the default install path (C:/Riot Games).
 * And if not that, we ask the user to run the application again from within the install directory.
 * @callback {Function} Callback
###
getInstallPath = (step) ->
  if process.platform == 'darwin'
    if fs.existsSync('/Applications/League of Legends.app')
      GLOBAL.lolChampPath = '/Applications/League of Legends.app/Contents/LoL/Config/Champions/'
      step null

    else if fs.existsSync('~/Applications/League of Legends.app')
      GLOBAL.lolChampPath = path.resolve('~/Applications/League of Legends.app')
      step null

    else
      cl 'Please drag your League Of Legends.app in to this window and hit enter!'
      prompt.start()
      prompt.get ['lol'], (err, results) ->
        lol_path = results.lol
        lol_path = lol_path.trim()
        lol_path = lol_path.replace(/\\/g, '')
        GLOBAL.lolChampPath = path.join(lol_path, '/Contents/LoL/Config/Champions/')

        if fs.existsSync(path.join(lol_path, '/Contents/LoL/'))
          step null
        else
          cl "Whoops, that doesn't seem to be the League of Legends.app. Restart me and try again.", 'yellow'
          enterToExit()

  else
    # Same Directory / Garena Installation Check 2
    if fs.existsSync(process.cwd() + '/lol.launcher.exe') or fs.existsSync(process.cwd() + '/League of Legends.exe')
      GLOBAL.lolChampPath = path.join(process.cwd(), '/Config/Champions/')
      step null

    # Garena Installation Check 1
    else if fs.existsSync(process.cwd() + '/LoLLauncher.exe')
      glob './GameData/Apps/*/', (err, paths) ->
        lol_path = paths[0].replace('./', '/')
        GLOBAL.lolChampPath = path.join(process.cwd(), lol_path, 'Game/Config/Champions/')
        step null

    # Default Install
    else if fs.existsSync('C:/Riot Games/League Of Legends/lol.launcher.exe')
      GLOBAL.lolChampPath = 'C:/Riot Games/League Of Legends/Config/Champions/'
      step null

    else
      cl "Whoops, I can't seem to find your League folder! Copy me in to your League folder and run me again.", 'yellow'
      enterToExit()

###*
 * Consoles install path
 * @callback {function} - Callback
###
clInstallPath = (step) ->
  cl 'Using League Installation in: ' +GLOBAL.lolChampPath, 'green'
  step null

###*
 * We check if we can write to directory.
 * If no admin and is required, warn and close.
 * @callback {Function} Callback
###
isWindowsAdmin = (step) ->
  if process.platform != 'darwin'
    installPath = GLOBAL.lolChampPath.replace('/Config/Champions/', '')
    fs.writeFile installPath + '/test.txt', 'Testing Write', (err) ->
      if err or !fs.existsSync(installPath + 'test.txt')
        cl 'Whoops! You need to run me as an admin. Right click on my file and hit "Run as Administrator"', 'yellow'
        enterToExit()
      else
        fs.unlinkSync(installPath + 'test.txt')
        step null
  else
    step null

# Run
async.series [
  checkVer
  getInstallPath
  clInstallPath
  isWindowsAdmin
  championify.run
], (err) ->
  if err
    console.log(err)
  else
    cl 'Looks like were all done! Get in to game and enjoy. :)', 'green'
  enterToExit()
