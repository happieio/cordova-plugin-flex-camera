package io.happie.cordovaCamera;

import android.os.Environment;

import org.apache.cordova.PluginResult;

import java.io.File;

/**
 * Created by jobnimbus on 5/13/15.
 */
public class HappieCameraRoll {

    protected HappieCameraThumb thumbGen = new HappieCameraThumb();
    protected HappieCameraJSON jsonGen = new HappieCameraJSON();

    public void getAndroidCameraRoll() {
        File dcim = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM);
        File thumbnails = new File(dcim, "/.thumbnails");
        File[] listOfImg = dcim.listFiles();
        if (dcim.isDirectory()) {
            //for each child in DCIM directory
            for (File file : listOfImg) {
                if (!file.getAbsolutePath().equals(thumbnails.getAbsolutePath())) {
                    if (file.isDirectory()) {
                        File[] temp = file.listFiles();
                        for (File image : temp) {
                             if (!image.getName().contains("mp4")) generateMediaPaths(image, true);
                            else generateMediaPaths(image, false);
                        }
                    } else if (file.isFile()) {
                        if (!file.getName().contains("mp4")) generateMediaPaths(file, true);
                        else generateMediaPaths(file, false);
                    }
                }
            }
            PluginResult r = new PluginResult(PluginResult.Status.OK, "{\"route\":\"selection\", paths:null}");
            r.setKeepCallback(true);
            HappieCamera.callbackContext.sendPluginResult(r);
        } else {
            HappieCamera.callbackContext.error("could not find camera roll");
        }
    }

    public void generateMediaPaths(File file, Boolean isImage) {
        if (isImage) {
            File thumbPath = thumbGen.getThumbFile("roll_" + file.getName());
            thumbGen.createThumbOfImage(file, thumbPath);
            String[] paths = new String[2];
            paths[0] = file.getAbsolutePath();
            paths[1] = thumbPath.getAbsolutePath();
            jsonGen.addToPathArray(paths);
            PluginResult r = new PluginResult(PluginResult.Status.OK, jsonGen.getFinalJSON("select", true));
            r.setKeepCallback(true);
            HappieCamera.callbackContext.sendPluginResult(r);
        } else {
            String notImplemented = "";
            //handles videos
//            File thumbPath = HappieThumb.getThumbFile("roll_" + file.getName());
//            HappieThumb.createThumbOfVideo(file);
//            String[] paths = new String[2];
//            paths[0] = file.getAbsolutePath();
//            paths[1] = thumbPath.getAbsolutePath();
//            HappieCameraJSON.addToPathArray(paths);
        }
    }
}