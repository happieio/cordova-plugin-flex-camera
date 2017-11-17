package io.happie.cordovaCamera;

import java.io.File;
import java.util.concurrent.atomic.AtomicInteger;

import main.java.com.mindscapehq.android.raygun4android.RaygunClient;

class HappieCameraJSON {

    private static AtomicInteger ACTIVE_PROCESSES;

    static void INITIALZIE_ACTIVE_PROCESSES(){
        ACTIVE_PROCESSES = new AtomicInteger(0);
    }

    static void INCREMENT_ACTIVE_PROCESSES(){
        ACTIVE_PROCESSES.incrementAndGet();
    }

    static void DECREMENT_ACTIVE_PROCESSES(){
        ACTIVE_PROCESSES.decrementAndGet();
    }

    static int GET_ACTIVE_PROCESSES(){
        if(ACTIVE_PROCESSES == null){
            ACTIVE_PROCESSES = new AtomicInteger(0);
        }
        return ACTIVE_PROCESSES.intValue();
    }

    static int GET_TOTAL_IMAGES(String user, String jnid){
        try{
            //TODO convert this code to a glob

            //get directory of current photo session
            File mediaDir = new File(HappieCamera.filesDir + "/media/" + user + "/" + jnid);

            //list all of the files
            File[] mediaFiles = mediaDir.listFiles();
            int total = 0;

            //count all of the photos, excluding the .json and thumb directory
            for(File file : mediaFiles){
                if(!file.getName().contains(".json") && !file.isDirectory()) total++;
            }

            //return total
            return total;
        }
        catch(Exception e){
            RaygunClient.send(e);
            return -1;
        }
    }
}