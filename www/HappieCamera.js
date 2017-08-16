module.exports = {
    openCamera: function (resolutionInt, success, failure) {
        var opts = {quality:resolutionInt};
        //signature - js success callback, js fail callback, native code class name, native code initialize method
        cordova.exec(success, failure, "HappieCamera", "openCamera", [opts]);
    },
    getProcessingCount: function (success, failure) {
        //signature - js success callback, js fail callback, native code class name, native code initialize method
        cordova.exec(success, failure, "HappieCamera", "getProcessingCount", []);
    },
    generateThumbnail: function (params, success, failure) {
        //signature - js success callback, js fail callback, native code class name, native code initialize method
        cordova.exec(success, failure, "HappieCamera", "generateThumbnail", params);
    }
};
