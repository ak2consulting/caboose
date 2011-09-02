objs = {
  Builder: require './lib/builder'
  Connection: require './lib/connection'
  Model: require './lib/model'
  Query: require './lib/query'
}

exports.connection = null

exports.configure = (config) ->
  exports.config = config
  this

exports.add_plugin = (name) ->
  require(name) objs
  this

exports.create = (name) ->
  new objs.Builder name