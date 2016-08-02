//
//  Pages.swift
//  Spotlight
//
//  Created by Samuel Huang on 1/25/16.
//  Copyright © 2016 Zomero LLC. All rights reserved.
//

import UIKit
import Parse

class Pages: UIPageViewController, UIPageViewControllerDataSource {
    
    var currentIndex: Int = 0
    
    private(set) var orderedViewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupView()
    }
    
    func setupView() {
        dataSource = self
        
        for i in 0...2 {
            let temporary:HogPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("hogPage") as! HogPage
            temporary.pageNo = i+1
            orderedViewControllers.append(temporary)
        }
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                direction: .Forward,
                animated: true,
                completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }
            
            currentIndex = viewControllerIndex
            
            let previousIndex = viewControllerIndex - 1
            
            guard previousIndex >= 0 else {
                return nil
            }
            
            guard orderedViewControllers.count > previousIndex else {
                return nil
            }
            
            return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }
            
            currentIndex = viewControllerIndex
            
            let nextIndex = viewControllerIndex + 1
            
            let orderedViewControllersCount = orderedViewControllers.count
            
            guard orderedViewControllersCount != nextIndex else {
                return nil
            }
            
            guard orderedViewControllersCount > nextIndex else {
                return nil
            }
            
            return orderedViewControllers[nextIndex]
    }
    
//    func presentationCountForPages(pageViewController: UIPages) -> Int {
//        return orderedViewControllers.count
//    }
//    
//    func presentationIndexForPages(pageViewController: UIPages) -> Int {
//        guard let firstViewController = viewControllers?.first,
//            firstViewControllerIndex = orderedViewControllers.indexOf(firstViewController) else {
//                return 0
//        }
//        
//        return firstViewControllerIndex
//    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
