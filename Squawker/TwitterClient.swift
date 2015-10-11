//
//  TwitterClient.swift
//  Squawker
//
//  Created by Kenneth Pu on 10/1/15.
//  Copyright © 2015 Kenneth Pu. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let kTwitterConsumerKey = valueForAPIKey("API_KEY")
let kTwitterConsumerSecret = valueForAPIKey("API_SECRET")
let kTwitterBaseUrl = "https://api.twitter.com"

class TwitterClient: BDBOAuth1RequestOperationManager {
    static let sharedInstance = TwitterClient(baseURL: NSURL(string: kTwitterBaseUrl), consumerKey: kTwitterConsumerKey, consumerSecret: kTwitterConsumerSecret)
    
    var loginCompletion:((user: User?, error: NSError?) -> ())?
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        self.loginCompletion = completion
        
        self.requestSerializer.removeAccessToken()
        self.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "kpsquawker://oauth"), scope: nil, success: { (requestCredential: BDBOAuth1Credential!) -> Void in
            let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestCredential.token)")
            UIApplication.sharedApplication().openURL(authURL!)
        }, failure: { (error: NSError!) -> Void in
            print("ERROR: Unable to fetch request token")
            self.loginCompletion?(user: nil, error: error)
        })
    }
    
    func homeTimelineWithCompletion(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        self.GET("1.1/statuses/home_timeline.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            let tweets = Tweet.tweetsWithArray(responseObject as! [NSDictionary])
            completion(tweets: tweets, error: nil)
        }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            print("ERROR: Unable to get home timeline\n\(error)")
            completion(tweets: nil, error: error)
        })
    }
    
    func retweetTweetWithCompletion(idString: String!, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        self.POST("1.1/statuses/retweet/\(idString).json", parameters: nil, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            let tweet = Tweet(dictionary: responseObject as! NSDictionary)
            completion(tweet: tweet, error: nil)
        }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            print("ERROR: Unable to retweet Tweet\n\(error)")
            completion(tweet: nil, error:error)
        })
    }
    
    func favoriteTweetWithCompletion(params: NSDictionary!, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        self.POST("1.1/favorites/create.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            let tweet = Tweet(dictionary: responseObject as! NSDictionary)
            completion(tweet: tweet, error: nil)
        }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            print("ERROR: Unable to favorite Tweet\n\(error)")
            completion(tweet: nil, error:error)
        })
    }
    
    func unfavoriteTweetWithCompletion(params: NSDictionary!, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        self.POST("1.1/favorites/destroy.json", parameters: params, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            let tweet = Tweet(dictionary: responseObject as! NSDictionary)
            completion(tweet: tweet, error: nil)
        }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                print("ERROR: Unable to unfavorite Tweet\n\(error)")
                completion(tweet: nil, error:error)
        })
    }
    
    func tweetWithCompletion(params: NSDictionary?, completion: (tweet: Tweet?, error: NSError?) -> ()){
        self.POST("1.1/statuses/update.json", parameters:params, success: { (operation: AFHTTPRequestOperation!, responseObject:
            AnyObject!) -> Void in
            let tweet = Tweet(dictionary: responseObject as! NSDictionary)
            completion(tweet: tweet, error: nil)
        }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                print("ERROR: Unable to post Tweet\n\(error)")
                completion(tweet: nil, error:error)
        })
    }
    
    func openURL(url: NSURL) {
        if url.absoluteString.containsString("denied") {
            return
        }
        self.fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: {
            (accessToken: BDBOAuth1Credential!) -> Void in
            self.requestSerializer.saveAccessToken(accessToken)
            self.GET("1.1/account/verify_credentials.json", parameters:nil, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                let user = User(dictionary: responseObject as! NSDictionary)
                User.currentUser = user
                self.loginCompletion?(user: user, error: nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                print("ERROR: Unable to verify credentials")
                self.loginCompletion?(user: nil, error: error)
            })
        }, failure: { (error: NSError?) -> Void in
            print("ERROR: Unable to fetch access token")
            self.loginCompletion?(user: nil, error: error)
        })
    }
    
}
