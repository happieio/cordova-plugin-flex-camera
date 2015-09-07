package io.happie.cordovaCamera;

import android.content.Context;
import android.content.Intent;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import java.io.File;

import android.os.Environment;

public class HappieCamera extends CordovaPlugin {

    public static CallbackContext callbackContext;
    public static Context context;
    protected HappieCameraRoll camRoll = new HappieCameraRoll();

    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;
        if (action.equals("openCamera") || action.equals("getCameraRoll")) {
            try {
                if (action.equals("openCamera")) { //run thread safe camera
                    cordova.getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            openCamera();
                        }
                    });
                } else if (action.equals("getCameraRoll")) {
                    cordova.getThreadPool().execute(new Runnable() {
                        @Override
                        public void run() {
                            camRoll.getAndroidCameraRoll();
                        }
                    });
                }
            } catch (IllegalArgumentException e) {
                callbackContext.error("Illegal Argument Exception");
                PluginResult r = new PluginResult(PluginResult.Status.ERROR);
                callbackContext.sendPluginResult(r);
                return true;
            }

            PluginResult r = new PluginResult(PluginResult.Status.NO_RESULT);
            r.setKeepCallback(true);
            callbackContext.sendPluginResult(r);
            return true;
        }
        return false;
    }

    public void openCamera() {
        context = this.cordova.getActivity().getApplicationContext();
        Intent pictureIntent = new Intent(context, io.happie.cordovaCamera.HappieCameraActivity.class);
        pictureIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(pictureIntent);
    }

    public static void sessionFinished(String JSON) {
        if (JSON != null && JSON.length() > 0) callbackContext.success(JSON);
         else callbackContext.error("no json");
    }
}