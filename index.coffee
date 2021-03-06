return module.exports = global['caboose'] if global['caboose']?

Path = require './lib/path'

caboose_path = new Path(process.argv[1])
exec_path = new Path(process.argv[1])
try
  exec_path = exec_path.readlink_sync()
  exec_path = caboose_path.join('..', exec_path) if exec_path[0] is '.'
catch e

node_modules = [
  new Path().join('node_modules').path,
  new Path(__dirname).join('node_modules').path
]

node_path = {}
node_path[p] = true for p in process.env.NODE_PATH.split(':') if process.env.NODE_PATH?

unless node_path[node_modules[0]]? and node_path[node_modules[1]]?
  node_path[node_modules[0]] = true
  node_path[node_modules[1]] = true
  
  process.env.NODE_PATH = Object.keys(node_path).join(':')
  require('module').Module._cache = {}
  require('module').Module._initPaths()

Application = require './lib/application'

if not global.Caboose?
  Caboose = global.Caboose = {
    exports: exports
    root: new Path()
    env: process.env.CABOOSE_ENV ? 'development'
    get: -> Caboose.registry.get(arguments...)
    argv: process.argv.slice()
    versions: {}
  }
  [major, minor, patch] = process.versions.node.split('.')
  Caboose.versions.node = {major: parseInt(major), minor: parseInt(minor), patch: parseInt(patch)}
  try
    caboose_package = require('caboose/package')
    [major, minor, patch] = caboose_package.version.split('.')
    Caboose.versions.caboose = {major: parseInt(major), minor: parseInt(minor), patch: parseInt(patch)}
  catch e
    # nerf
  
  Caboose.command = Caboose.argv.slice(2)[0]
  Caboose.arguments = Caboose.argv.slice(3)
  Caboose.path = {
    app: Caboose.root.join('app')
    config: Caboose.root.join('config')
    lib: Caboose.root.join('lib')
    plugins: Caboose.root.join('plugins')
    public: Caboose.root.join('public')
    test: Caboose.root.join('test')
    tmp: Caboose.root.join('tmp')
  }
  Caboose.path.controllers = Caboose.path.app.join('controllers')
  Caboose.path.helpers = Caboose.path.app.join('helpers')
  Caboose.path.views = Caboose.path.app.join('views')
  
  Caboose.logger = require './lib/logger'
  Caboose.util = require './lib/util'

  Caboose.registry = require './lib/registry'
  Caboose.app = new Application(Caboose.util.read_package().name) if Caboose.util.has_package()
  Caboose.cli = require './lib/cli'
  
  Caboose.controller = {
    create: (name, extends_name = 'Controller') -> new exports.controller.Builder(name, extends_name)
  }
  Caboose.generators = require './lib/generators'

exports.registry = global.Caboose.registry
exports.path = Path
exports.promise = require './lib/promise'

exports.Compiler = require './lib/compiler'
exports.controller = {
  Builder: require './lib/controller/builder'
  Controller: require './lib/controller/controller'
  Compiler: require './lib/controller/controller_compiler'
  Responder: require './lib/controller/responder'
}

exports.view = require './lib/view/view'

require './lib/controller/generator'
