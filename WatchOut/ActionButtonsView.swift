//
//  ActionButtonsView.swift
//  WatchOut
//
//  Created by admin on 08/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import UIKit

class ActionButtonsView: UIView {

    @IBOutlet weak var goButton:UIButton!

    @IBOutlet weak var inviteButton:UIButton!
    
    func setHidden(_ hidden:Bool, animated:Bool) {
        
        if hidden == (self.alpha == 0) { return }
//        let buttonTransform = hidden ? CGAffineTransform(scaleX: 0, y: 0) : .identity

        UIView.animate(withDuration: animated ? 0.5 : 0, delay: 0.0, usingSpringWithDamping: hidden ? 1:1, initialSpringVelocity: 0, options: [.beginFromCurrentState], animations: { [weak self] in
            
           // self?.goButton.transform = buttonTransform
            //self?.inviteButton.transform = buttonTransform
            self?.alpha = hidden ? 0 : 1
            
            }, completion: nil)
        
    }
    
}
