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
            File mediaDir = new File(HappieCamera.filesDir + "/media/" + user + "/" + jnid);
            File[] mediaFiles = mediaDir.listFiles();
            int total = 0;
            for(File file : mediaFiles){
                String name = file.getName();
                if(!name.contains(".json")) total++;
            }
            return total - 1;
        }
        catch(Exception e){
            RaygunClient.send(e);
            return -1;
        }
    }
}
