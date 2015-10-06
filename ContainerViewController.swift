//
//  ContainerViewController.swift
//  Cwitter
//
//  Created by Kushal Bhatt on 10/4/15.
//  Copyright © 2015 Kushal Bhatt. All rights reserved.
//

import UIKit


class ContainerViewController: UIViewController {
    
    var homeNavigationController: UINavigationController!
    var homeViewController: HomeViewController!
    
    var leftNavExpanded : Bool = false {
        didSet {
            showShadowForCenterViewController(leftNavExpanded)
        }
    }
    
    var leftViewController: SidePanelViewController?
    let centerPanelExpandedOffset: CGFloat = 60

    override func viewDidLoad() {
        super.viewDidLoad()
        

        homeViewController = UIStoryboard.homeViewController()
        homeViewController.delegate = self
        
        homeNavigationController = UIStoryboard.homeNavigationController()
        homeNavigationController.setViewControllers( [homeViewController], animated: true)
        
        view.addSubview(homeNavigationController.view)
        addChildViewController(homeNavigationController)
        homeNavigationController.didMoveToParentViewController(self)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        homeNavigationController.view.addGestureRecognizer(panGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

extension ContainerViewController: HomeViewControllerDelegate {
    
    func addLeftPanelViewController() {
        if (leftViewController == nil) {
            leftViewController = UIStoryboard.leftViewController()
            leftViewController!.delegate = homeViewController
            addChildSidePanelController(leftViewController!)
        }
    }
    
    func addChildSidePanelController(sidePanelController: SidePanelViewController) {
        view.insertSubview(sidePanelController.view, atIndex: 0)
        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }
    
    func animateLeftPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            leftNavExpanded = true
            
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(homeNavigationController.view.frame) - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.leftNavExpanded = false
                self.leftViewController!.view.removeFromSuperview()
                self.leftViewController = nil;
            }
        }
    }
    
    func animateCenterPanelXPosition(targetPosition position: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.homeNavigationController.view.frame.origin.x = position
            }, completion: completion)
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            homeNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            homeNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    
    func collapseSidePanels() {
        if(leftNavExpanded) {
            animateLeftPanel(false)
        }
        
    }
    
}

extension ContainerViewController: UIGestureRecognizerDelegate {
    // MARK: Gesture recognizer
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        switch(recognizer.state) {
        case .Began:
            if (!leftNavExpanded) {
                if (gestureIsDraggingFromLeftToRight) {
                    addLeftPanelViewController()
                }
                //showShadowForCenterViewController(true)
            }
        case .Changed:
            recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
            recognizer.setTranslation(CGPointZero, inView: view)
        case .Ended:
            if (leftViewController != nil) {
                //animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                animateLeftPanel(hasMovedGreaterThanHalfway)
            }
        default:
            break
        }
    }
    
}

extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func leftViewController() -> SidePanelViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("MenuViewController") as? SidePanelViewController
    }
    
    class func homeViewController() -> HomeViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("HomeViewController") as? HomeViewController
    }
    
    class func homeNavigationController() -> UINavigationController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("HomeNavigationController") as! UINavigationController
    }
    
}
