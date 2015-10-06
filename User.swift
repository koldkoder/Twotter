//
//  User.swift
//  Cwitter
//
//  Created by Kushal Bhatt on 9/27/15.
//  Copyright © 2015 Kushal Bhatt. All rights reserved.
//

import Foundation
import UIKit

var _currentUser: User?
let currentUserKey = "kCurrentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User: NSObject {
    var name: String?
    var screenname: String?
    var profileImageUrl: String?
    var bannerImageUrl: String?
    var tagline: String?
    var dictionary: NSDictionary?
    var followers_count = 0
    var following_count = 0
    var tweets_count = 0
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        profileImageUrl = dictionary["profile_image_url"] as? String
        bannerImageUrl = dictionary["profile_banner_url"] as? String
        tagline = dictionary["tagline"] as? String
        followers_count = dictionary["followers_count"] as! Int
        following_count = dictionary["friends_count"] as! Int
        tweets_count = dictionary["statuses_count"] as! Int
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
                if let data = data {
                    let dictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary
                    _currentUser = User(dictionary: dictionary!)
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            
            if _currentUser != nil {
                let data =  try! NSJSONSerialization.dataWithJSONObject(user!.dictionary!, options: [])
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
                NSUserDefaults.standardUserDefaults().synchronize()
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
        }
    }
}
