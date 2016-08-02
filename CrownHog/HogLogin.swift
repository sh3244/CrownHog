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
        req.startWithCompletionHandler({ (connection, result, error : NSError!) -> Void in
            if(error == nil)
            {
                NSUserDefaults.standardUserDefaults().setValue(result["id"] as! String, forKey: "fbid")
                NSUserDefaults.standardUserDefaults().setValue(result["name"] as! String, forKey: "name")
                NSUserDefaults.standardUserDefaults().setObject(UIImagePNGRepresentation(self.getProfPic(result["id"] as! String)!), forKey: "profileImage")
                
                let query = PFQuery(className: "_User")
                let username = PFUser.currentUser()?.username
                query.whereKey("username", equalTo: username!)
                query.findObjectsInBackgroundWithBlock{
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    if (error == nil) {
                        if let objects = objects {
                            for object in objects {
                                object["fbid"] = result["id"] as! String
                                let imageFile = PFFile(name: "image.png", data: UIImagePNGRepresentation(self.getProfPic(result["id"] as! String)!)!)
                                object["profileImage"] = imageFile
                                object.saveInBackground()
                            }
                        }
                    }
                    else {
                        print("error login")
                    }
                }
            }
            else
            {
                print("error \(error)")
            }
        })
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
