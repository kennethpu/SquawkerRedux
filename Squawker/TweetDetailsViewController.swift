//
//  TweetDetailsViewController.swift
//  Squawker
//
//  Created by Kenneth Pu on 10/4/15.
//  Copyright © 2015 Kenneth Pu. All rights reserved.
//

import UIKit

protocol TweetDetailsViewControllerDelegate {
    func handleTweetUpdatedForViewController(tweet: Tweet, index: Int)
    func callSegueFromViewController(tweet: Tweet)
}

class TweetDetailsViewController: UIViewController {

    @IBOutlet private weak var retweetedView: UIView!
    @IBOutlet private weak var retweetedViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var retweetedLabel: UILabel!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var fullNameLabel: UILabel!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var tweetTextLabel: UILabel!
    @IBOutlet private weak var mediaView: UIView!
    @IBOutlet private weak var mediaViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var mediaImageView: UIImageView!
    @IBOutlet private weak var timeStampLabel: UILabel!
    @IBOutlet private weak var retweetCountLabel: UILabel!
    @IBOutlet private weak var retweetsLabel: UILabel!
    @IBOutlet private weak var favoriteCountLabel: UILabel!
    @IBOutlet private weak var favoritesLabel: UILabel!
    @IBOutlet private weak var retweetButton: UIButton!
    @IBOutlet private weak var favoriteButton: UIButton!
    
    var tweet: Tweet!
    var index: Int!
    var delegate: TweetDetailsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true
        
        mediaImageView.layer.cornerRadius = 5
        mediaImageView.contentMode = UIViewContentMode.ScaleAspectFill
        mediaImageView.clipsToBounds = true
        
        updateUI()
    }
    
    private func updateUI() {
        let isRetweet = tweet.retweetedStatus != nil
        let sourceTweet = isRetweet ? tweet.retweetedStatus : tweet
        
        if isRetweet {
            retweetedView.hidden = false
            retweetedViewHeightConstraint.constant = 40
            retweetedLabel.text = "\(tweet.author!.name!) Retweeted"
        } else {
            retweetedView.hidden = true
            retweetedViewHeightConstraint.constant = 20
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
        tweetTextLabel.text = sourceTweet.text
        
        if sourceTweet.mediaURL != nil {
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
        
        timeStampLabel.text = self.formatTimestamp(sourceTweet.createdAt!)
        let retweetCount = sourceTweet.retweetCount!
        retweetCountLabel.text = "\(retweetCount)"
        retweetsLabel.text = retweetCount == 1 ? "RETWEET" : "RETWEETS"
        let favoriteCount = sourceTweet.favoriteCount!
        favoriteCountLabel.text = "\(favoriteCount)"
        favoritesLabel.text = favoriteCount == 1 ? "FAVORITE" : "FAVORITES"
        retweetButton.selected = sourceTweet.retweeted!
        favoriteButton.selected = sourceTweet.favorited!
    }
    
    private func formatTimestamp(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "h:mm a - d MMM y"
        return formatter.stringFromDate(date)
    }
    
    @IBAction func replyTapped(sender: AnyObject) {
        self.delegate?.callSegueFromViewController(tweet)
    }
    
    @IBAction func retweetTapped(sender: AnyObject) {
        TwitterClient.sharedInstance.retweetTweetWithCompletion(tweet.idString!, completion: { (tweet: Tweet?, error: NSError?) -> () in
            if tweet != nil {
                self.retweetButton.selected = tweet!.retweeted!
                self.retweetCountLabel.text = "\(tweet!.retweetCount!)"
                
                self.tweet.retweetCount = tweet!.retweetCount!
                self.tweet.retweeted = tweet!.retweeted!
                self.tweet.favoriteCount = tweet!.favoriteCount!
                self.delegate?.handleTweetUpdatedForViewController(self.tweet, index: self.index)
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
                self.updateUI()
                self.delegate?.handleTweetUpdatedForViewController(tweet!, index: self.index)
            }
        })
    }
    
    private func unfavoriteTweet(idString: String!) {
        let params : NSDictionary = ["id": idString]
        TwitterClient.sharedInstance.unfavoriteTweetWithCompletion(params, completion: { (tweet: Tweet?, error: NSError?) -> () in
            if tweet != nil {
                self.tweet = tweet!
                self.updateUI()
                self.delegate?.handleTweetUpdatedForViewController(tweet!, index: self.index)
            }
        })
    }
}
