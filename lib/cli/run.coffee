Path = require '../path'

exports.description = 'Run a script'

exports.method = (script) ->
  throw new Error 'caboose run requires a script argument' if not script?
  if script.indexOf('/') is 0
    require script
  else
    Caboose.root.join(script).require()
