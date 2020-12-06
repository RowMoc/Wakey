//
//  WalkThroughPageVC.swift
//  Wakey
//
//  Created by Rowan Mockler on 2020/06/12.
//  Copyright © 2020 Wakey. All rights reserved.
//

import UIKit

protocol WalkThroughPageViewControllerDelegate: class {
    func didUpdatePageIndex(currentIndex: Int)
}

class WalkThroughPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // MARK: - Properties
    
    weak var walkthroughDelegate: WalkThroughPageViewControllerDelegate?
    
    var pageHeadings = ["WELCOME TO WAKEY", "SEND WAKEYS", "RECEIVE WAKEYS", "BED TIME?","ALLOW NOTIFICATIONS"]
    var pageImages = ["onboarding-1", "onboarding-2", "onboarding-3","Not necessary","onboarding-4"]
    var pageSubHeadings = ["Wakey is an alarm app with a twist! On wakey, your friends curate the alarm that wakes you up in the morning, and you help curate theirs. Here's how it works...", "Record a Wakey from the home screen and send it to friends. It'll be the audio that wakes them up the next time they set an alarm on Wakey!", "Set an alarm on Wakey from the home screen just before bed. You'll then be woken up by the Wakeys that your friends have sent you!","Select the time you usually go to bed so we can remind you to set your alarm!", "In order for you to be able to set your alarm on Wakey, you'll need to allow notifications!"]
    
    var currentIndex = 0
    var vcs: [UIViewController]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the data source and the delegate to itself
        dataSource = self
        delegate = self
        vcs = [contentViewController(at: 0),contentViewController(at: 1),contentViewController(at: 2),reminderViewController(at: 3), contentViewController(at: 4)]
        //reminderWalkThroughDelegate
        
        
        
        // Create the first walkthrough screen
            //setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        setViewControllers([vcs[0]], direction: .forward, animated: true, completion: nil)
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index: Int = 0
        if let vc = viewController as? StandardWalkThroughContentVC {
            index = vc.index
        } else if let vc = viewController as? ReminderWalkThroughContentVC {
            index = vc.index
        }
        index -= 1
        if index < 0 || index >= vcs.count {
            return nil
        }
        return vcs[index]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index: Int = 0
        if let vc = viewController as? StandardWalkThroughContentVC {
            index = vc.index
        } else if let vc = viewController as? ReminderWalkThroughContentVC {
            index = vc.index
        }
        index += 1
        if index < 0 || index >= vcs.count {
            return nil
        }
        return vcs[index]
    }
    
    // MARK: - Helper
    func reminderViewController(at index: Int) -> ReminderWalkThroughContentVC {
        // Create a new view controller and pass suitable data
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let pageContentViewController = storyboard.instantiateViewController(withIdentifier: "ReminderWalkThroughContentVC") as! ReminderWalkThroughContentVC
        pageContentViewController.heading = pageHeadings[index]
        pageContentViewController.subHeading = pageSubHeadings[index]
        pageContentViewController.index = index
        return pageContentViewController
    }
    
    func contentViewController(at index: Int) -> StandardWalkThroughContentVC {
        // Create a new view controller and pass suitable data
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let pageContentViewController = storyboard.instantiateViewController(withIdentifier: "StandardWalkThroughContentVC") as! StandardWalkThroughContentVC
        pageContentViewController.imageFile = pageImages[index]
        pageContentViewController.heading = pageHeadings[index]
        pageContentViewController.subHeading = pageSubHeadings[index]
        pageContentViewController.index = index
        return pageContentViewController
    }
    
    func forwardPage() {
        currentIndex += 1
        setViewControllers([vcs[currentIndex]], direction: .forward, animated: true, completion: nil)
    }
    
    // MARK: - Page View Controller delegate
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let contentViewController = pageViewController.viewControllers?.first as? StandardWalkThroughContentVC {
                currentIndex = contentViewController.index
                
                walkthroughDelegate?.didUpdatePageIndex(currentIndex: currentIndex)
            } else if let contentViewController =  pageViewController.viewControllers?.first as? ReminderWalkThroughContentVC {
                currentIndex = contentViewController.index
                walkthroughDelegate?.didUpdatePageIndex(currentIndex: currentIndex)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
