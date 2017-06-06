//
//  DateFilterVies.swift
//  WatchOut
//
//  Created by admin on 04/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import UIKit

class DateFilterView: UIView {

    @IBOutlet weak var oneHourButton:UIButton!
    @IBOutlet weak var todayButton:UIButton!
    @IBOutlet weak var otherDayButton:UIButton!
    @IBOutlet weak var allButton:UIButton!
    
    var filterDate:Date?
    
    var otherDayAction:((Void) -> (Void))?
    
    var valueDidChangeAction:((Void) -> (Void))?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        oneHourButton.isSelected = true
    }
    
    @IBAction func didSelectTimeFilter(_ sender: UIButton) {
        if sender.isSelected, sender != otherDayButton { return }
        sender.isSelected = true
        let buttons = [oneHourButton,todayButton,otherDayButton,allButton]
        
        for button in buttons {
            if button != sender {
                button?.isSelected = false
            }
        }
        if sender == otherDayButton, sender.isSelected {
            otherDayAction?()
        }
        else {
            valueDidChangeAction?()
        }
        
    }
    

}
