//
//  Tabs.swift
//  Spotlight
//
//  Created by Samuel Huang on 1/20/16.
//  Copyright © 2016 Zomero LLC. All rights reserved.
//

import UIKit

class Tabs: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.selectedIndex = 0
        
        let swipeLeft = UISwipeGestureRecognizer.init(target: self, action: "swipeLeft:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer.init(target: self, action: "swipeRight:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func swipeRight(recognizer: UISwipeGestureRecognizer) {
        if (recognizer.direction == .Right) {
            if (self.selectedIndex == 1) {
                Helper.delay(0.3) {
                    self.selectedIndex--
                }
            }
        }
    }
    
    func swipeLeft(recognizer: UISwipeGestureRecognizer) {
        if (recognizer.direction == .Left) {
            if (self.selectedIndex == 0) {
                Helper.delay(0.3) {
                    self.selectedIndex++
                }
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