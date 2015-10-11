//
//  TweetComposeViewController.swift
//  Squawker
//
//  Created by Kenneth Pu on 10/5/15.
//  Copyright © 2015 Kenneth Pu. All rights reserved.
//

import UIKit

protocol TweetComposeViewControllerDelegate {
    func handleTweetPosted(tweet: Tweet)
}

class TweetComposeViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var characterLimitLabel: UILabel!
    @IBOutlet weak var tweetButton: UIButton!
    
    var replyTweet: Tweet?
    var delegate: TweetComposeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true
        
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
        fullNameLabel.text = User.currentUser!.name
        usernameLabel.text = "@\(User.currentUser!.screenName!)"
        
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor(red: 225.0/255, green: 232.0/255, blue: 237.0/255, alpha: 1.0).CGColor
        textView.layer.cornerRadius = 5.0
        textView.delegate = self
        if replyTweet != nil {
            textView.text = "@\(replyTweet!.author!.screenName!) "
        }
        
        characterLimitLabel.text = "\(140-textView.text.characters.count)"
        
        tweetButton.layer.cornerRadius = 5.0
        if textView.text.characters.count == 0 {
            tweetButton.enabled = false
            tweetButton.alpha = 0.3
        }
        
        textView.becomeFirstResponder()
    }
    
    @IBAction func onTweet(sender: AnyObject) {
        var params: Dictionary = ["status" : textView.text]
        if replyTweet != nil {
            params["in_reply_to_status_id"] = replyTweet!.idString
        }
        TwitterClient.sharedInstance.tweetWithCompletion(params as NSDictionary, completion: { (tweet: Tweet?, error: NSError?) -> () in
            if tweet != nil {
                self.delegate?.handleTweetPosted(tweet!)
                self.navigationController?.popViewControllerAnimated(true)
            }
        })
    }
}

extension TweetComposeViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return textView.text.characters.count + (text.characters.count - range.length) <= 140;
    }
    
    func textViewDidChange(textView: UITextView) {
        characterLimitLabel.text = "\(140-textView.text.characters.count)"
        if textView.text.characters.count > 0 {
            tweetButton.enabled = true
            tweetButton.alpha = 1.0
        } else {
            tweetButton.enabled = false
            tweetButton.alpha = 0.3
        }
    }
}
