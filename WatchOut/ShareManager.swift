//
//  ShareManager.swift
//  Busity
//
//  Created by Quentin Beaudouin on 10/12/2016.
//  Copyright © 2016 Instama. All rights reserved.
//

import UIKit

class ShareManager: NSObject {

    static func shareOnController(controller:UIViewController, sourceView:UIView, shareItemName:String,  image:UIImage?){
        
        let messageString = "Look".localized + "\(shareItemName)" + "a great place I discovered with this cool app !".localized
        let webSiteUrlString = "http://busity.co"
        
        var activityItems:[Any]
        
        if image != nil  {
            activityItems = [messageString, image!, webSiteUrlString]
        }
        else {
            activityItems = [messageString, webSiteUrlString]
        }
        
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = sourceView
        activityVC.popoverPresentationController?.sourceRect = sourceView.bounds
        
        controller.present(activityVC, animated: true, completion: nil)
        
    }
    
    static func shareOnController(controller:UIViewController, sourceView:UIView, message:String){
        
        let activityItems = [message]

        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = sourceView
        activityVC.popoverPresentationController?.sourceRect = sourceView.bounds
        
        controller.present(activityVC, animated: true, completion: nil)
        
    }
    
}
