package io.happie.cordovaCamera;

import java.io.File;
import java.util.concurrent.atomic.AtomicInteger;

public class HappieCameraJSON {

    private static AtomicInteger ACTIVE_PROCESSES;

    public static void INITIALZIE_ACTIVE_PROCESSES(){
        ACTIVE_PROCESSES = new AtomicInteger(0);
    }

    public static void INCREMENT_ACTIVE_PROCESSES(){
        ACTIVE_PROCESSES.incrementAndGet();
    }

    public static void DECREMENT_ACTIVE_PROCESSES(){
        ACTIVE_PROCESSES.decrementAndGet();
    }

    public static int GET_ACTIVE_PROCESSES(){
        if(ACTIVE_PROCESSES == null){
            ACTIVE_PROCESSES = new AtomicInteger(0);
        }
        return ACTIVE_PROCESSES.intValue();
    }

    public static int GET_TOTAL_IMAGES(){
        File mediaDir = new File(HappieCamera.context.getFilesDir() + "/media");
        String[] mediaFiles = mediaDir.list();
        return mediaFiles.length - 1;
    }
}