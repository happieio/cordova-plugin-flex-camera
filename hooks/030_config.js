#! /usr/local/bin/node

var fs = require('fs');
var platforms = (process.env.CORDOVA_PLATFORMS ? process.env.CORDOVA_PLATFORMS.split(',') : []);
for(var x=0; x<platforms.length; x++) {
    try {
        var platform = platforms[x].trim().toLowerCase();
        if(platform == 'ios') {
            var xcconfigPath = "platforms/ios/cordova/build.xcconfig";
            var pluginDir = "JobNimbus/Plugins/io.happie.cordovaCamera/HappieCamera-Bridging-Header.h";
            var swiftOptions = [""]; // <-- begin to file appending AFTER initial newline
            swiftOptions.push("SWIFT_OBJC_BRIDGING_HEADER = " + pluginDir);
            swiftOptions.push('LD_RUNPATH_SEARCH_PATHS = "@executable_path/Frameworks"');
            fs.appendFileSync(xcconfigPath, swiftOptions.join('\n'));
        }
    } catch(e) {
        process.stdout.write(e);
    }
}