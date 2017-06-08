//
//  CollectionPopupVC.swift
//  MarksHot
//
//  Created by Quentin Beaudouin on 09/03/2017.
//  Copyright © 2017 Quentin Beaudouin. All rights reserved.
//

import UIKit


//------------------------------------------------------
// MARK: ---------------- Popup --------------------
//--------------------------------------------------------


class CollectionPopup: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var leftButton: UIButton!
    
    
    var leftAction:((Void) -> (Void))?
    var rightAction:((Void) -> (Void))?
    
    var actions = [PopupAction]() {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        collectionView.register(UINib(nibName: "CollectionPopupCell", bundle: nil), forCellWithReuseIdentifier: "CollectionPopupCell")
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mainView.layer.cornerRadius = 0
        let shadowPath:UIBezierPath  = UIBezierPath.init(roundedRect: (mainView.bounds), cornerRadius: 0)
        
        mainView.layer.shadowRadius = 20
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOpacity = 0.3
        mainView.layer.shadowOffset = CGSize(width: 0, height: 6)
        mainView.layer.shadowPath = shadowPath.cgPath
        mainView.clipsToBounds = false
        
        leftButton.layer.cornerRadius = 17
        leftButton.layer.borderColor = UIColor.white.cgColor
        leftButton.layer.borderWidth = 1
        
        
    }
    
    func showInWindow(_ window:UIWindow) {
        
        self.frame = window.bounds
        mainView.transform = CGAffineTransform(translationX: 0, y: mainView.frame.size.height)
        
        self.alpha = 0
        
        window.addSubview(self)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.alpha = 1
            self.mainView.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
    }
    
    
    @IBAction func clickLeftButton(_ sender: UIButton) {
        hide()
        leftAction?()
        
    }
    
    @IBAction func closeClicked(_ sender: Any) {
        hide()
        
    }
    
    
    
    
    func hide(){
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
            self.mainView.transform = CGAffineTransform(translationX: 0, y: self.mainView.frame.size.height)
            self.backgroundView.alpha = 0
        }, completion: { finished in
            self.removeFromSuperview()
        })
        
        
        
        
    }
    
    //************************************
    // MARK: - Collection data source
    //************************************
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionPopupCell", for: indexPath) as! CollectionPopupCell
        
        let action = actions[indexPath.row]
        
        cell.textLabel.text = action.title!
        cell.iconImage.image = action.image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        actions[indexPath.row].handler?()
        
    }
    
}

//------------------------------------------------------
// MARK: ---------------- Actions --------------------
//--------------------------------------------------------

class PopupAction:NSObject {
    
    var title: String?
    var image: UIImage?
    var handler:(() -> ())?
    
    init(title: String?, image: UIImage, handler: (() -> ())? = nil) {

        self.title = title
        self.image = image
        self.handler = handler
        
    }
    
    
    

}

//------------------------------------------------------
// MARK: ---------------- Cell --------------------
//--------------------------------------------------------


class CollectionPopupCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImage: UIImageView!
    
    @IBOutlet weak var textLabel: UILabel!
    
    override var isHighlighted: Bool {
        
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
            }
            
        }
        
    }
    
}


