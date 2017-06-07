//
//  UserMoviesCell.swift
//  WatchOut
//
//  Created by admin on 07/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import UIKit
import AlamofireImage

class UserMoviesView: UIView {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var savedMovies = SaveManager.savedMovies
    
    var selectMovieAction:((WOMovie)->())?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
    }

}

//************************************
// MARK: - collection Data Source
//************************************

extension UserMoviesView:UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserMovieColCell", for: indexPath) as! UserMovieColCell
        
        let movie = savedMovies[indexPath.item]
        
        if let url = movie.imageURL {
            let filter = AspectScaledToFillSizeFilter(size: cell.picture.frame.size)
            let placeH = filter.filter(#imageLiteral(resourceName: "defaultMovie"))
            cell.picture.af_setImage(withURL: url, placeholderImage: placeH, filter: filter)
        }
        //cell.title.text = movie.name
        
        return cell
    }
    
    
}


//************************************
// MARK: - collection Delegate
//************************************
extension UserMoviesView:UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if savedMovies.count > 0 {
            selectMovieAction?(savedMovies[indexPath.item])
            
        }
        
    }
    
}

//************************************
// MARK: - collection Flow Layout
//************************************
extension UserMoviesView:UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = collectionView.frame.size
        size.width = 100
        return size
        
    }
    
    
}




class UserMovieColCell: UICollectionViewCell {
    
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    override var isHighlighted: Bool {
        
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.alpha = self.isHighlighted ? 0.7 : 1
            }
            
        }
        
    }
    
    
}
