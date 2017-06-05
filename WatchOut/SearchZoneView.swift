//
//  SearchZoneView.swift
//  MarksHot
//
//  Created by Quentin Beaudouin on 02/03/2017.
//  Copyright © 2017 Quentin Beaudouin. All rights reserved.
//

import UIKit
import MapKit

class SearchZoneView: UIView {

    
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var loaderImage: UIImageView!
    @IBOutlet weak var loadingIndicator:NVActivityIndicatorView!
    
    static let mapSearchSidePadding:CGFloat = 56.0
    static let mapSearchBotAdditionalPadding:CGFloat = 9.0
    static let mapSearchTopAdditionalPadding:CGFloat = 80.0
    static let pinHeightPadding:CGFloat = 34.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.isUserInteractionEnabled = false
        
        
        self.alpha = 0
        
        var cat:NVActivityIndicatorType!
        
        let dice = arc4random_uniform(6)
        
        switch dice {
        case 0:
            cat = .orbit
        case 1:
            cat = .ballTrianglePath
        case 2:
            cat = .pacman
        case 3:
            cat = .ballScaleRippleMultiple
        case 4:
            cat = .ballRotateChase
        case 5:
            cat = .lineScaleParty
        case 6:
            cat = .ballClipRotateMultiple
        default:
            cat = .ballSpinFadeLoader
        }
        
        loadingIndicator.type = cat
        loadingIndicator.color = #colorLiteral(red: 0.0862745098, green: 0.09019607843, blue: 0.09803921569, alpha: 1)
        loadingIndicator.alpha = 0.7
        
        loadingIndicator.center = loaderView.center
        loaderView.addSubview(loadingIndicator)
    }

    
    func show() {
        
        UIView.animate(withDuration: 0.1) {
            self.alpha = 0
        }
        
        loaderImage.layer.removeAllAnimations()
        loaderImage.transform = CGAffineTransform(scaleX: 0, y: 0)
        loaderImage.alpha = 0
        self.loaderImage.image = #imageLiteral(resourceName: "searchViewIcon")
        
        loadingIndicator.stopAnimating()
        
//        loaderBgImView.transform = CGAffineTransform(scaleX: 0, y: 0)
//        loaderBgImView.alpha = 0
        
        
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.loaderImage.alpha = 0.5
            self.loaderImage.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
    }
    
    func startLoading() {
        
        UIView.animate(withDuration: 0.1, animations: {
            self.loaderImage.alpha = 0.0
//            self.loaderImage.transform = CGAffineTransform(scaleX: 0, y: 0)
        }) { (ended) in
            if self.alpha != 0 {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                }, completion: nil)
                self.loadingIndicator.startAnimating()
            }
        }
        
        
    }
    
    private func animateLoading(){
        UIView.animateKeyframes(withDuration: 0.8, delay: 0, options: [.autoreverse, .repeat], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.2, animations: {

                self.loaderImage.transform = CGAffineTransform(scaleX: 0, y: 0).rotated(by: CGFloat.pi)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2, animations: {
                self.loaderImage.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).rotated(by: 0)
            })
        }, completion: { (finished) in
           
        })
    }
    
    func hide() {
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
            self.alpha = 0
        })
    }
    
    
    

}
