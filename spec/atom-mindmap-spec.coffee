{WorkspaceView} = require 'atom'
AtomMindmap = require '../lib/atom-mindmap'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "AtomMindmap", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('atom-mindmap')

  describe "when the atom-mindmap:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.atom-mindmap')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'atom-mindmap:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.atom-mindmap')).toExist()
        atom.workspaceView.trigger 'atom-mindmap:toggle'
        expect(atom.workspaceView.find('.atom-mindmap')).not.toExist()
