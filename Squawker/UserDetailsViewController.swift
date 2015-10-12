//
//  UserDetailsViewController.swift
//  Squawker
//
//  Created by Kenneth Pu on 10/11/15.
//  Copyright © 2015 Kenneth Pu. All rights reserved.
//

import UIKit

class UserDetailsViewController: UIViewController {

    @IBOutlet private weak var profileBannerImageView: UIImageView!
    @IBOutlet private weak var profileView: UIView!
    @IBOutlet private weak var profileBorderView: UIView!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var numTweetsLabel: UILabel!
    @IBOutlet private weak var numFollowingLabel: UILabel!
    @IBOutlet private weak var numFollowersLabel: UILabel!
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileBannerImageView.contentMode = UIViewContentMode.ScaleAspectFill
        profileBannerImageView.clipsToBounds = true
        
        profileView.layer.cornerRadius = 5
        profileView.clipsToBounds = true
        
        profileBorderView.layer.cornerRadius = 5
        profileBorderView.clipsToBounds = true
        profileBorderView.layer.borderColor = UIColor(red: 204.0/255, green: 214.0/255, blue: 221.0/255, alpha: 1).CGColor
        profileBorderView.layer.borderWidth = 1
        
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
        
        updateUI()
    }
    
    private func updateUI() {
        let request = NSURLRequest(URL: (user.profileImageURL)!)
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
        
        if user.profileBannerImageURL != nil {
            let request = NSURLRequest(URL: (user.profileBannerImageURL)!)
            weak var weakIV = profileBannerImageView
            profileBannerImageView.setImageWithURLRequest(request, placeholderImage: nil, success: { (request, response, image) -> Void in
                weakIV!.image = image
                if (response != nil && response!.statusCode != 0) {
                    weakIV!.alpha = 0.0
                    UIView.animateWithDuration(0.5) {
                        weakIV!.alpha = 1.0
                    }
                }
            }, failure: nil)
        }
        
        fullNameLabel.text = user.name!
        usernameLabel.text = "@\(user.screenName!)"
        numTweetsLabel.text = abbrevNumString(user.numTweets!)
        numFollowingLabel.text = abbrevNumString(user.numFollowing!)
        numFollowersLabel.text = abbrevNumString(user.numFollowers!)
    }
    
    private func abbrevNumString(int: Int) -> String {
        if int < 1000 {
            return "\(int)"
        }
        
        let num:Double = Double(int)
        let exp:Int = Int(log10(num) / log10(1000));
        let units:[String] = ["K","M","G","T","P","E"];

        let roundedNum:Double = round(10.0 * num / pow(1000.0,Double(exp))) / 10;
        
        return "\(roundedNum)\(units[exp-1])";
    }
}
