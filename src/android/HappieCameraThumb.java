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

            ExifInterface exif = new ExifInterface(fullFile.getAbsolutePath());
            String orientation = exif.getAttribute(ExifInterface.TAG_ORIENTATION);

            ExifInterface exifThumb = new ExifInterface(thumbFile.getAbsolutePath());
            exif.setAttribute(ExifInterface.TAG_ORIENTATION, orientation);
            exif.saveAttributes();
        } catch (FileNotFoundException e) {
            Log.d("HappieThumb", "File not found: " + e.getMessage());
            return false;
        } catch (IOException e) {
            Log.d("HappieThumb", "Error accessing file: " + e.getMessage());
            return false;
        }
        return true;
    }

    public Bitmap createThumbOfImage(File file, byte[] imageData, int degrees) {
        Bitmap ThumbImage = ThumbnailUtils.extractThumbnail(BitmapFactory.decodeByteArray(imageData, 0, imageData.length), 400, 400);

        Matrix matrix = new Matrix();
        if(degrees == 0 || degrees == 180){
            matrix.postRotate(degrees+90);
        }else {
            matrix.postRotate(degrees-90);
        }

        Bitmap orientedBmp = Bitmap.createBitmap(ThumbImage, 0, 0, ThumbImage.getWidth(), ThumbImage.getHeight(), matrix, true);

        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        orientedBmp.compress(Bitmap.CompressFormat.JPEG, 85, stream);
        byte[] thumbnailByteArray = stream.toByteArray();

        try {
            FileOutputStream fosThumb = new FileOutputStream(file);
            fosThumb.write(thumbnailByteArray);
            fosThumb.close();
        } catch (FileNotFoundException e) {
            Log.d("HappieThumb", "File not found: " + e.getMessage());
        } catch (IOException e) {
            Log.d("HappieThumb", "Error accessing file: " + e.getMessage());
        }
        return ThumbImage;
    }
}