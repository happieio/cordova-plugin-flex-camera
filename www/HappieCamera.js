module.exports = {
    openCamera: function (success, failure) {
        //signature - js success callback, js fail callback, native code class name, native code initialize method
        cordova.exec(success, failure, "HappieCamera", "openCamera", []);
    },

    getCameraRoll: function (success, failure) {
        //signature - js success callback, js fail callback, native code class name, native code initialize method
        cordova.exec(success, failure, "HappieCamera", "getCameraRoll", []);
    }
};