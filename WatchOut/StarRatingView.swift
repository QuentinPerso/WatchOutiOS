//
//  StarRatingView.swift
//  WatchOut
//
//  Created by admin on 06/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import UIKit

class StarRatingView: UIView {

    
    private var unselectedAlpha:CGFloat = 0.5
    @IBOutlet var starImagesArray: [UIImageView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for im in starImagesArray {
            im.alpha = unselectedAlpha
        }
    }
    
    var rating:CGFloat = 0 {
        didSet {
            for im in starImagesArray {
                if Int(rating + 0.5) > im.tag {
                    im.alpha = 1
                }
                else {
                    im.alpha = unselectedAlpha
                }
            }
            
        }
    }

}
