//
//  Personal.swift
//  Spotlight
//
//  Created by Samuel Huang on 1/23/16.
//  Copyright © 2016 Zomero LLC. All rights reserved.
//

import UIKit
import ParseUI
import ParseFacebookUtilsV4

class Personal: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var refresher = UIRefreshControl()
    
    var listImages: [UIImage] = []
    var numberItems: Int = 0
    var listComments: [String] = []
    
    var name: String = ""
    var views: String = ""
    var likes: String = ""
    var image: UIImage?
    var timerCounter:NSTimeInterval = NSTimeInterval(0)
    
    var active: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadData()
        setupAppearance()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
//        updateScore()
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    func setupAppearance() {
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationController?.view.tintColor = UIColor.whiteColor()
        startTimer(1)
        
        if (active) {
            
        }
        else {
            progressView.progress = 1.0
        }
        
        nameLabel.text = name
        viewsLabel.text = views
        likesLabel.text = likes
        profileView.image = image
        
        settingsButton.addTarget(self, action: #selector(Personal.pushExtraController), forControlEvents: .TouchUpInside)
        
        backButton.imageView?.contentMode = .ScaleAspectFit
        backButton.setImage(UIImage(named: "Arrow"), forState: .Normal)
        backButton.addTarget(self, action: #selector(Personal.backAction), forControlEvents: .TouchUpInside)
        
        refresher.backgroundColor = UIColor.greenColor()
        refresher.tintColor = UIColor.blueColor()
        refresher.attributedTitle = NSAttributedString(string: "Help")
        refresher.addTarget(self, action: #selector(Personal.reloads(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refresher)
    }

    //MARK: - Data Functions

    func loadData() {
        queryPosts()
    }

    func reloads(sender: AnyObject) {
        tableView.reloadData()
    }

    func queryPosts() {
        let query = PFQuery(className: "aPost")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.whereKey("dimmed", equalTo: false)
        query.addAscendingOrder("createdAt")
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, err: NSError?) -> Void in
            for post in results! {
                if let image = post.valueForKey("imageFile") {
                    image.getDataInBackgroundWithBlock({ (result: NSData?, error: NSError?) -> Void in
                        if (error == nil) {
                            self.listImages.append(UIImage(data: result!)!)
                            self.numberItems += 1
                            self.listComments.append((post.valueForKey("imageComment") as? String)!)
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        }
    }
    
    //MARK - Table Control
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return numberItems
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (numberItems > indexPath.row) {
            let cell = tableView.dequeueReusableCellWithIdentifier("customCell") as! CustomCell
            cell.nameLabel.text = name
            cell.topLabel.text = String(indexPath.row+1) + "/5"
            cell.postImage.image = listImages[indexPath.row]
            cell.commentLabel.text = listComments[indexPath.row]
            cell.cellIndex = indexPath.row
            return cell
        }
        return CustomCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

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
        if (timerCounter.isNormal) {
            if (seconds==0) {
                timerCounter = NSTimeInterval(9)
            }
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(Personal.onTimer(_:)), userInfo: nil, repeats: true)
        }
    }
    
    @objc func onTimer(timer:NSTimer!) {
        if (!timerCounter.isZero) {
            timerCounter -= 1
        }
        else {
            
        }
        timeLabel.text = stringFromTimeInterval(timerCounter)
    }
    
    // MARK: - Navigation

    func pushWinController() {
        let winView:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("winViewController")
        winView.modalPresentationStyle = .OverCurrentContext
        self.view.window!.rootViewController!.presentViewController(winView, animated: true, completion: nil)
    }
    
    func backAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func pushExtraController() {
        let extraView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("extraViewController") as! SocialView
        extraView.modalPresentationStyle = .OverCurrentContext
        self.view.window!.rootViewController!.presentViewController(extraView, animated: true, completion: nil)
    }
}
