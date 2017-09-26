//
//  CastingView.swift
//  WatchOut
//
//  Created by admin on 07/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import UIKit
import AlamofireImage

class CastingView: UIView {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var castMembers = [WOCastMember]() { didSet { collectionView.reloadData() } }
    
    var selectPersonAction:((WOPerson)->())?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
}

//************************************
// MARK: - collection Data Source
//************************************

extension CastingView:UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return castMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastingColCell", for: indexPath) as! CastingColCell
        
        let member = castMembers[indexPath.item]
        
        if let url = member.person.imageURL {
            let filter = AspectScaledToFillSizeCircleFilter(size: cell.picture.frame.size)
            let placeH = filter.filter(#imageLiteral(resourceName: "defaultMovie"))
            cell.picture.af_setImage(withURL: url, placeholderImage: placeH, filter: filter) 
        }
        else {
            cell.picture.image = #imageLiteral(resourceName: "defaultMovie")

        }
        cell.activityLabel.text = member.activity
        cell.nameLabel.text = member.person.name
        
        return cell
    }
    
    
}


//************************************
// MARK: - collection Delegate
//************************************
extension CastingView:UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if castMembers.count > 0 {
            selectPersonAction?(castMembers[indexPath.item].person)
            
        }
        
    }
    
}

//************************************
// MARK: - collection Flow Layout
//************************************
extension CastingView:UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = collectionView.frame.size
        size.width = 70
        return size
        
    }
    
    
}

//---------------------------------------------
// MARK: ------------- Cell
//---------------------------------------------


class CastingColCell: UICollectionViewCell {
    
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override var isHighlighted: Bool {
        
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.alpha = self.isHighlighted ? 0.7 : 1
            }
            
        }
        
    }
 
}
