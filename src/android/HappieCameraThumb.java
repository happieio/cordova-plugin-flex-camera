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

        FileOutputStream fosThumb = null;
        try {
            fosThumb = new FileOutputStream(thumbFile);
            fosThumb.write(thumbnailByteArray);

            ExifInterface exif = new ExifInterface(fullFile.getAbsolutePath());
            String orientation = exif.getAttribute(ExifInterface.TAG_ORIENTATION);

            ExifInterface exifThumb = new ExifInterface(thumbFile.getAbsolutePath());
            exifThumb.setAttribute(ExifInterface.TAG_ORIENTATION, orientation);
            exifThumb.saveAttributes();
        } catch (Exception e) {
            RaygunClient.send(e);
            return false;
        }
        finally {
            try{
                fosThumb.close();
            }
            catch (NullPointerException e){
                RaygunClient.send(e);
            }
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

        FileOutputStream fosThumb = null;
        try {
            fosThumb = new FileOutputStream(file);
            fosThumb.write(thumbnailByteArray);
        } catch (Exception e) {
            RaygunClient.send(e);
        }
        finally {
            try{
                fosThumb.close();
            }
            catch (Exception e){
                RaygunClient.send(e);
            }
        }
        return ThumbImage;
    }
}
