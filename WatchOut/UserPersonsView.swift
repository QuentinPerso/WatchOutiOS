//
//  UserPersonsView.swift
//  WatchOut
//
//  Created by admin on 07/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import UIKit
import AlamofireImage

class UserPersonsView: UIView {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var savedPersons = SavedPersons.persons
    
    var selectPersonAction:((WOPerson)->())?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func reload() {
        savedPersons = SavedPersons.persons
        collectionView.reloadData()
        
    }

}

//************************************
// MARK: - collection Data Source
//************************************

extension UserPersonsView:UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedPersons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserPersonColCell", for: indexPath) as! UserPersonColCell
        
        let person = savedPersons[indexPath.item]
        
        if let url = person.imageURL {
            let filter = AspectScaledToFillSizeCircleFilter(size: cell.picture.frame.size)
            let placeH = filter.filter(#imageLiteral(resourceName: "defaultMovie"))
            cell.picture.af_setImage(withURL: url, placeholderImage: placeH, filter: filter) 
        }
        else {
            cell.picture.image = #imageLiteral(resourceName: "defaultMovie")

        }
        cell.nameLabel.text = person.name
        
        return cell
    }
    
    
}


//************************************
// MARK: - collection Delegate
//************************************
extension UserPersonsView:UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if savedPersons.count > 0 {
            selectPersonAction?(savedPersons[indexPath.item])
            
        }
        
    }
    
}

//************************************
// MARK: - collection Flow Layout
//************************************
extension UserPersonsView:UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = collectionView.frame.size
        size.width = 100
        return size
        
    }
    
    
}

//---------------------------------------------
// MARK: ------------- Cell
//---------------------------------------------


class UserPersonColCell: UICollectionViewCell {
    
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override var isHighlighted: Bool {
        
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.alpha = self.isHighlighted ? 0.7 : 1
            }
            
        }
        
    }
 
}
