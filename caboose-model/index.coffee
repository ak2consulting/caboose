return module.exports = global['caboose-model'] if global['caboose-model']?

module.exports = global['caboose-model'] = caboose_model =
  connection: null

  create: (name) -> new caboose_model.Builder(name)
  configure: (config) ->
    @config = config
    @
  
  'caboose-plugin': {
    install: (util, logger) ->
      util.mkdir(Caboose.path.models)
      util.create_file(
        Caboose.path.config.join('caboose-model.json'),
        JSON.stringify({host: 'localhost', port: 27017, database: Caboose.app.name}, null, 2)
      )

    initialize: ->
      if Caboose?
        require './lib/cli'
        
        Caboose.registry.register 'model', {
          get: (parsed_name) ->
            return null unless Caboose.path.models.exists_sync()
            name = parsed_name.join('_')
            try
              files = Caboose.path.models.readdir_sync()
              model_file = files.filter((f) -> f.basename is name)
              model_file = if model_file.length > 0 then model_file[0] else null
              return null unless model_file?
              return caboose_model.Compiler.compile(model_file) if model_file.extension is 'coffee'
              model_file.require()
            catch e
              console.error e.stack
        }
      
      if Caboose?.app?.config?['caboose-model']?
        caboose_model.configure Caboose.app.config['caboose-model']
  }

caboose_model.Builder = require './lib/builder'
caboose_model.Compiler = require './lib/model_compiler'
caboose_model.Connection = require './lib/connection'
caboose_model.Model = require './lib/model'
caboose_model.Query = require './lib/query'
