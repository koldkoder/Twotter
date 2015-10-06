//
//  ProfileCell.swift
//  Cwitter
//
//  Created by Kushal Bhatt on 10/5/15.
//  Copyright © 2015 Kushal Bhatt. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {
    

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var tweetsLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureProfileCell(user: User?) {

        if let profileImageUrl = user?.profileImageUrl {
            let httpsUrl = profileImageUrl.stringByReplacingOccurrencesOfString("http://", withString: "https://")
            profileImageView.setImageWithURL(NSURL(string: httpsUrl))
        }
        
        if let bannerImageUrl = user?.bannerImageUrl {
            let httpsUrl = bannerImageUrl.stringByReplacingOccurrencesOfString("http://", withString: "https://")
            bannerImageView.setImageWithURL(NSURL(string: httpsUrl))
        }
        
        tweetsLabel.text = "Tweets " + String(User.currentUser!.tweets_count)
        followingLabel.text = "Following " + String(User.currentUser!.following_count)
        followerLabel.text = "Followers " + String(User.currentUser!.followers_count)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
