//
//  User.swift
//  Squawker
//
//  Created by Kenneth Pu on 10/3/15.
//  Copyright © 2015 Kenneth Pu. All rights reserved.
//

import UIKit

var _currentUser: User?
let currentUserKey = "kCurrentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User: NSObject {
    var dictionary: NSDictionary
    var name:String?
    var screenName: String?
    var profileImageURL: NSURL?
    var profileBannerImageURL: NSURL?
    var tagLine: String?
    var numTweets: Int?
    var numFollowing: Int?
    var numFollowers: Int?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        let profileImageURLString = dictionary["profile_image_url"] as? String
        if profileImageURLString != nil {
            profileImageURL = NSURL(string: profileImageURLString!.stringByReplacingOccurrencesOfString("_normal", withString: "_bigger"))
        }
        let profileBannerImageURLString = dictionary["profile_banner_url"] as? String
        if profileBannerImageURLString != nil {
            profileBannerImageURL = NSURL(string: profileBannerImageURLString!)
        }
        tagLine = dictionary["description"] as? String
        numTweets = dictionary["statuses_count"] as? Int
        numFollowing = dictionary["friends_count"] as? Int
        numFollowers = dictionary["followers_count"] as? Int
    }
    
    func logout() {
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
    }
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
                if data != nil {
                    do {
                        let dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                        _currentUser = User(dictionary: dictionary)
                    } catch let error as NSError {
                        print("JSON Error: \(error)")
                    }
                }
            }
            return _currentUser
        }
        
        set(user) {
            _currentUser = user
            
            if _currentUser != nil {
                do {
                    let data = try NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: [])
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
                } catch let error as NSError {
                    print("JSON Error: \(error)")
                }
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}
