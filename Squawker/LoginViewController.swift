//
//  LoginViewController.swift
//  
//
//  Created by Kenneth Pu on 10/1/15.
//
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onLogin(sender: AnyObject) {
        TwitterClient.sharedInstance.loginWithCompletion { (user: User?, error: NSError?) -> () in
            if user != nil {
                self.performSegueWithIdentifier("loginSegue", sender: self)
            } else {
                print("ERROR: \(error)")
            }
        }
    }
}
