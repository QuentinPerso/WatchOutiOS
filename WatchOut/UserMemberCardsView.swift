//
//  UserMoviesCell.swift
//  WatchOut
//
//  Created by admin on 07/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import UIKit
import AlamofireImage

class UserMemberCardsView: UIView {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
     @IBOutlet weak var collectionHConstraint: NSLayoutConstraint!
    
    var selectMovieAction:((WOMovie)->())?
    
    var baseCards = SaveManager.savedBaseMemberCard
    
    override func awakeFromNib() {
        super.awakeFromNib()
        baseCards = SaveManager.savedBaseMemberCard
        if baseCards.count == 0 {
            self.isHidden = true
        }
        else {
            self.isHidden = false
            collectionView.delegate = self
            collectionView.dataSource = self
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionHConstraint.constant = collectionView.contentSize.height
    }

}

//************************************
// MARK: - collection Data Source
//************************************

extension UserMemberCardsView:UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return baseCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCardColCell", for: indexPath) as! UserCardColCell
        
        let card = baseCards[indexPath.item]

        cell.button.setTitle(card.label, for: .normal)
        
        cell.button.isSelected = SaveManager.userMemberCard.contains(card)
        
        cell.button.tag = indexPath.row
        
        cell.button.addTarget(self, action: #selector(self.clickMemberCard(_:)), for: .touchUpInside)
        
        //cell.title.text = movie.name
        
        return cell
    }
    
    
}


//************************************
// MARK: - collection Delegate
//************************************
extension UserMemberCardsView:UICollectionViewDelegate {
    
    func clickMemberCard(_ sender:UIButton) {
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            SaveManager.saveUserMemberCard(baseCards[sender.tag])
        }
        else {
            SaveManager.unsaveUserMemberCard(baseCards[sender.tag])
        }
        
    }
    
}

//************************************
// MARK: - collection Flow Layout
//************************************
extension UserMemberCardsView:UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let font = UIFont.woFont(size: 15, weight: .demibold)
        var labelSize = CGSize()
        let text = baseCards[indexPath.row].label
        
        labelSize = font.sizeOfString(string: text!, constrainedToWidth:1000.0 )
        
        labelSize.width += 20
        labelSize.height = 35
        
        return labelSize

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    
}




class UserCardColCell: UICollectionViewCell {
    
    @IBOutlet weak var button: UIButton!
    
    override var isHighlighted: Bool {
        
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.alpha = self.isHighlighted ? 0.7 : 1
            }
            
        }
        
    }
    
    
}
