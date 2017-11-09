module.exports = {
    openCamera: function (ops, success, failure) {
        //ops quality:Int, user:String, jnid:String
        cordova.exec(success, failure, "HappieCamera", "openCamera", ops);
    },
    writePhotoMeta: function (metaData, success, failure) {
        //ops quality:Int, user:String, jnid:String
        cordova.exec(success, failure, "HappieCamera", "writePhotoMeta", metaData);
    },
    readPhotoMeta: function (ops, success, failure) {
        //ops quality:Int, user:String, jnid:String
        cordova.exec(success, failure, "HappieCamera", "readPhotoMeta", ops);
    },
    getProcessingCount: function (ops, success, failure) {
        //signature - js success callback, js fail callback, native code class name, native code initialize method
        cordova.exec(success, failure, "HappieCamera", "getProcessingCount", ops);
    },
    generateThumbnail: function (params, success, failure) {
        //signature - js success callback, js fail callback, native code class name, native code initialize method
        cordova.exec(success, failure, "HappieCamera", "generateThumbnail", params);
    }
};