package io.happie.cordovaCamera;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.media.ThumbnailUtils;

import java.io.File;

import android.util.Log;

import java.io.ByteArrayOutputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

/**
 * Created by jobnimbus on 5/13/15.
 */
public class HappieCameraThumb {

    public boolean createThumbAtPathWithName(String name, Context context) throws java.io.IOException{

        String filePath = context.getFilesDir() + "/mainCache";
        File fullFile = new File(filePath, name);

        File thumbFile = new File(filePath, name + "_thumb");

        byte[] imageBytes = org.apache.commons.io.FileUtils.readFileToByteArray(fullFile);
        Bitmap ThumbImage = ThumbnailUtils.extractThumbnail(BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.length), 400, 400);

        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        ThumbImage.compress(Bitmap.CompressFormat.JPEG, 85, stream);
        byte[] thumbnailByteArray = stream.toByteArray();

        try {
            FileOutputStream fosThumb = new FileOutputStream(thumbFile);
            fosThumb.write(thumbnailByteArray);
            fosThumb.close();
        } catch (FileNotFoundException e) {
            Log.d("HappieThumb", "File not found: " + e.getMessage());
            return false;
        } catch (IOException e) {
            Log.d("HappieThumb", "Error accessing file: " + e.getMessage());
            return false;
        }
        return true;
    }

    public Bitmap createThumbOfImage(File file, byte[] imageData, String degrees) {
        Bitmap thumbImage = ThumbnailUtils.extractThumbnail(BitmapFactory.decodeByteArray(imageData, 0, imageData.length), 400, 400);

        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        thumbImage.compress(Bitmap.CompressFormat.JPEG, 80, stream);
        byte[] thumbnailByteArray = stream.toByteArray();

        try {
            FileOutputStream fosThumb = new FileOutputStream(file);
            fosThumb.write(thumbnailByteArray);
            fosThumb.close();

            ExifInterface exif = new ExifInterface(file.getAbsolutePath());
            exif.setAttribute(ExifInterface.TAG_ORIENTATION, degrees);
            exif.saveAttributes();

        } catch (FileNotFoundException e) {
            Log.d("HappieThumb", "File not found: " + e.getMessage());
        } catch (IOException e) {
            Log.d("HappieThumb", "Error accessing file: " + e.getMessage());
        }
        return thumbImage;
    }
}