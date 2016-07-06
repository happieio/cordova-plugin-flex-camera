package io.happie.cordovaCamera;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
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

    public Bitmap createThumbOfImage(File file, Bitmap imageData) {
        Bitmap ThumbImage = ThumbnailUtils.extractThumbnail(imageData, 400, 400);
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        ThumbImage.compress(Bitmap.CompressFormat.JPEG, 80, stream);
        byte[] thumbnailByteArray = stream.toByteArray();

        try {
            FileOutputStream fosThumb = new FileOutputStream(file);
            fosThumb.write(thumbnailByteArray);
            fosThumb.close();

            return ThumbImage;
        } catch (FileNotFoundException e) {
            Log.d("HappieThumb", "File not found: " + e.getMessage());
            Bitmap.Config conf = Bitmap.Config.ARGB_8888; // see other conf types
            Bitmap bmp = Bitmap.createBitmap(100, 100, conf);
            return bmp;
        } catch (IOException e) {
            Log.d("HappieThumb", "Error accessing file: " + e.getMessage());
            Bitmap.Config conf = Bitmap.Config.ARGB_8888; // see other conf types
            Bitmap bmp = Bitmap.createBitmap(100, 100, conf);
            return bmp;
        }
    }

    public void createThumbOfImage(File file, File thumbPath) {
        Bitmap ThumbImage = ThumbnailUtils.extractThumbnail(BitmapFactory.decodeFile(file.getPath()), 400, 400);
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        ThumbImage.compress(Bitmap.CompressFormat.JPEG, 80, stream);
        byte[] thumbnailByteArray = stream.toByteArray();

        try {
            FileOutputStream fosThumb = new FileOutputStream(thumbPath);
            fosThumb.write(thumbnailByteArray);
            fosThumb.close();
        } catch (FileNotFoundException e) {
            Log.d("HappieThumb", "File not found: " + e.getMessage());
        } catch (IOException e) {
            Log.d("HappieThumb", "Error accessing file: " + e.getMessage());
        }
    }

//    public void createThumbOfVideo (File file){
//        try {
//            int size = (int) file.length();
//            byte[] ImageBytes = new byte[size];
//
//            BufferedInputStream buf = new BufferedInputStream(new FileInputStream(file));
//            buf.read(ImageBytes, 0, ImageBytes.length);
//            buf.close();
//
//            Bitmap ThumbImage = ThumbnailUtils.createVideoThumbnail(file.getPath(), MediaStore.Video.Thumbnails.MINI_KIND);
//            ByteArrayOutputStream stream = new ByteArrayOutputStream();
//            ThumbImage.compress(Bitmap.CompressFormat.JPEG, 80, stream);
//            byte[] thumbnailByteArray = stream.toByteArray();
//
//            FileOutputStream fosThumb = new FileOutputStream(file);
//            fosThumb.write(thumbnailByteArray);
//            fosThumb.close();
//        } catch (FileNotFoundException e) {
//            Log.d("HappieThumb", "File not found: " + e.getMessage());
//        } catch (IOException e) {
//            Log.d("HappieThumb", "Error accessing file: " + e.getMessage());
//        }
//    }

    public File getThumbFile(String filename) {
        File mediaThumbStorageDir = new File(HappieCamera.context.getExternalFilesDir(null) + "/media/thumb");
        return new File(mediaThumbStorageDir.getPath() + File.separator + filename);
    }
}