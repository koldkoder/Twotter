//
//  MenuItemCell.swift
//  Cwitter
//
//  Created by Kushal Bhatt on 10/5/15.
//  Copyright © 2015 Kushal Bhatt. All rights reserved.
//

import UIKit

class MenuItemCell: UITableViewCell {

    @IBOutlet weak var menuTitleLabel: UILabel!
    
    @IBOutlet weak var menuItemImageView: UIImageView!
    
    func configureMenuItem(title: String, image:UIImage?) {
        menuTitleLabel.text = title
        menuItemImageView.image = image
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
