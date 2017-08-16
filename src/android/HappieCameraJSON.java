package io.happie.cordovaCamera;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

import com.fasterxml.jackson.databind.*;
import com.fasterxml.jackson.databind.node.*;
import com.fasterxml.jackson.module.afterburner.AfterburnerModule;

public class HappieCameraJSON {

    private static AtomicInteger ACTIVE_PROCESSES;
    private static AtomicInteger TOTAL_IMAGES;

    public static void INITIALZIE_ACTIVE_PROCESSES(){
        ACTIVE_PROCESSES.set(0);
    }

    public static void SET_TOTAL_IMAGES(int count){
        TOTAL_IMAGES.set(count);
    }

    public static void INCREMENT_ACTIVE_PROCESSES(){
        ACTIVE_PROCESSES.incrementAndGet();
    }

    public static void DECREMENT_ACTIVE_PROCESSES(){
        ACTIVE_PROCESSES.decrementAndGet();
    }

    public static int GET_ACTIVE_PROCESSES(){
        return ACTIVE_PROCESSES.intValue();
    }

    public static int GET_TOTAL_IMAGES(){
        return TOTAL_IMAGES.intValue();
    }
}