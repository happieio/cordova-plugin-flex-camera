package io.happie.cordovaCamera;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

public class HappieCamera extends CordovaPlugin {

    public static CallbackContext callbackContext;
    public static Context context;
    public static String currentAction = "";

    public static final String CAMERA = Manifest.permission.CAMERA;
    public static final int CAM_REQUEST_CODE = 0;

    public static Integer quality;

    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        this.quality = (Integer) args.getJSONObject(0).get("quality");
        this.callbackContext = callbackContext;
        currentAction = action;

        if(action.equals("generateThumbnail")){
            try{
                return generateThumbnail(args);
            }catch (java.io.IOException e){
                return false;
            }

        }

        else if(cordova.hasPermission(CAMERA)) {
            return executeLogic(action);
        }
        else {
            getCamPermission(CAM_REQUEST_CODE);
            return false;
        }
    }


    public boolean executeLogic(String action) {
        if (action.equals("openCamera")) {
            try {
                if (action.equals("openCamera")) { //run thread safe camera
                    cordova.getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            openCamera();
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

    public boolean generateThumbnail(JSONArray args) throws JSONException, java.io.IOException {
        String name = (String) args.getJSONObject(0).get("name");
        HappieCameraThumb thumbGen = new HappieCameraThumb();

        try{
            return thumbGen.createThumbAtPathWithName(name, this.cordova.getActivity().getApplicationContext());
        }
        catch(java.io.IOException E){
            return false;
        }
    }

    public void getCamPermission(int requestCode){
        cordova.requestPermission(this, requestCode, CAMERA);
    }

    public void onRequestPermissionResult(int requestCode, String[] permissions,
                                          int[] grantResults) throws JSONException {
        for(int r:grantResults) {
            if(r == PackageManager.PERMISSION_DENIED) {
                this.callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, "Permission Denied"));
                return;
            }
        }
        switch(requestCode) {
            case CAM_REQUEST_CODE:
                executeLogic(currentAction);
                break;
        }
    }

    public static void sessionFinished(String JSON) {
        if (JSON != null && JSON.length() > 0) callbackContext.success(JSON);
        else callbackContext.error("no json");
    }
}