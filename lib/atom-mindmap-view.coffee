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
    #@iframe id:'container', class: 'atom-mindmap', tabindex: -1, src: "atom://atom-mindmap/lib/mindmup/index.html", name: 'disable-x-frame-options'
    @div =>
      @button "Send To Frame", id:'sendMessage', click: 'onClick'
      @iframe id:'container', class: 'atom-mindmap', tabindex: -1, src: "atom://atom-mindmap/lib/mindmup/index.html", name: 'disable-x-frame-options'

  initialize: (path) ->
    super
    @filePath = path
    @file = new File(path)
    @subscribe @file, 'content-changed', => @updateMindMap

    window.addEventListener "message", @handleMessage, false

  onClick: ->
    console.log 'Send To Frame'
    @iframePort.postMessage "Sent From Parent Message"

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
    window.removeEventListener "message", @handleMessage, false
    @detach()

  updateMindMap: ->
    console.log 'updateMindMap'
    @data = JSON.parse(fs.readFileSync(@filePath, encoding: 'utf8'))
    if @iframePort
      console.log "send updateData message"
      @iframePort.postMessage({message: "updateData", data: @data})

  handleMessage: (e) =>
    if e.data is 'Initialize-Port'
      @iframePort = e.ports[0]
      @iframePort.onmessage = @handleFrameMessage
      @updateMindMap()


  handleFrameMessage: (e) ->
    console.log 'from iFrame'
    console.log e
