package io.happie.cordovaCamera;

import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.databind.*;
import com.fasterxml.jackson.databind.node.*;
import com.fasterxml.jackson.module.afterburner.AfterburnerModule;

public class HappieCameraJSON {

    public HappieCameraJSON() {
        if (!jacksonModulesRegistered) {
            jacksonMapper.registerModule(new AfterburnerModule());
            jacksonModulesRegistered = true;
        }
    }

    public static final ObjectMapper jacksonMapper = new ObjectMapper();
    static Boolean jacksonModulesRegistered = false;
    public List<String[]> paths = new ArrayList<String[]>();

    public void addToPathArray(String[] path) {
        paths.add(path);
    }

    public String getFinalJSON(String route, Boolean shouldSave) {
        if (shouldSave) {
            JsonNode json = jacksonMapper.createObjectNode();
            JsonNode jsonPaths = jacksonMapper.createArrayNode();

            for (String[] strings : paths)
                ((ArrayNode) jsonPaths).addObject().put("url", strings[0]).put("thumb", strings[1]);

            ((ObjectNode) json).put("route", route);
            ((ObjectNode) json).put("paths", jsonPaths);
            System.out.println(json.toString());
            resetJSON();
            String output = json.toString();
            return output;
        } else {
            deleteCapturedImages();
            resetJSON();
            return "{\"route\":\"cancel\", \"paths\":null }";
        }
    }
    
    private void deleteCapturedImages() {
    
    }

    private void resetJSON() {
        paths.clear();
    }
}
/**
 * EXAMPLE RESULTING JSON STRING
 * {
 * paths: [
 * {
 * url:"full/size/path",
 * thumb: "thumb/path"
 * }
 * ],
 * route: "queue",// options: queue || selection
 * }
 */