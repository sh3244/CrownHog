//
//  CodeView.swift
//  Spotlight
//
//  Created by Samuel Huang on 1/20/16.
//  Copyright © 2016 Zomero LLC. All rights reserved.
//

import UIKit
import ParseUI
import AudioToolbox
import ParseFacebookUtilsV4
import Darwin

class CodeView: UIViewController {
    @IBOutlet weak var profileButton: UIButton!
    
    @IBOutlet weak var pinOne: UILabel!
    @IBOutlet weak var pinTwo: UILabel!
    @IBOutlet weak var pinThree: UILabel!
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var fourButton: UIButton!
    @IBOutlet weak var fiveButton: UIButton!
    @IBOutlet weak var sixButton: UIButton!
    @IBOutlet weak var sevenButton: UIButton!
    @IBOutlet weak var eightButton: UIButton!
    @IBOutlet weak var nineButton: UIButton!
    
    @IBOutlet weak var hogOne: UIButton!
    @IBOutlet weak var hogTwo: UIButton!
    @IBOutlet weak var hogThree: UIButton!
    
    @IBOutlet weak var hogOneTime: UILabel!
    @IBOutlet weak var hogTwoTime: UILabel!
    @IBOutlet weak var hogThreeTime: UILabel!
    
    @IBOutlet weak var gameComment: UILabel!
    
    var pinIndex = 0
    var winCode = 000
    var didWin:Bool = false
    
    var buttons: [UIButton] = []
    var hogs: [UIButton] = []
    var times: [UILabel] = []
    var pins: [UILabel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if PFUser.currentUser() == nil {
            showLogInPage()
        }
        setupView()
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() == nil {
            showLogInPage()
        }
        changeCode()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showLogInPage() {
        let logInController = HogLogin()
        logInController.fields = PFLogInFields.Facebook
        logInController.delegate = logInController
        self.view.window?.rootViewController!.presentViewController(logInController, animated: true, completion: nil)
    }
    
    //MARK: - Setup Appearance
    
    func setupView() {
        //settings button
        profileButton.setImage(UIImage(named: "settings.png"), forState: UIControlState.Normal)
        profileButton.addTarget(self, action: #selector(CodeView.loadProfile), forControlEvents: .TouchUpInside)
        
        //top logo
        self.navigationItem.titleView = UIImageView.init(image: UIImage(named: "logoMedium.png"))

        self.navigationItem.titleView?.contentMode = .Center
        self.navigationItem.titleView?.contentScaleFactor = 3.0
        
        //setup buttons
        setupInitial()
        setupHogs()
    }
    
    func disable() {
        for button in self.buttons {
            button.enabled = false
        }
    }
    
    func setupHogs() {
        //query for hog situation
        let query = PFQuery(className: "aWinner")
        query.whereKey("dimmed", equalTo: false)
        var count = 0
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if (error == nil) {
                //check if currentuser is a winner
                for result in results! {
                    result.objectForKey("user")?.fetchInBackgroundWithBlock({ (res: PFObject?, err: NSError?) -> Void in
                        if (res?.objectId == PFUser.currentUser()?.objectId) {
                            self.didWin = true
                            self.gameComment.text = "You already won! Post on your crownhog page!"
                            self.disable()
                        }
                    })
                }
                //set active crownhogs
                count = (results?.count)!
                if (count<=3 && count>0) {
                    for i in 0...count-1 {
                        self.hogs[i].enabled = true
                        self.times[i].backgroundColor = Helper.UIColorFromRGB(0x52E8A0)
                        self.times[i].text = "0:01"
                    }
                }
                if (count>=3) {
                    self.disable()
                    self.gameComment.text = "Sorry, there are three crownhogs already!"
                }
            }
        }
        testQuery()
    }
    
    func testQuery() {
        //return currentuser
//        let query = PFQuery(className: "_User")
//        query.whereKey("objectId", equalTo: PFUser.currentUser()!.objectId!)
//        do {
//            let result = try query.findObjects()
//            print(result)
//        }
//        catch {
//            
//        }
        
        //return winners
//        let query = PFQuery(className: "aWinner")
//        query.whereKey("dimmed", equalTo: false)
//        var winArray: [PFObject] = []
//        do {
//            winArray = try query.findObjects()
//        }
//        catch {
//            
//        }
        
        
//        PFCloud.callFunctionInBackground("countWinners", withParameters: ["winner":"The Matrix"]) {
//            (response: AnyObject?, error: NSError?) -> Void in
//            let ratings = response as! Int
//            print(ratings)
//            // ratings is 4.5w
//        }
        
    }
    
    func setupInitial() {
        buttons = [oneButton, twoButton, threeButton, fourButton, fiveButton, sixButton, sevenButton, eightButton, nineButton]
        for button in buttons {
            button.addTarget(self, action: #selector(CodeView.enterCode(_:)), forControlEvents: .TouchUpInside)
            button.tag = Int(button.titleLabel!.text!)!
        }
        pins = [pinOne, pinTwo, pinThree]
        
        hogs = [hogOne, hogTwo, hogThree]
        for hog in hogs {
            hog.imageView?.contentMode = .ScaleAspectFit
            hog.enabled = false
        }
        
        times = [hogOneTime, hogTwoTime, hogThreeTime]
        for time in times {
            time.text = "NO HOG"
        }
    }
    
    //MARK: - Game Functions
    
    func enterCode(sender:UIButton) {
        if (pinIndex == 0) {
            pinOne.text = String(sender.tag)
            pinIndex += 1
        }
        else if (pinIndex == 1) {
            pinTwo.text = String(sender.tag)
            pinIndex += 1
        }
        else if (pinIndex == 2) {
            pinThree.text = String(sender.tag)
            checkWin()
        }
    }
    
    func loadProfile() {
        let settingsView:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(
            "settingsViewController")
        settingsView.modalPresentationStyle = .OverCurrentContext
        self.view.window!.rootViewController!.presentViewController(settingsView, animated: true, completion: nil)
    }
    
    func checkWin() {
        let guess:String = pinOne.text! + pinTwo.text! + pinThree.text!
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//        print(guess,winCode)
        if (guess == String(winCode)) {
            clearCode()
            commitWin()
        }
        else {
            let alert = UIAlertController(title: "Wrong Code!", message: "Try Again...", preferredStyle: .Alert)
            self.presentViewController(alert, animated: true, completion: nil)
            Helper.delay(0.5, closure: { () -> () in
                self.clearCode()
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            
        }
    }
    
    func clearCode() {
        self.pinOne.text = ""
        self.pinTwo.text = ""
        self.pinThree.text = ""
        self.pinIndex = 0
    }
    
    func commitWin() {
        didWin = true
        if (PFUser.currentUser() != nil) {
            let winner = PFObject(className: "aWinner")
            let user = PFUser.currentUser()
            
            winner["user"] = user
            winner["time"] = 999
            winner["dimmed"] = false
            winner["posts"] = 0
            winner.saveInBackground()
        }
        self.gameComment.text = "You already won! Post on your crownhog page!"
        self.disable()
        let alert = UIAlertController(title: "You won!", message: "Now you can post!", preferredStyle: .Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        Helper.delay(2.0, closure: { () -> () in
            self.clearCode()
            self.dismissViewControllerAnimated(true, completion: nil)
            self.pushWinController()
        })
    }
    
    func changeCode() {
        var random:String = ""
        for _ in 0...2 {
            random.appendContentsOf(String(arc4random_uniform(9)+1))
        }
        print(random)
        winCode = Int(random)!
    }

    // MARK: - Navigation

    func pushWinController() {
        let winView:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("winViewController")
        winView.modalPresentationStyle = .OverCurrentContext
        self.view.window!.rootViewController!.presentViewController(winView, animated: true, completion: nil)
        changeCode()
    }
}
