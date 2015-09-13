//  Created by Jason Du
//  Copyright (c) 2015 Jason Du. All rights reserved.
//

import UIKit


class ViewController: UIViewController,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate
{

// ImageView that will show the picked image (from Camera or Photo library)
@IBOutlet weak var imagePicked: UIImageView!
    
    
override func prefersStatusBarHidden() -> Bool {
        return true
}
    
override func viewDidLoad() {
        super.viewDidLoad()
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
}
    
func DismissKeyboard(){
    //Causes the view (or one of its embedded text fields) to resign the first responder status.
    view.endEditing(true)
}
    
@IBOutlet weak var titleField: UITextField!

@IBAction func SubmitPressed(sender: AnyObject) {
    myImageUploadRequest()
    titleField.text = ""
    var alert = UIAlertView(title: "",
        message: "Your image has been submitted to the server!",
        delegate: nil,
        cancelButtonTitle: "Ok")
    alert.show()
    }

// OPEN CAMERA BUTTON
@IBAction func openCameraButton(sender: AnyObject) {
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
        imagePicker.allowsEditing = false
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
}
 
// OPEN PHOTO LIBRARY BUTTON
@IBAction func openPhotoLibraryButton(sender: AnyObject) {
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
        imagePicker.allowsEditing = false
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
}

// IMAGE PICKER DELEGATE 
func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        imagePicked.image = image
        self.dismissViewControllerAnimated(true, completion: nil);
}
    
// SAVE IMAGE BUTTON
@IBAction func saveButt(sender: AnyObject) {
    var imageData = UIImageJPEGRepresentation(imagePicked.image, 0.6)
    var compressedJPGImage = UIImage(data: imageData)
    UIImageWriteToSavedPhotosAlbum(compressedJPGImage, nil, nil, nil)
    
    var alert = UIAlertView(title: "Wow",
        message: "Your image has been saved to Photo Library!",
        delegate: nil,
        cancelButtonTitle: "Ok")
    alert.show()
}
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
    
func myImageUploadRequest() {
    var titleNote = titleField.text
    let myUrl = NSURL(string: "http://35.0.122.159:5000/send-image");
    
    let request = NSMutableURLRequest(URL:myUrl!);
    request.HTTPMethod = "POST";
        
    let param = [
        "title"  : titleNote!,
        "userId"    : "9"
    ]
        
    let boundary = generateBoundaryString()
        
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
    let imageData = UIImageJPEGRepresentation(imagePicked.image, 0.6)
        
    if(imageData==nil)  { return; }
        
    request.HTTPBody = createBodyWithParameters(param, filePathKey: "file", imageDataKey: imageData, boundary: boundary)
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
        data, response, error in
            
        if error != nil {
            println("error=\(error)")
            return
        }
            
        // You can print out response object
        println("******* response = \(response)")
            
        // Print out reponse body
        let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
        println("****** response data = \(responseString!)")
            
        var err: NSError?
        var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &err) as? NSDictionary
            
            
            
        dispatch_async(dispatch_get_main_queue(),{
            self.imagePicked.image = nil;
        });
    }
        
    task.resume()
    
}
    
    
func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
    var body = NSMutableData();
        
    if parameters != nil {
        for (key, value) in parameters! {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
    }
        
    let filename = "user-profile.jpg"
        
    let mimetype = "image/jpg"
        
    body.appendString("--\(boundary)\r\n")
    body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
    body.appendString("Content-Type: \(mimetype)\r\n\r\n")
    body.appendData(imageDataKey)
    body.appendString("\r\n")
    body.appendString("--\(boundary)--\r\n")
    return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
}



extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}



