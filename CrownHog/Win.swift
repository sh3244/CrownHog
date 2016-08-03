//
//  Win.swift
//  Spotlight
//
//  Created by Samuel Huang on 1/20/16.
//  Copyright © 2016 Zomero LLC. All rights reserved.
//

import UIKit
import Parse

class Win: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var somethingButton: UIButton!
    @IBOutlet var touchView: UIView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var postNumber: UIBarButtonItem!
    
    var imagePicked: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupAppearance()
        setupExtra()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        setupExtra()
    }
    
    //MARK: - Setup View

    func setupAppearance() {
        cameraButton.addTarget(self, action: #selector(Win.getPicture), forControlEvents: .TouchUpInside)
        uploadButton.addTarget(self, action: #selector(Win.uploadPicture), forControlEvents: .TouchUpInside)
        backButton.action = #selector(Win.somethingAction)
        
        commentField.delegate = self
        
//        self.navigationItem.hidesBackButton = false
    }
    
    func somethingAction () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setupExtra() {
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Win.dismissKeyboard))
        touchView.addGestureRecognizer(tap)
        
        let blurEffect = UIBlurEffect(style: .Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        self.view.addSubview(blurEffectView)
        self.view.sendSubviewToBack(blurEffectView)
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - Upload

    func uploadPicture() {
        if (PFUser.currentUser() != nil && imagePicked) {
            let user = PFUser.currentUser()
            let query = PFQuery(className: "aWinner")
            query.whereKey("user", equalTo: user!)
            query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
                if (error == nil) {
                    let count = results!.first?.objectForKey("posts") as! Int
                    if (count <= 4) {
                        results!.first?.incrementKey("posts")
                        results!.first?.saveInBackground()
                        print("saved another post")
                        
                        let post = PFObject(className: "aPost")
                        let imageData = UIImagePNGRepresentation((self.cameraButton.imageView?.image)!)
                        let imageFile = PFFile(name: "image.png", data: imageData!)
                        
                        post["imageComment"] = self.commentField.text
                        post["imageFile"] = imageFile
                        post["likes"] = 0
                        post["views"] = 0
                        post["user"] = user
                        post["dimmed"] = false
                        
                        do {
                            try post.save()
                        } catch {
                            
                        }
                        
                        let alert = UIAlertController(title: "Alert", message: "Image Upload Success", preferredStyle: .Alert)
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                        Helper.delay(1.5, closure: { () -> () in
                            self.dismissViewControllerAnimated(true, completion: nil)
                            self.dismissViewControllerAnimated(true, completion: nil)
                        })
                        print("uploadPicture success")
                    }
                    else {
                        results!.first?.setValue(false, forKey: "postable")
                    }
                }
                else {
                    print("error winview")
                }
            }
        }
        else {
            let alert = UIAlertController(title: "Image Upload Failed", message: "Try Again.", preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
            Helper.delay(1.5, closure: { () -> () in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            print("uploadPicture failed")
        }
    }
    
    
    
    // MARK: - Get Image
    
    func getPicture() {
        let picker:UIImagePickerController = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .SavedPhotosAlbum
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        imagePicked = true
        cameraButton.setImage(image, forState: .Normal)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("Image Picker Canceled")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Scroll Keyboard
    
    func textFieldDidBeginEditing(textField: UITextField) { // became first responder
        
        //move textfields up
        let myScreenRect: CGRect = UIScreen.mainScreen().bounds
        let keyboardHeight : CGFloat = 216 + 27
        
        UIView.beginAnimations( "animateView", context: nil)
//        var movementDuration:NSTimeInterval = 0.35
        var needToMove: CGFloat = 0
        
        var frame : CGRect = self.view.frame
        if (textField.frame.origin.y + textField.frame.size.height + /*self.navigationController.navigationBar.frame.size.height + */UIApplication.sharedApplication().statusBarFrame.size.height > (myScreenRect.size.height - keyboardHeight)) {
            needToMove = (textField.frame.origin.y + textField.frame.size.height + /*self.navigationController.navigationBar.frame.size.height +*/ UIApplication.sharedApplication().statusBarFrame.size.height) - (myScreenRect.size.height - keyboardHeight);
        }
        
        frame.origin.y = -needToMove
        self.view.frame = frame
        UIView.commitAnimations()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        //move textfields back down
        UIView.beginAnimations( "animateView", context: nil)
//        var movementDuration:NSTimeInterval = 0.35
        var frame : CGRect = self.view.frame
        frame.origin.y = 0
        self.view.frame = frame
        UIView.commitAnimations()
    }
    
    // MARK: - Navigation

}
