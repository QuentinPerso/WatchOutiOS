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

    static let mapSearchSidePadding:CGFloat = 56.0
    static let mapSearchBotAdditionalPadding:CGFloat = 9.0
    static let mapSearchTopAdditionalPadding:CGFloat = 80.0
    static let pinHeightPadding:CGFloat = 34.0
    
    private var searchRect:CGRect!
    
    var layerView:UIView!
    
    var loaderView:UIView!
    var loaderImage:UIImageView!
    let loadingLabel = UILabel()
    var loadingIndicator:NVActivityIndicatorView!
//    var loaderBgImView:UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(mapView:MKMapView) {
        
        super.init(frame: mapView.frame)
        
        self.isUserInteractionEnabled = false

        
        self.alpha = 0

        addMaskView(mapView: mapView)
        
        loaderView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        
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
        
        loadingIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 44, height: 44), type: cat)
        loadingIndicator.color = #colorLiteral(red: 0.0862745098, green: 0.09019607843, blue: 0.09803921569, alpha: 1)
        loadingIndicator.alpha = 0.7

        loadingIndicator.center = loaderView.center
        loaderView.addSubview(loadingIndicator)
        
        loaderImage = UIImageView(image: #imageLiteral(resourceName: "searchViewIcon"))
        loaderImage.center = loaderView.center
        
        loaderView.addSubview(loaderImage)
        
        
        loadingLabel.numberOfLines = 1
        loadingLabel.font = UIFont.woFont(size: 13)
        loadingLabel.textColor = UIColor.white
        let messSize = loadingLabel.font.sizeOfString(string: "Loading...", constrainedToWidth: Double(frame.width) - 30.0)
        
        var messFrame = CGRect(origin: CGPoint(), size: messSize)
        messFrame.origin.y = 44 + 10
        messFrame.size.width += 20
        messFrame.size.height = 34
        
        loadingLabel.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.09019607843, blue: 0.09803921569, alpha: 1)
        loadingLabel.layer.cornerRadius = 17
        loadingLabel.layer.borderColor = UIColor.white.cgColor
        loadingLabel.layer.borderWidth = 1
        loadingLabel.alpha = 0.7
        loadingLabel.clipsToBounds = true
        loadingLabel.textAlignment = .center
        
        loadingLabel.frame = messFrame
        loadingLabel.center.x = loaderView.frame.size.width/2
        
        loadingLabel.text = "Loading..."
        
        loaderView.addSubview(loadingLabel)
        
        self.addSubview(loaderView)
        
    }
    
    func show() {
        
        UIView.animate(withDuration: 0.1) {
            self.alpha = 0
        }
        
        loadingLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
        loadingLabel.alpha = 0
        
        layerView.alpha = 1
        
        loaderView.center = CGPoint(x: searchRect.origin.x + searchRect.size.width/2,
                                    y: searchRect.origin.y + searchRect.size.height/2)
        
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
            self.layerView.alpha = 0.0
            self.loaderImage.alpha = 0.0
//            self.loaderImage.transform = CGAffineTransform(scaleX: 0, y: 0)
        }) { (ended) in
            if self.alpha != 0 {
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.loadingLabel.alpha = 0.7
                })
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                    self.loadingLabel.transform = .identity
                }, completion: nil)
                self.loadingIndicator.startAnimating()
            }
        }
        
//        let finalX = self.bounds.width - 44 - 20
//        let finalY = searchRect.origin.y + searchRect.size.height + SearchZoneView.mapSearchBotAdditionalPadding - 44 - 23
//        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
//            var rect = self.loaderView.frame
//            rect.origin.y = finalY
//            self.loaderView.frame = rect
//            
//            self.loaderBgImView.alpha = 1
//        })
//        
//        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
//            self.loaderView.frame = CGRect(x: finalX,
//                                         y: finalY,
//                                         width: 44,
//                                         height: 44)
//            self.loaderBgImView.transform = CGAffineTransform(scaleX: 1, y: 1)
//            self.loaderImage.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
//            self.loaderImage.alpha = 1
//        }) { (finished) in
//            self.animateLoading()
//        }
        
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
    
    private func addMaskView(mapView:MKMapView) {
        
        let sidePadding:CGFloat = SearchZoneView.mapSearchSidePadding - SearchZoneView.pinHeightPadding / 2
        let botAdditionalPadding:CGFloat = SearchZoneView.mapSearchBotAdditionalPadding
        let topAdditionalPadding:CGFloat = SearchZoneView.mapSearchTopAdditionalPadding - SearchZoneView.pinHeightPadding
        let nePoint =
            CGPoint(x:mapView.bounds.origin.x + mapView.bounds.size.width - sidePadding,
                    y:mapView.bounds.origin.y + mapView.layoutMargins.top + topAdditionalPadding)
        let swPoint =
            CGPoint(x:(mapView.bounds.origin.x + sidePadding),
                    y:(mapView.bounds.origin.y + mapView.bounds.size.height - mapView.layoutMargins.bottom - botAdditionalPadding))
        
        layerView = UIView(frame: bounds)
        layerView.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.09019607843, blue: 0.09803921569, alpha: 1)
        
        
        let maskLayer = CAShapeLayer()
        
        maskLayer.frame = bounds
        
        let path = CGMutablePath()
        searchRect = CGRect(x: swPoint.x, y: nePoint.y, width: nePoint.x - swPoint.x, height: swPoint.y - nePoint.y)
//        searchRect.size.width = max(searchRect.width, searchRect.height)
//        searchRect.size.height = max(searchRect.width, searchRect.height)

        let circlePath = UIBezierPath(roundedRect: searchRect, cornerRadius: searchRect.size.width/2)
        path.addPath(circlePath.cgPath)
        path.addRect(self.bounds)

        maskLayer.fillColor = #colorLiteral(red: 0.0862745098, green: 0.09019607843, blue: 0.09803921569, alpha: 0.1813730736).cgColor
        maskLayer.path = path
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        layerView.layer.mask = maskLayer
        layerView.clipsToBounds = true
        
        self.addSubview(layerView)
    }
    
    

}
