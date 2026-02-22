//
//  Action.js
//  OpenInMlem
//
//  Created by Bedir Ekim on 2026-02-20.
//

var Action = function() {};

Action.prototype = {

    run: function(arguments) {
        arguments.completionFunction({ "url" : document.URL })
    },

    finalize: function(arguments) {
        var deeplink = arguments["deeplink"]
        if (deeplink) {
            document.location.href = deeplink
        }
    }

};

var ExtensionPreprocessingJS = new Action
