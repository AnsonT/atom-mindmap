requirejs.config({
    'baseUrl': '/lib/mindmup/',
    'paths': {
        'domReady': 'javascript/domReady',
        'jquery': 'javascript/jquery-2.0.2.min',
        'underscore': 'javascript/underscore-1.4.4',
        'color': 'javascript/color-0.4.1.min',
        'hammerjs': 'javascript/hammer',
        'jquery-hammer': 'javascript/jquery.hammer.min',
        'jquery-hotkey': 'javascript/jquery.hotkeys',
        'jquery-mousewheel': 'javascript/jquery.mousewheel-3.1.3',
        'jquery-ui-position': 'javascript/jquery.ui.position',
        'jquery-contextmenu': 'javascript/jquery.contextMenu',
        'mapjs': 'javascript/mapjs-compiled',
        'testmap': 'javascript/templates/roy-map',
        'default-template': 'javascript/templates/default-template'
    },
    'packages': [
        { 'name': 'Hammer', }
    ],
    'shim': {
        'underscore': {
            'exports': '_'
        },
        'mapjs': {
            'deps': ['jquery', 'underscore', 'color', 'hammerjs',
                     'jquery-hammer', 'jquery-hotkey', 'jquery-mousewheel',
                     'jquery-ui-position', 'jquery-contextmenu'],
            'exports': 'MAPJS',
            init: function( $, _, color, Hammer ) {
                this.Hammer = Hammer;
            }
        },
        'testmap': {
            'exports': 'test_tree'
        },
        'default-template': {
          'exports': 'default_template'
        }
    }
});


define('mindmup/message',
       ['jquery'],
       function($) {
         return {
           sendToParent: function(message) {
             message = message || {};
             message.frameId = window.frameId;
             window.parentPort.postMessage(message);
           }
         };
});

require(['jquery', 'domReady!', 'mapjs', 'mindmup/message'], function($, doc, mapjs, msg) {
  $('#message').click(function() {
      msg.sendToParent({ message: "testing message" });
  });


  channel = new MessageChannel();

  function onParentMessage2(e) {
      if (e && e.data)
      {
        if (e.data.message == 'updateData')
        {
            var idea = MAPJS.content(e.data.data);
            window.mapModel.setIdea(idea);
            idea.addEventListener('changed', function() {
              msg.sendToParent({message: 'changed' });
            });
            window.mapModel.addEventListener('contextMenuRequested', function(id, x, y) {
              //msg.sendToParent({message: 'contextMenu', id:id, x:x, y:y });
              $('.node-context-menu').contextMenu({x:x, y:y});
              $('.node-context-menu').trigger('contextmenu');
            });

        }
        else if (e.data.message == 'saveData')
        {
            var data = JSON.stringify(window.mapModel.getIdea());
            var path = e.data.path;
            msg.sendToParent({message: 'saveData', data: data, path: path})
        }
      }
  }
  channel.port1.onmessage = onParentMessage2
  window.parentPort = channel.port1;
  window.frameId = (new Date()).toString();
  window.parent.postMessage( { message: "Initialize-Port",
                               frameId: window.frameId },
                             "*", [channel.port2]);
});

require(['jquery', 'mapjs'],
    function($, mapjs, template) {


    window.oneerror = alert;

    var container = $('#container');
    var mapModel = new MAPJS.MapModel(MAPJS.DOMRender.layoutCalculator, []);
    var imageInsertController = new MAPJS.ImageInsertController("http://localhost:4999?u=");
    container.domMapWidget(console, mapModel, false, imageInsertController);
    window.mapModel = mapModel;
    imageInsertController.addEventListener('imageInsertError', function (reason) {
        console.log('image insert error', reason);
    });

    $.contextMenu(
      {
        selector: '.node-context-menu',
        trigger: 'none',
        callback: function(key, options) {
          switch(key)
          {
            case 'edit':
              window.mapModel.editNode(null, true, false);
              break;
            case 'cut':
              window.mapModel.cut(null);
              break;
            case 'copy':
              window.mapModel.copy(null);
              break;
            case 'paste':
              window.mapModel.paste(null);
              break;
            case 'delete':

              break;
            case 'connect':
              window.mapModel.toggleAddLinkMode(null);
              break;
            case 'color':
              break;
            case 'image':
              break;
          }
        },
        items: {
            'edit': {name: 'Edit Text'},
            'sep1': '--------',
            'cut': {name: 'Cut'},
            'copy': {name: 'Copy'},
            'paste': {name: 'Paste'},
            'sep2': '--------',
            'delete': {name: 'Delete'},
            'sep3': '--------',
            'connect': {name: 'Connect'},
            'color': {name: 'Color'},
            'image': {name: 'Insert Image'},
            'note': {name: 'Insert Note'}
        }
      }
    );
});
