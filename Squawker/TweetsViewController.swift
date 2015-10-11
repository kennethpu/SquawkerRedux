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
    
    var tweets: [Tweet]!
    var replyTweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        fetchData()
    }
    
    func fetchData() {
        TwitterClient.sharedInstance.homeTimelineWithCompletion(nil, completion: { (tweets: [Tweet]?, error: NSError?) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
        })
    }
    
    func refresh(sender: AnyObject) {
        fetchData()
        self.refreshControl.endRefreshing()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailSegue" {
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
    
    func callSegueFromCell(tweet: Tweet) {
        replyTweet = tweet
        self.performSegueWithIdentifier("NewTweetSegue", sender: self)
    }
}

extension TweetsViewController: TweetDetailsViewControllerDelegate {
    func handleTweetUpdatedForViewController(tweet: Tweet, index: Int) {
        tweets[index] = tweet
        tableView.reloadData()
    }
    
    func callSegueFromViewController(tweet: Tweet) {
        replyTweet = tweet
        self.performSegueWithIdentifier("NewTweetSegue", sender: self)
    }
}

extension TweetsViewController: TweetComposeViewControllerDelegate {
    func handleTweetPosted(tweet: Tweet) {
        tweets.insert(tweet, atIndex: 0)
        tableView.reloadData()
    }
}