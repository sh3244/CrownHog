//
//  Spotlight.swift
//  Spotlight
//
//  Created by Samuel Huang on 1/20/16.
//  Copyright © 2016 Zomero LLC. All rights reserved.
//

import UIKit
import ParseUI
import ParseFacebookUtilsV4

class Spotlight: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var dimmed: [PFObject] = []
    
    var name: [String!] = []
    var views: [String!] = []
    var likes: [String!] = []
    var image: [UIImage!] = []
    
    var numberItems: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupAppearance()
        queryPosts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {

    }
    
    func setupAppearance() {
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationController?.navigationBarHidden = true
    }
    
    func updateScore() {
        let username: String! = PFUser.currentUser()?.username
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: username)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        if (object.valueForKey("views") == nil) {
                            object["views"] = 0
                            object["likes"] = 0
                            object.saveInBackground()
                        }
                        else {
                            object.incrementKey("views")
                            object.incrementKey("likes")
                            object.saveInBackground()
                        }
                    }
                }
            }
            else {
                print("error in query")
            }
        }
    }
    
    func loadDimmed() {
        for i in 0...dimmed.count-1 {
            self.dimmed[i].objectForKey("user")!.fetchInBackgroundWithBlock({ (result: PFObject?, err: NSError?) -> Void in
                let guy = result!
                
                self.name.append(guy.objectForKey("name") as! String)
                self.views.append(String(guy.objectForKey("views")!))
                self.likes.append(String(guy.objectForKey("likes")!))
                let userImageFile = guy.objectForKey("profileImage") as! PFFile
                userImageFile.getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            self.image.append(UIImage(data: imageData)!)
                            self.numberItems += 1
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
            })
        }
        self.tableView.reloadData()
    }
    
    func queryPosts() {
        let query = PFQuery(className: "aWinner")
        query.whereKey("dimmed", equalTo: true)
//        query.addAscendingOrder("createdAt")
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, err: NSError?) -> Void in
            for post in results! {
                self.dimmed.append(post)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.loadDimmed()
            })
        }
    }
    
    //MARK: - TableViewDelegation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
    
        return dimmed.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let index = indexPath.row
        let cell = tableView.dequeueReusableCellWithIdentifier("dimmedCell") as! DimmedCell
        if (numberItems > index) {
            cell.nameLabel.text = name[index]
            cell.viewsLabel.text = views[index]
            cell.likesLabel.text = likes[index]
            cell.profileView.contentMode = .ScaleAspectFit
            cell.profileView?.image = image[index]
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        pushPersonalController(indexPath.row)
    }
    
    
    // MARK: - Navigation

    func pushPersonalController(index: Int) {
        let personalView:Personal = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("personalViewController") as! Personal
//        personalView.timerCounter = self.timerCounter
        personalView.name = name[index]
        personalView.views = views[index]
        personalView.likes = likes[index]
        personalView.image = image[index]
        self.navigationController?.delegate = self
        self.navigationController?.pushViewController(personalView, animated: true)
    }
}
