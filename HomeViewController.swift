//
//  HomeViewController.swift
//  Cwitter
//
//  Created by Kushal Bhatt on 9/26/15.
//  Copyright © 2015 Kushal Bhatt. All rights reserved.
//

import UIKit

@objc protocol HomeViewControllerDelegate {
    optional func collapseSidePanels()
}
enum ViewState{
    case Home
    case Profile
    case Mentions
}

class HomeViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate, TweetCellTableViewCellDelegate, SidePanelViewControllerDelegate {

   
    @IBOutlet weak var tweetListTableView: UITableView!
    var refreshControl: UIRefreshControl?
    var tweets: [Tweet]?
    var replyTo: String?
    var currentState = ViewState.Home
    var user : User?
    
    var delegate: HomeViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetListTableView.delegate = self
        tweetListTableView.dataSource = self
        tweetListTableView.rowHeight = UITableViewAutomaticDimension
        tweetListTableView.estimatedRowHeight = 100

        
        addRefreshControl()
        
        switch currentState {
        case ViewState.Home:
                 setNavigationButtons()
                 fetchHomeTimeLine()
            
        case ViewState.Profile:
                setBackNavigationButton()
                fetchUserTimeLine()
            
        case ViewState.Mentions:
                setNavigationButtons()
                fetchMentionsTimeLine()
        }
       
        
    }
    
    
    func setNavigationButtons() {
        navigationController?.navigationBar.tintColor = UIColor.blueColor()
        let signOutButton = UIBarButtonItem(title: "Sign out", style: UIBarButtonItemStyle.Plain, target: self, action: "doSignOut")
        navigationItem.leftBarButtonItem = signOutButton
        let tweetButton = UIBarButtonItem(title: "Tweet", style: UIBarButtonItemStyle.Plain, target: self, action: "doCompose")
        navigationItem.rightBarButtonItem = tweetButton
    }
    
    func setBackNavigationButton() {
        navigationItem.title = user?.name
        let backButton = UIBarButtonItem(title: "<Back", style: UIBarButtonItemStyle.Plain, target: self, action: "goBack")
        navigationItem.leftBarButtonItem = backButton
    }
    
    func goBack() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func fetchHomeTimeLine() {
                TwitterClient.sharedInstance.homeTimeLineWithParams([:], completion: { (tweets, error) -> () in
            self.refreshControl?.endRefreshing()
            if(tweets != nil) {
                self.tweets = tweets
                self.tweetListTableView.reloadData()
            }
        })
    }
    
    func fetchUserTimeLine() {
        
        if user == nil {
            user = User.currentUser
        }
        let paramsdict = ["screen_name": user!.screenname!]
        let params = paramsdict as NSDictionary
        TwitterClient.sharedInstance.userTimeLineWithParams(params, completion: { (tweets, error) -> () in
            self.refreshControl?.endRefreshing()
            if(tweets != nil) {
                self.tweets = tweets
                self.tweetListTableView.reloadData()
            }
        })
    }
    
    func fetchMentionsTimeLine() {

        TwitterClient.sharedInstance.mentionsTimeLineWithParams([:], completion: { (tweets, error) -> () in
            self.refreshControl?.endRefreshing()
            if(tweets != nil) {
                self.tweets = tweets
                self.tweetListTableView.reloadData()
            }
        })
    }
    
    func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tweetListTableView.insertSubview(refreshControl!, atIndex: 0)
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func onRefresh() {
        fetchHomeTimeLine()
    }
    
    func doSignOut() {
        User.currentUser?.logout()
    }
    
    func doCompose() {
        replyTo = nil
        doTweet()
    }
    
    func doReply(replyTo: String) {
        self.replyTo = replyTo
        doTweet()
    }
    
    func doTweet() {
        performSegueWithIdentifier("composeSegue", sender: nil)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = tweets {
            return tweets.count
        }
        return 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(currentState == ViewState.Profile) {
            if(indexPath.row == 0) {
                let profileCell = tableView.dequeueReusableCellWithIdentifier("ProfileCell", forIndexPath: indexPath) as! ProfileCell
                profileCell.configureProfileCell(user)
                return profileCell
            }
        }
        
        let tweetCell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCellTableViewCell
        let tweet = tweets![indexPath.row]
        tweetCell.tweet = tweet
        tweetCell.delegate = self
        return tweetCell
    }

    
    func tweetCellTableViewCell(tweetCell: TweetCellTableViewCell, buttonTapped value: String) {
        let indexPath = tweetListTableView.indexPathForCell(tweetCell)!
        let tweetId = tweets![indexPath.row].id
        switch value {
            case "favorite":
                tweets![indexPath.row].favorited = tweetCell.favoriteButton.selected
                
                if tweetCell.favoriteButton.selected {
                    TwitterClient.sharedInstance.favoriteTweet(tweetId)
                } else {
                    TwitterClient.sharedInstance.unFavoriteTweet(tweetId)
                }
            
            case "retweet":
                tweets![indexPath.row].retweeted = tweetCell.retweetButton.selected
                
                if tweetCell.retweetButton.selected {
                    TwitterClient.sharedInstance.reTweet(tweetId)
                } else {
                    //TwitterClient.sharedInstance.unReTweet(tweetId)
                }
            
            case "reply":
                let tweet = tweets![indexPath.row]
                doReply("@" + (tweet.user?.screenname)!)
                break;
        default:
            break;
            
        }
    }
    
    func profileImageTapped(tweetCell: TweetCellTableViewCell) {
        let indexPath = tweetListTableView.indexPathForCell(tweetCell)!
        let user = tweets![indexPath.row].user
        let homeViewController = UIStoryboard.homeViewController()
        homeViewController!.user = user
        homeViewController?.currentState = ViewState.Profile
        navigationController?.pushViewController(homeViewController!, animated: true)
        
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let segueId = segue.identifier!
        switch segueId {
            case "composeSegue":
                let navigationController = segue.destinationViewController as! UINavigationController
                let composeViewController = navigationController.topViewController as! ComposeViewController
                composeViewController.tweetText = replyTo
            case "detailSegue":
                let cell = sender as! UITableViewCell
                let indexPath = tweetListTableView.indexPathForCell(cell)!
                let tweet = tweets![indexPath.row]
                let detailViewController = segue.destinationViewController as! TweetDetailViewController
                detailViewController.tweet = tweet
                break;
            
        default:
            break;
        }
    }

    func reloadView(type: String) {
        
        let containerViewController = ContainerViewController()
        presentViewController(containerViewController, animated: true) { () -> Void in
            switch type {
            case "Home":
                containerViewController.homeViewController.currentState = ViewState.Home
                containerViewController.homeViewController.fetchHomeTimeLine()
                
            case "Mentions":
                containerViewController.homeViewController.currentState = ViewState.Mentions
                containerViewController.homeViewController.fetchMentionsTimeLine()
                
            case "Profile":
                containerViewController.homeViewController.currentState = ViewState.Profile
                containerViewController.homeViewController.fetchUserTimeLine()
                
            default:
                break
            }
            containerViewController.homeViewController.navigationItem.title = type
            
        }
        delegate?.collapseSidePanels?()
       
    }
    
    func menuItemSelected(menuItem: MenuItem) {
        reloadView(menuItem.title)
    }
}


