//
//  MenuItem.swift
//  Cwitter
//
//  Created by Kushal Bhatt on 10/5/15.
//  Copyright © 2015 Kushal Bhatt. All rights reserved.
//

import UIKit

class MenuItem {
    let title: String
    let image: UIImage?
    
    init(title:String, image:UIImage) {
        self.title = title
        self.image = image
    }
    
    init(title: String) {
        self.title = title
        self.image = nil
    }
    
    class func allMenuItems() -> Array<MenuItem> {
        return [MenuItem(title: "Home"),
          MenuItem(title: "Profile"),
          MenuItem(title: "Mentions"),
          MenuItem(title: "Accounts")]
    }
}
