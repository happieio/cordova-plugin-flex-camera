package io.happie.cordovaCamera;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.hardware.Camera;
import android.hardware.SensorManager;
import android.media.ExifInterface;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.Display;
import android.view.OrientationEventListener;
import android.view.Surface;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.jobnimbus.JobNimbus2.R; //parent project package

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

import main.java.com.mindscapehq.android.raygun4android.RaygunClient;

/**
 * import com.jobnimbus.moderncamera.R; //Used For testing with the intenral ionic project
 */

public class HappieCameraActivity extends Activity {
    public static final int MEDIA_TYPE_IMAGE = 1;
    public static final int MEDIA_TYPE_VIDEO = 2;
    private static final String TAG = "HappieCameraActivity";

    private static final String ORIENTATION_ROTATE_90 = "6";
    private static final String ORIENTATION_NORMAL = "1";
    private static final String ORIENTATION_ROTATE_270 = "8";
    private static final String ORIENTATION_ROTATE_180 = "3";

    private ImageButton shutter;
    private ImageButton flash;
    private ImageButton queue;
    private ImageButton cancel;

    private ImageView upperLeftThumbnail;
    private ImageView upperRightThumbnail;
    private ImageView lowerLeftThumbnail;
    private ImageView lowerRightThumbnail;
    private TextView badgeCount;
    private int quadState;  //0 = UL , 1 = UR, 2 = LL, 3 = LR
    private int flashState = 2;//camera_flash_auto
    private android.content.Context thisRef;
    File mediaDir;
    File mediaThumbDir;
    Display display;

    private int degrees = 0;

    protected HappieCameraThumb thumbGen = new HappieCameraThumb();

    private Camera mCamera;

    /**
     * UI State Functions
     */
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.happie_cam_layout);
        onCreateTasks();
        setCamOrientation();
    }

    protected void onCreateTasks() {

        OrientationEventListener orientationListener = new OrientationEventListener(this, SensorManager.SENSOR_DELAY_NORMAL) {
            @Override
            public void onOrientationChanged(int arg0) {
                //TODO update camera orientation with arg0
                //Log.d(TAG, "OrientationChanged called: " + arg0);
                degrees = arg0;
            }
        };

        HappieCameraJSON base = new HappieCameraJSON();

        display = getWindowManager().getDefaultDisplay();

        if (orientationListener.canDetectOrientation()) orientationListener.enable();

        cancel = (ImageButton) findViewById(R.id.cancel);
        cancel.setOnClickListener(cancelSession);

        shutter = (ImageButton) findViewById(R.id.shutter);
        shutter.setOnClickListener(captureImage);

        queue = (ImageButton) findViewById(R.id.confirm);
        queue.setOnClickListener(cameraFinishToQueue);


        flash = (ImageButton) findViewById(R.id.flashToggle);
        flash.setOnClickListener(switchFlash);

        upperLeftThumbnail = (ImageView) findViewById(R.id.UpperLeft);
        upperRightThumbnail = (ImageView) findViewById(R.id.UpperRight);
        lowerLeftThumbnail = (ImageView) findViewById(R.id.LowerLeft);
        lowerRightThumbnail = (ImageView) findViewById(R.id.LowerRight);
        badgeCount = (TextView) findViewById(R.id.badgeCount);

        quadState = 0;

        thisRef = this;

        mediaDir = new File(HappieCamera.filesDir + "/media/" + HappieCamera.userId + "/" + HappieCamera.jnId);
        mediaThumbDir = new File(HappieCamera.filesDir + "/media/"+ HappieCamera.userId + "/" + HappieCamera.jnId + "/thumb");

        if (mediaDir.mkdirs()) {
            Log.d(TAG, "media directory created");
        } else {
            Log.d(TAG, "media directory already created");
        }

        if (mediaThumbDir.mkdirs()) {
            Log.d(TAG, "media thumbnail directory created");
        } else {
            Log.d(TAG, "media thumbnail directory already created");
        }

        String[] thumbFiles = mediaThumbDir.list();
        for (String file : thumbFiles) {
            File image = new File(mediaThumbDir, file);
            BitmapFactory.Options bmOptions = new BitmapFactory.Options();
            Bitmap bitmap = BitmapFactory.decodeFile(image.getAbsolutePath(), bmOptions);
            if (quadState == 0) {
                upperLeftThumbnail.setImageBitmap(bitmap);
                quadState = 1;
            } else if (quadState == 1) {
                upperRightThumbnail.setImageBitmap(bitmap);
                quadState = 2;
            } else if (quadState == 2) {
                lowerLeftThumbnail.setImageBitmap(bitmap);
                quadState = 3;
            } else if (quadState == 3) {
                lowerRightThumbnail.setImageBitmap(bitmap);
                quadState = 0;
            }
        }

        badgeCount.setText(Integer.toString(HappieCameraJSON.GET_TOTAL_IMAGES(HappieCamera.userId, HappieCamera.jnId)));

        HappieCameraJSON.INITIALZIE_ACTIVE_PROCESSES();

        initCameraSession();
        initCameraPreview();
    }

    protected void initCameraPreview() {
        HappieCameraPreview mPreview = new HappieCameraPreview(this, mCamera);
        FrameLayout preview = (FrameLayout) findViewById(R.id.camera_preview);
        preview.addView(mPreview);
    }

    protected void initCameraSession() {
        try {
            releaseCamera();
            mCamera = Camera.open();
            Camera.Parameters params = mCamera.getParameters();
            params.setFocusMode(Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE);
            switch (flashState) {
                case 1:
                    params.setFlashMode(Camera.Parameters.FLASH_MODE_OFF);
                    flash.setImageResource(R.drawable.camera_flash_off);
                    break;
                case 2:
                    params.setFlashMode(Camera.Parameters.FLASH_MODE_AUTO);
                    flash.setImageResource(R.drawable.camera_flash_auto);
                    break;
                default:
                    params.setFlashMode(Camera.Parameters.FLASH_MODE_TORCH);
                    flash.setImageResource(R.drawable.camera_flash_on);
            }


            List<Camera.Size> validPhotoDimensions = params.getSupportedPictureSizes();
            int i = 0;
            Camera.Size jnLimit = null;
            switch (HappieCamera.quality) {
                case 0: // High Compression
                    jnLimit = mCamera.new Size(1024, 768);
                    break;
                case 1: // Medium Compression
                    jnLimit = mCamera.new Size(2560, 1440);
                    break;
                case 2: // Low Compression
                    jnLimit = mCamera.new Size(4096, 2304);
                    break;
            }

            int lastLongSide = 0, lastShortSide = 0;
            if (jnLimit != null && validPhotoDimensions.size() != 1) {
                i = validPhotoDimensions.size();
                while (--i > 0) {
                    Camera.Size tmp = validPhotoDimensions.get(i);
                    int longSide, shortSide;
                    if (tmp.width > tmp.height) {
                        longSide = tmp.width;
                        shortSide = tmp.height;
                    } else {
                        longSide = tmp.height;
                        shortSide = tmp.width;
                    }
                    if (jnLimit.width >= longSide && jnLimit.height >= shortSide) {
                        if (lastLongSide <= longSide || lastShortSide <= shortSide) {
                            lastLongSide = longSide;
                            lastShortSide = shortSide;
                        } else {
                            i++;
                            break;
                        }
                    } else {
                        if(lastLongSide!=0 && lastShortSide!=0) {
                            i++;
                            break;
                        }
                    }
                }
            }
            Camera.Size currentSize = params.getPictureSize();
            Camera.Size maxSize = validPhotoDimensions.get(i);
            if (currentSize.height > maxSize.height || currentSize.width > maxSize.width) {
                Log.d(TAG, "current size greater than max size, resize to max size " + maxSize.width + "x" + maxSize.height);

                params.setPictureSize(maxSize.width, maxSize.height);
            }

            params.setJpegQuality(85);
            mCamera.setParameters(params);
        } catch (Exception e) {
            //There is an intermittent failure while running setParameters, do not close the camera in that case
            //since the call back will fire pre-maturely and JN will not get notified.
            Camera.Parameters params = mCamera.getParameters();
            if (params.getSupportedPictureSizes() != null) {
                Camera.Size currentSize = params.getPictureSize();
                Camera.Size maxSize = params.getSupportedPictureSizes().get(0);
                if (currentSize.height > maxSize.height || currentSize.width > maxSize.width) {
                    Log.d(TAG, "exception: current size greater than max size, resize to max size " + maxSize.width + "x" + maxSize.height);

                    params.setPictureSize(maxSize.width, maxSize.height);
                }
            }
            params.setJpegQuality(85);
            mCamera.setParameters(params);
        }
    }

    protected void setCamOrientation() {
        mCamera.stopPreview();
        Camera.CameraInfo info = new Camera.CameraInfo();
        Camera.getCameraInfo(0, info);
        int rotation = this.getWindowManager().getDefaultDisplay().getRotation();
        switch (rotation) {
            case Surface.ROTATION_0:
                degrees = 0;
                break;
            case Surface.ROTATION_90:
                degrees = 90;
                break;
            case Surface.ROTATION_180:
                degrees = 180;
                break;
            case Surface.ROTATION_270:
                degrees = 270;
                break;
        }

        int result;
        if (info.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
            result = (info.orientation + degrees) % 360;
            result = (360 - result) % 360;  // compensate the mirror
        } else {  // back-facing
            result = (info.orientation - degrees + 360) % 360;
        }
        mCamera.setDisplayOrientation(result);
        mCamera.startPreview();
    }

    @Override
    protected void onPostCreate(Bundle savedInstanceState) {
        super.onPostCreate(savedInstanceState);
    }

    @Override
    protected void onPause() {
        super.onPause();
        releaseCamera();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        setContentView(R.layout.happie_cam_layout);
        onCreateTasks();
    }

    protected void onResume() {
        super.onResume();
        if (mCamera == null) {
            initCameraSession();             // restart camera session when view returns
        }
    }

    protected void onStop() {
        releaseCamera();
        HappieCamera.sessionFinished();
        finish();// release the camera immediately on destroy event
        super.onStop();
    }

    protected void onDestroy() {
        releaseCamera();              // release the camera immediately on destroy event
        HappieCamera.sessionFinished();
        finish();
        super.onDestroy();
    }

    private void releaseCamera() {
        if (mCamera != null) {
            mCamera.release();        // release the camera for other applications
            mCamera = null;
        }
    }

    /**
     * UI Buttons
     */
    private View.OnClickListener cancelSession = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            releaseCamera();
            HappieCamera.sessionFinished();
            finish();
        }
    };

    private View.OnClickListener captureImage = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            //queue.setEnabled(false);
            shutter.setEnabled(false);
            cancel.setEnabled(false);
            try{
                mCamera.takePicture(null, null, capturePicture); //shutter, raw, jpeg
            }
            catch(Exception e){
                RaygunClient.send(e);
            }
        }
    };

    private View.OnClickListener cameraFinishToQueue = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            releaseCamera();
            HappieCamera.sessionFinished();
            finish();
        }
    };

    private View.OnClickListener switchFlash = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            Camera.Parameters params = mCamera.getParameters();
            if (flashState == 0) {
                params.setFlashMode(Camera.Parameters.FLASH_MODE_OFF);
                flash.setImageResource(R.drawable.camera_flash_off);
                flashState = 1;
            } else if (flashState == 1) {
                params.setFlashMode(Camera.Parameters.FLASH_MODE_AUTO);
                flash.setImageResource(R.drawable.camera_flash_auto);
                flashState = 2;
            } else if (flashState == 2) {
                params.setFlashMode(Camera.Parameters.FLASH_MODE_TORCH);
                flash.setImageResource(R.drawable.camera_flash_on);
                flashState = 0;
            }
            mCamera.setParameters(params);
        }
    };

    /**
     * Camera and file implementations
     */
    private Camera.PictureCallback capturePicture = new Camera.PictureCallback() {
        @Override
        public void onPictureTaken(byte[] data, Camera camera) {
            HappieCameraJSON.INCREMENT_ACTIVE_PROCESSES();
            mCamera.startPreview();

            new ProcessImage(quadState, upperLeftThumbnail,
                    upperRightThumbnail, lowerLeftThumbnail, lowerRightThumbnail, thisRef,
                    mediaDir, mediaThumbDir, queue, cancel, degrees).execute(data);

            if (quadState == 0) {
                quadState = 1;
            } else if (quadState == 1) {
                quadState = 2;
            } else if (quadState == 2) {
                quadState = 3;
            } else if (quadState == 3) {
                quadState = 0;
            }

            shutter.setEnabled(true);
        }
    };

    private class ProcessImage extends AsyncTask<byte[], Integer, android.graphics.Bitmap> {

        private android.content.Context thisRef;
        private ImageView upperLeftThumbnail;
        private ImageView upperRightThumbnail;
        private ImageView lowerLeftThumbnail;
        private ImageView lowerRightThumbnail;
        private int quadState;  //0 = UL , 1 = UR, 2 = LL, 3 = LR
        private File mediaStorageDir;
        private File mediaThumbStorageDir;
        private ImageButton queueRef;
        private ImageButton cancelRef;
        private int degrees;

        ProcessImage(int quadState, ImageView upperLeftThumb,
                     ImageView upperRightThumb, ImageView lowerLeftThumb, ImageView lowerRightThumb,
                     android.content.Context thisRef, File media, File thumb, ImageButton queue, ImageButton cancel, int deg) {
            this.upperLeftThumbnail = upperLeftThumb;
            this.upperRightThumbnail = upperRightThumb;
            this.lowerLeftThumbnail = lowerLeftThumb;
            this.lowerRightThumbnail = lowerRightThumb;
            this.quadState = quadState;
            this.thisRef = thisRef;
            this.mediaStorageDir = media;
            this.mediaThumbStorageDir = thumb;
            this.queueRef = queue;
            this.cancelRef = cancel;
            this.degrees = deg;

        }

        protected android.graphics.Bitmap doInBackground(byte[]... bytes) {
            if (Environment.getExternalStorageState().equals("MEDIA_MOUNTED") ||
                    Environment.getExternalStorageState().equals("mounted")) {
                final File[] pictureFiles = getOutputMediaFiles(MEDIA_TYPE_IMAGE);

                if (pictureFiles == null) {
                    Log.d(TAG, "Error creating media file, check storage permissions: ");
                }

                try {
                    //save image
                    FileOutputStream fos = new FileOutputStream(pictureFiles[0]);
                    fos.write(bytes[0]);
                    fos.close();

                    ExifInterface exif = new ExifInterface(pictureFiles[0].getAbsolutePath());
                    exif.setAttribute(ExifInterface.TAG_ORIENTATION, computeExifOrientation(degrees));
                    exif.saveAttributes();

                    //save thumbnail
                    Bitmap thumb = thumbGen.createThumbOfImage(pictureFiles[1], bytes[0], degreeForThumbnail(degrees));

                    String[] pathAndThumb = new String[3];
                    pathAndThumb[0] = Uri.fromFile(pictureFiles[0]).toString();
                    pathAndThumb[1] = Uri.fromFile(pictureFiles[1]).toString();

                    return thumb;

                } catch (FileNotFoundException e) {
                    Log.d(TAG, "File not found: " + e.getMessage());
                } catch (IOException e) {
                    Log.d(TAG, "Error accessing file: " + e.getMessage());
                }
            } else {
                presentSDCardWarning();
                Bitmap.Config conf = Bitmap.Config.ARGB_8888; // see other conf types
                Bitmap bmp = Bitmap.createBitmap(100, 100, conf);
                return bmp;
            }

            Bitmap.Config conf = Bitmap.Config.ARGB_8888; // see other conf types
            Bitmap bmp = Bitmap.createBitmap(100, 100, conf);

            return bmp;
        }

        protected void onPostExecute(android.graphics.Bitmap preview) {
            if (quadState == 0) {
                upperLeftThumbnail.setImageBitmap(preview);
            } else if (quadState == 1) {
                upperRightThumbnail.setImageBitmap((preview));
            } else if (quadState == 2) {
                lowerLeftThumbnail.setImageBitmap((preview));
            } else if (quadState == 3) {
                lowerRightThumbnail.setImageBitmap((preview));
            }

            badgeCount.setText(Integer.toString(HappieCameraJSON.GET_TOTAL_IMAGES(HappieCamera.userId, HappieCamera.jnId)));

            //queueRef.setEnabled(true);
            cancelRef.setEnabled(true);
            HappieCameraJSON.DECREMENT_ACTIVE_PROCESSES();
        }

        private File[] getOutputMediaFiles(int type) {
            String id = Long.toString(System.currentTimeMillis(), 36) + 
                Long.toString(ThreadLocalRandom.current().nextLong(0, 78364164095l), 36) +
                Long.toString(System.currentTimeMillis() % 37, 36) +
                ".jpg";

            File[] FileAndThumb = new File[2];
            if (type == MEDIA_TYPE_IMAGE) {
                FileAndThumb[0] = new File(mediaStorageDir.getPath() + File.separator + id);
                FileAndThumb[1] = new File(mediaThumbStorageDir.getPath() + File.separator + id);
            } else if (type == MEDIA_TYPE_VIDEO) {
                FileAndThumb[0] = new File(mediaStorageDir.getPath() + File.separator + id);
                FileAndThumb[1] = new File(mediaThumbStorageDir.getPath() + File.separator + id);
            } else {
                return null;
            }
            return FileAndThumb;
        }

        private void presentSDCardWarning() {
            new AlertDialog.Builder(thisRef)
                    .setTitle("SD Card Not Found")
                    .setMessage("Cannot reach SD card, closing camera.")
                    .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int which) {
                            finish();
                        }
                    })
                    .setIcon(android.R.drawable.ic_dialog_alert)
                    .show();
            Log.d(TAG, "Error accessing file: SD Card Not Available");
        }

        private String computeExifOrientation(int degrees) {
            if (degrees >= 315 || degrees < 45) {
                return ORIENTATION_ROTATE_90;
            } else if (degrees < 315 && degrees >= 225) {
                return ORIENTATION_NORMAL;
            } else if (degrees < 225 && degrees >= 135) {
                return ORIENTATION_ROTATE_270;
            } else if (degrees < 135 && degrees > 45) {
                return ORIENTATION_ROTATE_180;
            }
            return ORIENTATION_NORMAL;
        }

        private int degreeForThumbnail(int degrees) {
            if (degrees >= 315 || degrees < 45) {
                return 0;
            } else if (degrees < 315 && degrees >= 225) {
                return 90;
            } else if (degrees < 225 && degrees >= 135) {
                return 180;
            } else { // orientation <135 && orientation > 45
                return 270;
            }
        }
    }
}
