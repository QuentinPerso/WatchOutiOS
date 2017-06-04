//
//  DateFilterVies.swift
//  WatchOut
//
//  Created by admin on 04/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import UIKit

class DateFilterView: UIView {

    @IBOutlet weak var oneHourButton
    : UIButton!
    @IBOutlet weak var todayButton
    : UIButton!
    @IBOutlet weak var otherDayButton
    : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        oneHourButton.isSelected = true
    }
    
    @IBAction func didSelectTimeFilter(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let buttons = [oneHourButton,todayButton,otherDayButton]
        for button in buttons {
            if button != sender {
                button?.isSelected = false
            }
        }
    }
    

}
