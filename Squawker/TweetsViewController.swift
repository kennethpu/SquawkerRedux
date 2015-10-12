//
//  TweetsViewController.swift
//  Squawker
//
//  Created by Kenneth Pu on 10/4/15.
//  Copyright © 2015 Kenneth Pu. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    private var tweets: [Tweet]!
    private var replyTweet: Tweet?
    private var targetUser: User?
    private var oldMode: String?
    
    var mode: String = "Mentions" {
        didSet {
            if oldMode != mode {
                navigationItem.title = mode
                fetchData()
                oldMode = mode
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        fetchData()
    }
    
    func refresh(sender: AnyObject) {
        fetchData()
        self.refreshControl.endRefreshing()
    }
    
    private func fetchData() {
        if mode == "Home" {
            TwitterClient.sharedInstance.homeTimelineWithCompletion(nil, completion: { (tweets: [Tweet]?, error: NSError?) -> () in
                self.tweets = tweets
                self.tableView.reloadData()
            })
        } else {
            TwitterClient.sharedInstance.mentionsTimelineWithCompletion(nil, completion: { (tweets: [Tweet]?, error: NSError?) -> () in
                self.tweets = tweets
                self.tableView.reloadData()
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TweetDetailSegue" {
            let destinationVC = segue.destinationViewController as! TweetDetailsViewController
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
            
            destinationVC.tweet = tweets[indexPath.row]
            destinationVC.index = indexPath.row
            destinationVC.delegate = self
        } else if segue.identifier == "NewTweetSegue" {
            let destinationVC = segue.destinationViewController as! TweetComposeViewController
            
            if replyTweet != nil {
                destinationVC.replyTweet = replyTweet
                replyTweet = nil
            }
            destinationVC.delegate = self
        } else if segue.identifier == "UserDetailSegue" {
            let destinationVC = segue.destinationViewController as! UserDetailsViewController
            
            if targetUser != nil {
                destinationVC.user = targetUser
            }
        }
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
    }
}

extension TweetsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tweets != nil) ? tweets!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetsTableViewCell", forIndexPath: indexPath) as! TweetsTableViewCell
        
        cell.tweet = tweets[indexPath.row]
        cell.delegate = self
        
        return cell
    }
}

extension TweetsViewController: TweetsTableViewCellDelegate {
    func handleTweetUpdatedForCell(tweet: Tweet, cell: TweetsTableViewCell) {
        let indexPath = tableView.indexPathForCell(cell)!
        tweets[indexPath.row] = tweet
    }
    
    func callComposeSegueFromCell(tweet: Tweet) {
        replyTweet = tweet
        self.performSegueWithIdentifier("NewTweetSegue", sender: self)
    }
    
    func callUserSegueFromCell(user: User) {
        targetUser = user
        self.performSegueWithIdentifier("UserDetailSegue", sender: self)
    }
}

extension TweetsViewController: TweetDetailsViewControllerDelegate {
    func handleTweetUpdatedForViewController(tweet: Tweet, index: Int) {
        tweets[index] = tweet
        tableView.reloadData()
    }
    
    func callComposeSegueFromViewController(tweet: Tweet) {
        replyTweet = tweet
        self.performSegueWithIdentifier("NewTweetSegue", sender: self)
    }
    
    func callUserSegueFromViewController(user: User) {
        targetUser = user
        self.performSegueWithIdentifier("UserDetailSegue", sender: self)
    }
}

extension TweetsViewController: TweetComposeViewControllerDelegate {
    func handleTweetPosted(tweet: Tweet) {
        tweets.insert(tweet, atIndex: 0)
        tableView.reloadData()
    }
}