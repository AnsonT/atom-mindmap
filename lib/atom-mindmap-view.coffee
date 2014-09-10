{$, ScrollView} = require 'atom'
fs = require 'fs-plus'
path = require 'path'
{File} = require 'pathwatcher'


module.exports =
class AtomMindMapView extends ScrollView
  atom.deserializers.add(this)

  @deserialize: ({filePath}) ->
    if fs.isFileSync(filePath)
      new AtomMindMapView(filePath)
    else
      console.warn "Could not open file"

  @content: ->
    @iframe id:'container', class: 'atom-mindmap', tabindex: -1, src: "atom://atom-mindmap/lib/mindmup/index.html", name: 'disable-x-frame-options'


  initialize: (path) ->
    super
    @filePath = path
    @file = new File(path)

    @channel = new MessageChannel()
    console.log @channel

    window.addEventListener "message",
      (e) ->
        console.log(e)

        $("#container")[0]?.contentWindow.postMessage {type: "open", file: path}, "*"
      , false

    window.postMessage "test", "*"

  # Returns an object that can be retrieved when package is activated
  serialize: ->
    {@filePath, deserializer: 'AtomMindMapView'}

  getTitle: ->
    if @filePath?
      path.basename(@filePath)
    else
      'untitled'

  getUri: ->
    @filePath


  # Tear down any state and detach
  destroy: ->
    @detach()
