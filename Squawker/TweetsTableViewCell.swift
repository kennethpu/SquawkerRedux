//
//  TweetsTableViewCell.swift
//  Squawker
//
//  Created by Kenneth Pu on 10/4/15.
//  Copyright © 2015 Kenneth Pu. All rights reserved.
//

import UIKit

protocol TweetsTableViewCellDelegate {
    func handleTweetUpdatedForCell(tweet: Tweet, cell: TweetsTableViewCell)
    func callSegueFromCell(tweet: Tweet)
}

let retweetedColor: UIColor = UIColor(red: 102.0/255, green: 167.0/255, blue: 68.0/255, alpha: 1.0)
let favoritedColor: UIColor = UIColor(red: 253.0/255, green: 156.0/255, blue: 40.0/255, alpha: 1.0)
let defaultColor: UIColor = UIColor(red: 102.0/255, green: 117.0/255, blue: 127.0/255, alpha: 1.0)

class TweetsTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    var delegate: TweetsTableViewCellDelegate?
    
    var tweet: Tweet! {
        didSet {
            let request = NSURLRequest(URL: (tweet.author?.profileImageURL)!)
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
            fullNameLabel.text = tweet.author?.name
            usernameLabel.text = "@\(tweet.author!.screenName!)"
            timestampLabel.text = self.formatTimeElapsed(tweet.createdAt!)
            tweetTextLabel.text = tweet.text
            retweetButton.selected = tweet.retweeted!
            retweetCountLabel.text = "\(tweet.retweetCount!)"
            retweetCountLabel.textColor = retweetButton.selected ? retweetedColor : defaultColor
            favoriteButton.selected = tweet.favorited!
            favoriteCountLabel.text = "\(tweet.favoriteCount!)"
            favoriteCountLabel.textColor = favoriteButton.selected ? favoritedColor : defaultColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true
    }
    
    func formatTimeElapsed(sinceDate: NSDate) -> String {
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Abbreviated
        formatter.collapsesLargestUnit = true
        formatter.maximumUnitCount = 1
        let interval = NSDate().timeIntervalSinceDate(sinceDate)
        return formatter.stringFromTimeInterval(interval)!
    }
    
    @IBAction func replyTapped(sender: AnyObject) {
        self.delegate?.callSegueFromCell(tweet)
    }
    
    @IBAction func retweetTapped(sender: AnyObject) {
        TwitterClient.sharedInstance.retweetTweetWithCompletion(tweet.idString!, completion: { (tweet: Tweet?, error: NSError?) -> () in
            if tweet != nil {
                self.retweetButton.selected = tweet!.retweeted!
                self.retweetCountLabel.text = "\(tweet!.retweetCount!)"
                self.retweetCountLabel.textColor = retweetedColor
                
                self.tweet.retweetCount = tweet!.retweetCount!
                self.tweet.retweeted = tweet!.retweeted!
                self.tweet.favoriteCount = tweet!.favoriteCount!
                self.delegate?.handleTweetUpdatedForCell(self.tweet, cell: self)
            }
        })
    }
    
    @IBAction func favoriteTapped(sender: AnyObject) {
        if favoriteButton.selected {
            unfavoriteTweet(tweet.idString)
        } else {
            favoriteTweet(tweet.idString)
        }
    }
    
    func favoriteTweet(idString: String!) {
        let params : NSDictionary = ["id": idString]
        TwitterClient.sharedInstance.favoriteTweetWithCompletion(params, completion: { (tweet: Tweet?, error: NSError?) -> () in
            if tweet != nil {
                self.tweet = tweet!
                self.delegate?.handleTweetUpdatedForCell(tweet!, cell: self)
            }
        })
    }
    
    func unfavoriteTweet(idString: String!) {
        let params : NSDictionary = ["id": idString]
        TwitterClient.sharedInstance.unfavoriteTweetWithCompletion(params, completion: { (tweet: Tweet?, error: NSError?) -> () in
            if tweet != nil {
                self.tweet = tweet!
                self.delegate?.handleTweetUpdatedForCell(tweet!, cell: self)
            }
        })
    }
}
