//
//  Tweet.swift
//  Squawker
//
//  Created by Kenneth Pu on 10/3/15.
//  Copyright © 2015 Kenneth Pu. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var dictionary: NSDictionary
    var idString: String!
    var author: User?
    var text: String?
    var createdAt: NSDate?
    var retweeted: Bool?
    var retweetCount: Int?
    var favorited: Bool?
    var favoriteCount: Int?
    var retweetedStatus: Tweet?
    var mediaURL: NSURL?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        idString = dictionary["id_str"] as! String
        author = User(dictionary: dictionary["user"] as! NSDictionary)
        text = dictionary["text"] as? String
        let createdAtString = dictionary["created_at"] as? String
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAt = formatter.dateFromString(createdAtString!)
        retweeted = dictionary["retweeted"] as? Bool
        retweetCount = dictionary["retweet_count"] as? Int
        favorited = dictionary["favorited"] as? Bool
        favoriteCount = dictionary["favorite_count"] as? Int
        if let retweetDict = dictionary["retweeted_status"] as? NSDictionary {
            retweetedStatus = Tweet(dictionary: retweetDict)
        }
        let mediaList = dictionary.valueForKeyPath("entities.media") as? NSArray
        let mediaDict = mediaList?.firstObject as? NSDictionary
        let mediaURLString = mediaDict?["media_url"] as? String
        if mediaURLString != nil {
            mediaURL = NSURL(string: mediaURLString!)
        }
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        return tweets
    }
}
