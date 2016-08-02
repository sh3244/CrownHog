//
//  HogLogin.swift
//  Spotlight
//
//  Created by Samuel Huang on 1/20/16.
//  Copyright © 2016 Zomero LLC. All rights reserved.
//

import UIKit
import ParseUI
import ParseFacebookUtilsV4

class HogLogin: PFLogInViewController, PFLogInViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupAppearance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupAppearance() {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        
        let logoView = UIImageView()
        logoView.image = UIImage(named: "logoMedium.png")
        logoView.contentMode = UIViewContentMode.Center
        logoView.contentScaleFactor = 2.0
        self.viewIfLoaded?.backgroundColor = Helper.UIColorFromRGB(0x1A425B)
        self.logInView!.logo = logoView 
    }
    
    func getProfPic(fid: String) -> UIImage? {
        if (fid != "") {
            let imgURLString = "https://graph.facebook.com/" + fid + "/picture?type=large"
            let imgURL = NSURL(string: imgURLString)
            let imageData = NSData(contentsOfURL: imgURL!)
            
            if let imageData = imageData{
                let image = UIImage(data: imageData)
                return image
            }
            else {
                print("settings image error!")
            }
        }
        return nil
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        let accessToken = FBSDKAccessToken.currentAccessToken()
        let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, name"], tokenString: accessToken.tokenString, version: nil, HTTPMethod: "GET")
        req.startWithCompletionHandler({ connection, result, error -> Void in
            if(error == nil) {
                if let userID = result.valueForKey("id") as? String {
                    NSUserDefaults.standardUserDefaults().setValue(userID, forKey: "fbid")
                    
                    let image = self.getProfPic(userID)
                    NSUserDefaults.standardUserDefaults().setObject(image, forKey: "profileImage")
                    
                    let query = PFQuery(className: "_User")
                    let username = PFUser.currentUser()?.username
                    query.whereKey("username", equalTo: username!)
                    query.findObjectsInBackgroundWithBlock{
                        (objects: [PFObject]?, error: NSError?) -> Void in
                        if (error == nil) {
                            if let objects = objects {
                                for object in objects {
                                    object["fbid"] = result.stringForKey("id")
                                    if let img = image {
                                        let imageFile = PFFile(name: "image.png", data: UIImagePNGRepresentation(img)!)
                                        object["profileImage"] = imageFile
                                        object.saveInBackground()
                                    }
                                }
                            }
                        }
                        else {
                            print("error login")
                        }
                    }
                }
                if let userName = result.valueForKey("name") as? String {
                    NSUserDefaults.standardUserDefaults().setValue(userName, forKey: "name")
                }
            }
        })
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
