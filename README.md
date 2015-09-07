# cordova-plugin-flex-camera
a custom cordova camera that can take multiple images, create thumbnails and store data in custom locations. Supports iOS and Android

This plugin provides a modern camera for cordova projects. It has the following requirements
* iOS 7
* Android SDK >= 16
* Cordova CLI >= 5.0.0
* Cordova iOS >= 3.8.0
* Cordova Android >= 4.0.0

running this from the root folder pulls out the native source into the appropriate src folder

    gulp update

run this from the ionic root to inject the plugins from the repository (recursive)

    gulp config
    
to inject the plugin use 
    cordova plugin add https://github.com/jfspencer/jobnimbus-modern-camera.git
    
hooks/addSwiftOptions.js needs to be copied into your projects hooks folder within after_plugin_add .


*** Android Native Environment Config

testing native code via Android studio requires API 22 or later and uses cordova android 4.0.0+
