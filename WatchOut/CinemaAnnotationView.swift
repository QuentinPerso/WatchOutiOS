//
//  CinemaShowsAnnotationView.swift
//  AZCustomCallout
//
//  Created by Alexander Andronov on 23/06/16.
//  Copyright © 2016 Alexander Andronov. All rights reserved.
//

import Foundation
import MapKit

class CinemaAnnotationView : MKAnnotationView {
    
    
    static let pinSize = CGSize(width: 50, height: 57)
    
    let unselectedTransform = CGAffineTransform(translationX: 0, y: pinSize.height * (1 - 0.45) / 2 ).scaledBy(x: 0.45, y: 0.45)
    
    let strokW:CGFloat = 1
    
    var tapAction:(()->())?
    
    func initLayout(){
        
        let size = CinemaAnnotationView.pinSize
        self.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.backgroundColor = UIColor.clear
        self.calloutOffset = CGPoint(x: 0, y: 0)
        self.centerOffset = CGPoint(x: 0, y: -size.height / 2);
//        self.transform = unselectedTransform
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapView))
        tap.cancelsTouchesInView = true
        let press = UILongPressGestureRecognizer(target: self, action: nil)
        self.addGestureRecognizer(tap)
        self.addGestureRecognizer(press)
        
    }
    
    @objc private func didTapView() {
        tapAction?()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        self.isSelected = selected
        
        
        
        if animated {
            if selected {
                UIView.animate(withDuration: 0.28,
                               delay: 0,
                               usingSpringWithDamping: 0.7, initialSpringVelocity: 2,
                               options: .curveEaseOut, animations: {
                                self.transform = CGAffineTransform(translationX: 0, y: 0).scaledBy(x: 0.65, y: 1)
                }, completion: nil)
                UIView.animate(withDuration: 0.4,
                               delay: 0.0,
                               usingSpringWithDamping: 0.7, initialSpringVelocity: 1,
                               options: .curveEaseOut, animations: {
                                self.transform = CGAffineTransform(translationX: 0, y: 0).scaledBy(x: 1, y: 1)
                }, completion:nil)
            }
            else{
                UIView.animate(withDuration: 0.2, animations: {
                    self.transform = self.unselectedTransform
                }, completion:nil)
            }
            
        }
        else{
            self.transform = selected ? CGAffineTransform.identity : unselectedTransform
        }
    }
    
    
    override func draw(_ rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()
        
        if ctx == nil { return }
        
        //        let rectPadShadow = CGRect(x: rect.origin.x + 1, y: rect.origin.y + 1, width: rect.size.width - 2, height: rect.size.height - 2)
        
        UIGraphicsPushContext(ctx!);
        
        //**** Fill color
        createPath(ctx: ctx!, rect: rect)
        ctx!.setFillColor(#colorLiteral(red: 0.0862745098, green: 0.09019607843, blue: 0.09803921569, alpha: 1).cgColor)
        ctx?.setShadow(offset: CGSize(width: 0, height: 0), blur: 2, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7679357394).cgColor)
        ctx?.fillPath()
        ctx?.setShadow(offset: CGSize(width: 0, height: 0), blur: 0, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor)
        
                //**** Border color
                createPath(ctx: ctx!, rect: rect)
                ctx?.setLineWidth(strokW)
                ctx?.setStrokeColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor)
                ctx?.strokePath()
        
        //**** Image
        ctx!.setFillColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor)
        let width = self.bounds.width
        let rPad = width/5
        #imageLiteral(resourceName: "pinIcon").draw(in: CGRect(x: rPad, y: rPad, width: width - 2*rPad, height: width - 2*rPad))
        
        UIGraphicsPopContext();
    }
    
    func createPath(ctx:CGContext, rect:CGRect) {
        let bounds = self.bounds
        
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        
        let midBottom = CGPoint(x: rect.midX, y: rect.maxY + strokW / 2)
        
        let width = bounds.size.width
        
        //draw semi circle
        ctx.beginPath()
        let angle = .pi/2.3
        ctx.addArc(center: CGPoint(x: width/2, y: width/2 + strokW / 2),
                   radius: width/2 - strokW / 2,
                   startAngle: CGFloat(angle),
                   endAngle: CGFloat(.pi - angle),
                   clockwise: true)
        
        //draw bottom cone
        ctx.addLine(to: midBottom)
        ctx.addLine(to: CGPoint(x: topRight.x - width / 2 * (1 - CGFloat(cos(angle))),
                                y: topRight.y + width / 2 * (1 + CGFloat(sin(angle)))
        ))
        ctx.closePath()
    }
    
    
}





