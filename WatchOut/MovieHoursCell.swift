//
//  FeaturedPlaceCell.swift
//  MarksHot
//
//  Created by Quentin Beaudouin on 17/02/2017.
//  Copyright © 2017 Quentin Beaudouin. All rights reserved.
//

import UIKit

class MovieHoursCell: UITableViewCell {
    
    @IBOutlet weak var pictureImage: UIImageView!
    @IBOutlet weak var filmTitleLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        
    
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.15) { 
            self.alpha = highlighted ? 0.6 : 1
        }
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    
}
