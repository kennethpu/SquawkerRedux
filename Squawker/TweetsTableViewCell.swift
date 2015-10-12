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
    func callComposeSegueFromCell(tweet: Tweet)
    func callUserSegueFromCell(user: User)
}

let retweetedColor: UIColor = UIColor(red: 102.0/255, green: 167.0/255, blue: 68.0/255, alpha: 1.0)
let favoritedColor: UIColor = UIColor(red: 253.0/255, green: 156.0/255, blue: 40.0/255, alpha: 1.0)
let defaultColor: UIColor = UIColor(red: 102.0/255, green: 117.0/255, blue: 127.0/255, alpha: 1.0)

class TweetsTableViewCell: UITableViewCell {

    @IBOutlet private weak var retweetedView: UIView!
    @IBOutlet private weak var retweetedViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var retweetedLabel: UILabel!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var timestampLabel: UILabel!
    @IBOutlet private weak var tweetTextLabel: UILabel!
    @IBOutlet private weak var mediaView: UIView!
    @IBOutlet private weak var mediaViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var mediaImageView: UIImageView!
    @IBOutlet private weak var retweetButton: UIButton!
    @IBOutlet private weak var retweetCountLabel: UILabel!
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var favoriteCountLabel: UILabel!
    
    var delegate: TweetsTableViewCellDelegate?
    
    private var sourceTweet: Tweet!
    
    var tweet: Tweet! {
        didSet {
            let isRetweet = tweet.retweetedStatus != nil
            sourceTweet = isRetweet ? tweet.retweetedStatus : tweet
            
            if isRetweet {
                retweetedView.hidden = false
                retweetedViewHeightConstraint.constant = 30
                retweetedLabel.text = "\(tweet.author!.name!) Retweeted"
            } else {
                retweetedView.hidden = true
                retweetedViewHeightConstraint.constant = 8
            }
            
            let request = NSURLRequest(URL: (sourceTweet.author?.profileImageURL)!)
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
            
            fullNameLabel.text = sourceTweet.author?.name
            usernameLabel.text = "@\(sourceTweet.author!.screenName!)"
            timestampLabel.text = self.formatTimeElapsed(sourceTweet.createdAt!)
            tweetTextLabel.text = sourceTweet.text
            
            if sourceTweet.mediaURL != nil {
                mediaView.hidden = false
                mediaViewHeightConstraint.constant = 166
                let request = NSURLRequest(URL: (sourceTweet.mediaURL)!)
                weak var weakIV = mediaImageView
                mediaImageView.setImageWithURLRequest(request, placeholderImage: nil, success: { (request, response, image) -> Void in
                    weakIV!.image = image
                    if (response != nil && response!.statusCode != 0) {
                        weakIV!.alpha = 0.0
                        UIView.animateWithDuration(0.5) {
                            weakIV!.alpha = 1.0
                        }
                    }
                }, failure: nil)
            } else {
                mediaView.hidden = true
                mediaViewHeightConstraint.constant = 8
            }
            
            retweetButton.selected = sourceTweet.retweeted!
            retweetCountLabel.text = "\(sourceTweet.retweetCount!)"
            retweetCountLabel.textColor = retweetButton.selected ? retweetedColor : defaultColor
            favoriteButton.selected = sourceTweet.favorited!
            favoriteCountLabel.text = "\(sourceTweet.favoriteCount!)"
            favoriteCountLabel.textColor = favoriteButton.selected ? favoritedColor : defaultColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "profileImageTapped:"))
        profileImageView.userInteractionEnabled = true
        
        mediaImageView.layer.cornerRadius = 5
        mediaImageView.contentMode = UIViewContentMode.ScaleAspectFill
        mediaImageView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.cancelImageRequestOperation()
        profileImageView.image = nil
        
        mediaImageView.cancelImageRequestOperation()
        mediaImageView.image = nil
    }
    
    private func formatTimeElapsed(sinceDate: NSDate) -> String {
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Abbreviated
        formatter.collapsesLargestUnit = true
        formatter.maximumUnitCount = 1
        let interval = NSDate().timeIntervalSinceDate(sinceDate)
        return formatter.stringFromTimeInterval(interval)!
    }
    
    @IBAction func replyTapped(sender: AnyObject) {
        self.delegate?.callComposeSegueFromCell(tweet)
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
    
    private func favoriteTweet(idString: String!) {
        let params : NSDictionary = ["id": idString]
        TwitterClient.sharedInstance.favoriteTweetWithCompletion(params, completion: { (tweet: Tweet?, error: NSError?) -> () in
            if tweet != nil {
                self.tweet = tweet!
                self.delegate?.handleTweetUpdatedForCell(tweet!, cell: self)
            }
        })
    }
    
    private func unfavoriteTweet(idString: String!) {
        let params : NSDictionary = ["id": idString]
        TwitterClient.sharedInstance.unfavoriteTweetWithCompletion(params, completion: { (tweet: Tweet?, error: NSError?) -> () in
            if tweet != nil {
                self.tweet = tweet!
                self.delegate?.handleTweetUpdatedForCell(tweet!, cell: self)
            }
        })
    }
    
    func profileImageTapped(gesture: UIGestureRecognizer!) {
        self.delegate?.callUserSegueFromCell(sourceTweet.author!)
    }
}
