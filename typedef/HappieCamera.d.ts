
declare var HappieCamera: HappieCamera;

interface HappieCamera {
    openCamera(success:(jsonString:string)=>void, failure:(error:string)=>void) : void;
}

