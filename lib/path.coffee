fs = require 'fs'
util = require 'util'
PATH = require 'path'

module.exports = class Path
  constructor: (path = process.cwd()) ->
    @path = PATH.normalize(if path instanceof Path then path.path else path)
    # [x, x, @basename, @extension] = /^(.*\/)?(?:$|(.+?)(?:(\.[^.]*$)|$))/.exec(@path)
    # @filename = (@basename or '') + (@extension or '')
    # @extension = @extension.slice(1) if @extension?
    
    @dirname = PATH.dirname(@path)
    @extension = PATH.extname(@path)
    @filename = PATH.basename(@path)
    @basename = PATH.basename(@path, @extension)
    @extension = @extension.replace(/^\.+/, '')
    
  join: (subpaths...) ->
    subpaths = subpaths.map (p) -> if p instanceof Path then p.path else p
    new Path(PATH.join @path, subpaths...)
  
  toString: ->
    @path

  require: ->
    require @path

  # PATH METHODS
  exists: (callback) ->
    PATH.exists @path, callback

  exists_sync: ->
    PATH.existsSync @path

  # FS METHODS
  create_read_stream: ->
    fs.createReadStream @path
  
  create_write_stream: ->
    fs.createWriteStream @path
  
  mkdir: (mode = 0777, callback) ->
    fs.mkdir @path, mode, callback
  
  mkdir_sync: (mode = 0777) ->
    fs.mkdirSync @path, mode

  readdir: (callback) ->
    fs.readdir @path, (err, files) =>
      return callback(err) if err?
      callback(err, files.map (f) => @.join(f))

  readdir_sync: ->
    fs.readdirSync(@path).map (f) => @.join(f)

  read_file_sync: (encoding = undefined) ->
    fs.readFileSync @path, encoding
  
  stat: (callback) ->
    fs.stat @path, callback
  
  stat_sync: ->
    fs.statSync @path

  write_file_sync: (data, encoding = undefined) ->
    fs.writeFileSync @path, data, encoding
  
  unlink: (callback) ->
    fs.unlink @path, callback
  
  unlink_sync: ->
    fs.unlinkSync @path

  # HELPER METHODS
  is_directory_empty: (callback) ->
    @readdir (err, files) ->
      throw err if err and 'ENOENT' isnt err.code
      callback(files.length is 0)
  
  copy: (to, callback) ->
    src = @
    src.exists (err, exists) ->
      return callback(err) if err?
      return callback(new Error("File #{src} does not exist.")) unless exists
    
      dest = if to instanceof Path then to else new Path(to)
      dest.exists (err, exists) ->
        return callback(err) if err?
        return callback(new Error("File #{to} already exists.")) if exists
        
        input = src.create_read_stream()
        output = dest.create_write_stream()
        util.pump(input, output, callback)
  
  copy_sync: (to) ->
    throw new Error("File #{@} does not exist.") unless @.exists_sync()
    dest = if to instanceof Path then to else new Path(to)
    throw new Error("File #{to} already exists.") if dest.exists_sync()

    dest.write_file_sync(@.read_file_sync())
  
  is_directory: (callback) ->
    @stat (err, stats) ->
      callback(err, if stats? then stats.isDirectory() else null)
  
  is_directory_sync: ->
    @stat_sync().isDirectory()
  
  is_absolute: ->
    @path[0] is '/'
