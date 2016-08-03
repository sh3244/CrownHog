//
//  SocialView.swift
//  Spotlight
//
//  Created by Samuel Huang on 1/27/16.
//  Copyright © 2016 Zomero LLC. All rights reserved.
//

import UIKit
import ParseUI
import ParseFacebookUtilsV4

class SocialView: UIViewController {
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        setupAppearance()
        setupExtra()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupAppearance() {
        queryInfo()
    }
    
    func setupButtons() {
        exitButton.addTarget(self, action: #selector(SocialView.exitView), forControlEvents: .TouchUpInside)
        
    }
    
    func setupExtra() {
        let blurEffect = UIBlurEffect(style: .Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        self.view.addSubview(blurEffectView)
        self.view.sendSubviewToBack(blurEffectView)
    }
    
    func exitView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func loadInfo(username: String) {
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: username)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (error == nil) {
                if let objects = objects {
                    for object in objects {
                        self.nameLabel.text = String(object.valueForKey("name")!)
                        let userImageFile = object.valueForKey("profileImage") as! PFFile
                        userImageFile.getDataInBackgroundWithBlock {
                            (imageData: NSData?, error: NSError?) -> Void in
                            if error == nil {
                                if let imageData = imageData {
                                    self.profileView.image = UIImage(data: imageData)
                                }
                            }
                        }
                    }
                }
            }
            else {
                print("loadInfo error")
            }
        }
    }
    
    func queryInfo() {
        let query = PFQuery(className: "Winners")
        query.whereKey("active", equalTo: "yes")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (error == nil) {
                if let objects = objects {
                    for object in objects {
                        if object.valueForKey("number") != nil {
//                            if (number as! String == self.toPass){
//                                self.loadInfo(String(object.valueForKey("username")!))
//                            }
                        }
                    }
                }
            }
            else {
                print("queryInfo error")
            }
        }
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
