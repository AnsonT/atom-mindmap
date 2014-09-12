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
#    @div =>
#      @button "Send To Frame", id:'sendMessage', click: 'onClick'
    @iframe id:'container', class: 'atom-mindmap', tabindex: -1, src: "atom://atom-mindmap/lib/mindmup/index.html", name: 'disable-x-frame-options'

  initialize: (path) ->
    super
    @filePath = path
    @file = new File(path)
    @changed = false
    @subscribe @file, 'content-changed', => @updateMindMap
    window.addEventListener "message", @handleMessage, false

  isModified: ->
    return @changed

  isEmpty: ->
    return false

  shouldPromptToSave: ->
    @isModified()

  save: ->
    @framePort.postMessage message: 'saveData', path: @filePath

  saveAs: (path) ->
    @framePort.postMessage message: 'saveData', path: path

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

  getModel: ->
    console.log "getModel"
    return this

  setChanged: (isChanged) =>
    unless @changed is isChanged
      @changed = isChanged
      @trigger "modified-status-changed"

  # Tear down any state and detach
  destroy: ->
    window.removeEventListener "message", @handleMessage, false
    @detach()

  updateMindMap: ->
    @data = JSON.parse(fs.readFileSync(@filePath, encoding: 'utf8'))
    if @framePort
      @framePort.postMessage({message: "updateData", data: @data})
      @setChanged false


  handleMessage: (e) =>
    unless @frameId
      if e.data?.message is 'Initialize-Port'
        @framePort = e.ports[0]
        @framePort.onmessage = @handleFrameMessage
        @frameId = e.data.frameId
        @updateMindMap()


  handleFrameMessage: (e) =>
    if (e.data?.frameId is @frameId)
      if e.data?.message is 'changed'
        @setChanged true
      else if e.data?.message is 'saveData'

        @filePath = e.data?.path
        @file = new File(@filePath)
        fs.writeFileSync(@filePath, e.data.data, encoding: 'utf8')
        @setChanged false
