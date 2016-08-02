//
//  HogPage.swift
//  Spotlight
//
//  Created by Samuel Huang on 1/26/16.
//  Copyright © 2016 Zomero LLC. All rights reserved.
//

import UIKit
import ParseUI
import ParseFacebookUtilsV4
import FBSDKLoginKit

class HogPage: UIViewController, UINavigationControllerDelegate{
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var postsLabel: UILabel!
    
    var pageNo: Int!
    var user: String!
    var name: String!
    var active: Bool = false
    var timerCounter:NSTimeInterval!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadInfo()
        setupAppearance()
    }
    
    override func viewDidDisappear(animated: Bool) {
//        Refreshes data when scrolled, extra set of queries
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupAppearance() {
        setActive()
    }
    
    func setActive() {
        let fingerTap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: "singleTap:")
        self.view.addGestureRecognizer(fingerTap)
    }
    
    //MARK: - Data Functions
    
    func loadInfo() {
        let query = PFQuery(className: "aWinner")
        query.whereKey("dimmed", equalTo: false)
        query.addDescendingOrder("createdAt")
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if (error == nil) {
                results![self.pageNo-1].objectForKey("user")!.fetchInBackgroundWithBlock({ (result: PFObject?, err: NSError?) -> Void in
                    let guy = result!
                    
                    self.active = true
                    self.nameLabel.text = guy.objectForKey("name") as? String
                    self.viewsLabel.text = String(guy.objectForKey("views")!)
                    self.likesLabel.text = String(guy.objectForKey("likes")!)
                    
                    let userImageFile = guy.objectForKey("profileImage") as! PFFile
                    userImageFile.getDataInBackgroundWithBlock {
                        (imageData: NSData?, error: NSError?) -> Void in
                        if error == nil {
                            if let imageData = imageData {
                                self.profileView.image = UIImage(data: imageData)
                            }
                        }
                    }
//                  self.timerLabel.text =
                })
                //set timer stuff
                let date = NSDate()
                if (60*60*2-Int(date.timeIntervalSinceDate(results![self.pageNo-1].createdAt!)) > 0) {
                    self.startTimer(60*60*2-Int(date.timeIntervalSinceDate(results![self.pageNo-1].createdAt!)))
                }
                else {
                    let object = results![self.pageNo-1] as PFObject
                    object.setValue(true, forKey: "dimmed")
                    object.saveInBackground()
                    print("dimmed expired crownhog")
                }
                //set posts stuff
                print(String(results![self.pageNo].objectForKey("posts") as! Int), results![self.pageNo].objectForKey("posts") as! Int)
                self.postsLabel.text = String(results![self.pageNo].objectForKey("posts") as! Int)
            }
            else {
                print("error hogpage")
            }
        }
    }
    
    //MARK: - Timer
    
    func stringFromTimeInterval(interval: NSTimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%2d:%02d:%02d", hours, minutes, seconds)
    }
    
    func startTimer(seconds:Int) {
        timerCounter = NSTimeInterval(seconds)
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "onTimer:", userInfo: nil, repeats: true)
    }
    
    @objc func onTimer(timer:NSTimer!) {
        if (!timerCounter.isZero) {
            timerCounter!--
        }
        else {
            
        }
        timerLabel.text = stringFromTimeInterval(timerCounter)
    }

    // MARK: - Navigation

    func singleTap(recognizer: UITapGestureRecognizer) {
        if (self.timerCounter > 0.0) {
            pushPersonalController()
        }
        else {
            loadInfo()
        }
    }
    
    func pushPersonalController() {
        let personalView:Personal = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("personalViewController") as! Personal
        personalView.timerCounter = self.timerCounter
        personalView.name = nameLabel.text!
        personalView.views = viewsLabel.text!
        personalView.likes = likesLabel.text!
        personalView.image = profileView.image
        personalView.postsLabel.text = postsLabel.text
        let count = Int(postsLabel.text!)
        if (count >= 5) {
            personalView.active = false
        }
        else {
            personalView.active = true
        }
        self.navigationController?.delegate = self
        self.navigationController?.pushViewController(personalView, animated: true)
    }
}
