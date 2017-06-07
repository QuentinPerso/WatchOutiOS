//
//  DateFilterVies.swift
//  WatchOut
//
//  Created by admin on 04/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import UIKit

class DateFilterView: UIView {

    @IBOutlet weak var soonButton:UIButton!
    @IBOutlet weak var todayButton:UIButton!
    @IBOutlet weak var otherDayButton:UIButton!
    @IBOutlet weak var allButton:UIButton!
    
    @IBOutlet weak var sliderView:UIView!
    @IBOutlet weak var sliderViewHConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var slider:UISlider!
    
    var sliderKnobImView:UIImageView!
    
    var filterDate:Date?
    
    var otherDayAction:((Void) -> (Void))?
    
    var valueDidChangeAction:((Void) -> (Void))?
    
    var showSliderAction:((_ show:Bool) -> (Void))?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        soonButton.isSelected = true
        slider.setThumbImage(#imageLiteral(resourceName: "thumb"), for: .normal)
        slider.addTarget(self, action: #selector(self.sliderValueStopped(_:)), for: .touchUpOutside)
        slider.addTarget(self, action: #selector(self.sliderValueStopped(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(self.sliderValueChanged(_:)), for: .valueChanged)
    }
    
    func sliderValueStopped(_ sender: UISlider) {
        valueDidChangeAction?()
    }
    
    func sliderValueChanged(_ sender: UISlider) {
        
        var timeString = ""
        
        if slider.value < 3600 {
            timeString = "\(Int(slider.value)/60) min"
        }
        else {
            let mins = Int(slider.value)%3600/60
            if mins < 10{
                timeString = "\(Int(slider.value)/3600)h0\(mins)"
            }
            else {
                timeString = "\(Int(slider.value)/3600)h\(mins)"
            }
        }
        
        soonButton.setTitle(timeString, for: .normal)

    }
    
    var nowSliderHidden:Bool = false {
        didSet {
            sliderViewHConstraint.constant = nowSliderHidden ? 0 : 30
        }
    }
    
    
    @IBAction func didSelectTimeFilter(_ sender: UIButton) {
        
        showSliderAction?(sender == soonButton)
        
        if sender.isSelected, sender != otherDayButton { return }
        sender.isSelected = true
        let buttons = [soonButton,todayButton,otherDayButton,allButton]
        
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
