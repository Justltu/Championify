_ = require 'lodash'
moment = require 'moment'
async = require 'async'

module.exports = {
  ###*
   * Function HTTP/HTTPS Request for legacy and UI.
   * @param {String} URL
   * @callback {Function} Callback
  ###
  request: (url, done) ->
    if GLOBAL.championify_legacy
      this.legacyRequest(url, done)
    else
      this.ajaxRequest(url, done)

  ###*
   * Function HTTP request with Node
   * @param {String} URL
   * @callback {Function} Callback
  ###
  legacyRequest: (url, done) ->
    url_obj = parseURL(url)
    if url_obj.protocol == 'https:'
      r = https
    else
      r = http

    r.get {
      host: url_obj.host,
      path: url_obj.path
    }, (response) ->
      body = ''
      response.on 'socket', (socket) ->
        socket.setTimeout(60)
      response.on 'error', (err) ->
        console.log err
        return done err
      response.on 'data', (d) ->
        body += d
      response.on 'end', ->
        try
          body = JSON.parse(body)
        catch e
        done null, body

  ###*
   * Function Pre setup AJAX Request.
   * @param {String} URL
   * @callback {Function} Callback
  ###
  ajaxRequest: (url, done) ->
    async.retry 3, (step) ->
      $.ajax({url: url, timeout: 10000})
        .fail (err) ->
          console.log err
          step err
        .done (body) ->
          step null, body

    , (err, results) ->
      console.log err if err
      return done(err) if err
      done null, results


  ###*
   * Function Adds % to string.
   * @param {String} Text.
   * @returns {String} Formated String.
  ###
  wins: (text) ->
    return text.toString() + '%'


  ###*
   * Function Compares version numbers. Returns 1 if left is highest, -1 if right, 0 if the same.
   * @param {String} First (Left) version number.
   * @param {String} Second (Right) version number.
   * @returns {Number}.
  ###
  versionCompare: (left, right) ->
    if typeof left + typeof right != 'stringstring'
      return false

    a = left.split('.')
    b = right.split('.')
    i = 0
    len = Math.max(a.length, b.length)

    while i < len
      if a[i] and !b[i] and parseInt(a[i]) > 0 or parseInt(a[i]) > parseInt(b[i])
        return 1
      else if b[i] and !a[i] and parseInt(b[i]) > 0 or parseInt(a[i]) < parseInt(b[i])
        return -1
      i++

    return 0


  ###*
   * Function That parses Champion.GG HTML. Kept out of Championify.coffee as it'll rarely ever change.
   * @param {Function} Cheerio.
   * @returns {Object} Object containing Champion data.
  ###
  compileGGData: ($c) ->
    data = $c('script:contains("matchupData.")').text()
    data = data.replace(/;/g, '')

    processed = {}

    query = _.template('matchupData.<%= q %> = ')
    _.each data.split('\n'), (line) ->
      _.each ['championData', 'champion'], (field) ->
        search = query({q: field})

        if _.includes(line, search)
          line = line.replace(search, '')
          processed[field] = JSON.parse(line)

    return processed


  ###*
   * Function Pretty console log, as well as updates the progress div on interface
   * @param {String} Console Message.
  ###
  cl: (text) ->
    m = moment().format('HH:mm:ss')
    m = ('['+m+'] | ') + text
    console.log(m) if window.devEnabled or GLOBAL.championify_legacy
    $('#cl-progress').prepend('<span>'+text+'</span><br />') if !GLOBAL.championify_legacy


  ###*
   * Function Updates the progress bar on the interface.
   * @param {Number} Increment progress bar.
  ###
  updateProgressBar: (incr) ->
    if !GLOBAL.championify_legacy
      this.incr = 0 if !this.incr
      this.incr += incr
      $('.progress-bar').attr('style', 'width: '+Math.floor(this.incr)+'%')
      if this.incr >= 100
        window.Championify.remote.getCurrentWindow().setProgressBar(-1)
      else
        window.Championify.remote.getCurrentWindow().setProgressBar(this.incr / 100)


  # TODO: This is a messy function. Clean it up with Lodash, possibly.
  ###*
   * Function Saves all compiled item sets to file, creating paths included.
   * @callback {Function} Callback.
  ###
  saveToFile: (champData, step) ->
    async.each _.keys(champData), (champ, next) ->
      async.each _.keys(champData[champ]), (position, nextPosition) ->
        toFileData = JSON.stringify(champData[champ][position], null, 4)

        mkdirp GLOBAL.lolChampPath+champ+'/Recommended/', (err) ->
          fileName = GLOBAL.lolChampPath+champ+'/Recommended/CGG_'+champ+'_'+position+'.json'
          fs.writeFile fileName, toFileData, (err) ->
            console.log err if err # TODO: Print this to user.
            nextPosition null

      , () ->
        next null

    , () ->
      step null

}
