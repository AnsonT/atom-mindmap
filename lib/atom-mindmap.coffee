path = require 'path'

AtomMindMapView = require './atom-mindmap-view'

module.exports =
  activate: (state) ->
    atom.workspace.registerOpener(openUri)
    atom.packages.once('activated', createMindMapView)


  deactivate: ->
    atom.workspace.unregisterOpener(openUri)


mupExtensions = ['.mup']
openUri = (uriToOpen) ->
  uriExtension = path.extname(uriToOpen).toLowerCase()
  if uriExtension in mupExtensions
    new AtomMindMapView(uriToOpen)


createMindMapView = ->
  {statusBar} = atom.workspaceView
