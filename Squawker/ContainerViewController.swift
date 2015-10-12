//
//  ContainerViewController.swift
//  Squawker
//
//  Created by Kenneth Pu on 10/11/15.
//  Copyright © 2015 Kenneth Pu. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

    @IBOutlet private weak var menuView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet private weak var containerNavigationItem: UINavigationItem!
    
    private var selectedViewController: UIViewController!
    private var profileVC: UserDetailsViewController!
    private var timelineVC: TweetsViewController!
    
    private var menuClosedX: CGFloat!
    private var menuOpenX: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true
        
        profileVC = storyboard!.instantiateViewControllerWithIdentifier("profileVC") as! UserDetailsViewController
        profileVC.user = User.currentUser
        
        timelineVC = storyboard!.instantiateViewControllerWithIdentifier("TimelineVC") as! TweetsViewController
        timelineVC.mode = "Home"
        
        updateUI()
        
        selectViewController(timelineVC)
    }
    
    private func updateUI() {
        if User.currentUser != nil {
            let request = NSURLRequest(URL: (User.currentUser!.profileImageURL)!)
            weak var weakIV = profileImageView
            profileImageView.setImageWithURLRequest(request, placeholderImage: nil, success: { (request, response, image) -> Void in
                weakIV!.image = image
                if (response != nil && response!.statusCode != 0) {
                    weakIV!.alpha = 0.0
                    UIView.animateWithDuration(0.5) {
                        weakIV!.alpha = 1.0
                    }
                }
            }, failure: nil)
            fullNameLabel.text = User.currentUser!.name!
            userNameLabel.text = "@\(User.currentUser!.screenName!)"
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        menuOpenX = menuView.frame.size.width / 2
        menuClosedX = -menuView.frame.size.width / 2
    }
    
    private func selectViewController(viewController: UIViewController) {
        containerNavigationItem.title = viewController.navigationItem.title
        if let oldViewController = selectedViewController {
            if oldViewController == viewController {
                return
            }
            oldViewController.willMoveToParentViewController(nil)
            oldViewController.view.removeFromSuperview()
            oldViewController.removeFromParentViewController()
        }
        self.addChildViewController(viewController)
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        containerView.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
        selectedViewController = viewController
    }
    
    @IBAction func onPan(panGestureRecognizer: UIPanGestureRecognizer) {
        let velocity = panGestureRecognizer.velocityInView(view)
        
        if panGestureRecognizer.state == UIGestureRecognizerState.Began {
            if velocity.x > 0 {
                UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 5, options: [], animations: { () -> Void in
                        self.menuView.center = CGPointMake(self.menuOpenX, self.menuView.center.y)
                }, completion: nil)
            } else {
                UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 5, options: [], animations: { () -> Void in
                    self.menuView.center = CGPointMake(self.menuClosedX, self.menuView.center.y)
                    }, completion: nil)
            }
        }
    }
    @IBAction func onProfilePressed(sender: AnyObject) {
        selectViewController(profileVC)
    }
    
    @IBAction func onHomePressed(sender: AnyObject) {
        timelineVC.mode = "Home"
        selectViewController(timelineVC)
    }
    
    @IBAction func onMentionsPressed(sender: AnyObject) {
        timelineVC.mode = "Mentions"
        selectViewController(timelineVC)
    }
}
