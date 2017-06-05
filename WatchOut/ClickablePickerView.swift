//
//  ClickablePickerView.swift
//  WatchOut
//
//  Created by admin on 06/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import UIKit

class ClickablePickerView: UIPickerView {

    var didSelectAction:(()->())?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if event?.type == .touches {

            for component in 0..<self.numberOfComponents {
                for row in 0..<self.numberOfRows(inComponent: component) {
                    if let view = self.view(forRow: row, forComponent: component) {
                        if self.selectedRow(inComponent: component) == row {
                            let pointInView = self.convert(point, to: view)
                            if 0 < pointInView.y, pointInView.y < self.rowSize(forComponent: component).height {
                                didSelectAction?()
                            }
                        }
                        
                    }
                }
                
            }
        }
        return super.hitTest(point, with: event)
        
    }
}
