//
//  Settings.swift
//  Spotlight
//
//  Created by Samuel Huang on 1/20/16.
//  Copyright © 2016 Zomero LLC. All rights reserved.
//

import UIKit
import ParseUI
import ParseFacebookUtilsV4

class Settings: UIViewController {
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        setupExtra()
        setupAppearance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupExtra() {
        let blurEffect = UIBlurEffect(style: .Light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        self.view.addSubview(blurEffectView)
        self.view.sendSubviewToBack(blurEffectView)
    }
    
    func setupAppearance() {
        profileView.image = UIImage(data: NSUserDefaults.standardUserDefaults().objectForKey("profileImage") as! NSData)
        profileView.contentMode = .ScaleAspectFit
        
        nameLabel.text = NSUserDefaults.standardUserDefaults().objectForKey("name") as? String
    }
    
    func setupButtons() {
        exitButton.setImage(UIImage(named: "ex.png"), forState: .Normal)
        exitButton.addTarget(self, action: #selector(Settings.exitView), forControlEvents: .TouchUpInside)
        
        logoutButton.addTarget(self, action: #selector(Settings.logout), forControlEvents: .TouchUpInside)
    }
    
    func exitView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logout() {
        PFUser.logOutInBackground()
        FBSDKAccessToken.setCurrentAccessToken(nil)
        if(PFUser.currentUser() == nil) {
            logoutButton.setTitle("Facebook Disconnected", forState: .Normal)
        }
        
        let logInController = HogLogin()
        logInController.fields = PFLogInFields.Facebook
        logInController.delegate = logInController
        
        exitView()
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
