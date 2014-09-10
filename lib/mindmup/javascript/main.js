requirejs.config({
    'baseUrl': '/lib/mindmup/',
    'paths': {
        'jquery': 'javascript/jquery-2.0.2.min',
        'underscore': 'javascript/underscore-1.4.4',
        'color': 'javascript/color-0.4.1.min',
        'hammerjs': 'javascript/hammer',
        'jquery-hammer': 'javascript/jquery.hammer.min',
        'jquery-hotkey': 'javascript/jquery.hotkeys',
        'jquery-mousewheel': 'javascript/jquery.mousewheel-3.1.3',
        'mapjs': 'javascript/mapjs-compiled',
        'testmap': 'javascript/test/roy-map'
    },
    'packages': [
        { 'name': 'Hammer', }
    ],
    'shim': {
        'underscore': {
            'exports': '_'
        },
        'mapjs': {
            'deps': ['jquery', 'underscore', 'color', 'hammerjs', 'jquery-hammer', 'jquery-hotkey', 'jquery-mousewheel'],
            'exports': 'MAPJS',
            init: function( $, _, color, Hammer ) {
                this.Hammer = Hammer;
            }
        },
        'testmap': {
            'exports': 'test_tree'
        }
    }
});


require(['jquery', 'mapjs', 'testmap'],
    function($, mapjs, testmap) {


    window.oneerror = alert;
    window.addEventListener("message", function(event) { console.log(event); }, false);

    console.log(mapjs);
    console.log(testmap());

    var container = $('#container');
    var idea = MAPJS.content(testmap());
    var mapModel = new MAPJS.MapModel(MAPJS.DOMRender.layoutCalculator, []);
    var imageInsertController = new MAPJS.ImageInsertController("http://localhost:4999?u=");
    container.domMapWidget(console, mapModel, false, imageInsertController);
    mapModel.setIdea(idea);
    window.mapModel = mapModel;
    imageInsertController.addEventListener('imageInsertError', function (reason) {
        console.log('image insert error', reason);
    });
    window.parent.postMessage("testing", "*");
});
