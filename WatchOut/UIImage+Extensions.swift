//
//  UIImage+Extensions.swift
//  MarksHot
//
//  Created by Quentin Beaudouin on 23/10/2016.
//  Copyright © 2016 Quentin Beaudouin. All rights reserved.
//

import UIKit

extension UIImage {
    static func fromColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    func imageWithRoundedCornersAndSize(sizeToFit:CGSize) -> UIImage  {
        
        let rect = CGRect(x: 0, y: 0, width: sizeToFit.width, height: sizeToFit.height)

        if let ctx = UIGraphicsGetCurrentContext() {
            UIGraphicsBeginImageContextWithOptions(sizeToFit, false, UIScreen.main.scale)
            let cgBezierPath = UIBezierPath(roundedRect: rect, cornerRadius: sizeToFit.width).cgPath
            
            ctx.addPath(cgBezierPath)
            
            ctx.clip()
            
            self.draw(in: rect)

            if let output = UIGraphicsGetImageFromCurrentImageContext() {

                UIGraphicsEndImageContext()
                return output
            }
            else {

                UIGraphicsEndImageContext()
                return self
            }
            
        }
        return self

    }

}

extension UIImage {
    
    func scaledTo(newSize: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
}





