Model = require './model'

class Builder
  @plugins = {
    store_in: {
      post_build: (collection_name) ->
        @model._collection_name = collection_name
    }
  }
  
  constructor: (@name) ->
    for field in Object.keys(Builder.plugins)
      do (field) =>
        this[field] = ->
          @properties[field] = Array::slice.call arguments
          this
    
    @statics = {}
    @methods = {}
    @properties = {}
    @_before_save = []
  static: (name, method) ->
    @statics[name] = method
    this
  method: (name, method) ->
    @methods[name] = method
    this
  before_save: (method) ->
    @_before_save.push method
    this

  build: ->
    # pre-build plugins
    for k, v of @properties
      Builder.plugins[k].pre_build.apply this, v if Builder.plugins[k].pre_build?

    @model = class extends Model
      constructor: (collection) ->
        super(collection)
    @model._name = @name
    @model._properties = @properties
    @model._before_save = @_before_save
    for k, v of @methods
      @model::[k] = v
    for k, v of @statics
      @model[k] = v

    # post-build plugins
    for k, v of @properties
      Builder.plugins[k].post_build.apply this, v if Builder.plugins[k].post_build?

    @model

module.exports = Builder