//
//  UserMoviesView.swift
//  WatchOut
//
//  Created by admin on 07/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import UIKit
import AlamofireImage

class FilmographyView: UIView {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var participations = [WOPersonParticipation]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
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

extension FilmographyView:UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return participations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserMovieColCell", for: indexPath) as! UserMovieColCell
        
        let movie = participations[indexPath.item].movie
        
        if let url = movie?.imageURL {
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
extension FilmographyView:UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if participations.count > 0 {
            selectMovieAction?(participations[indexPath.item].movie)
            
        }
        
    }
    
}

//************************************
// MARK: - collection Flow Layout
//************************************
extension FilmographyView:UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = collectionView.frame.size
        size.width = 100
        return size
        
    }
    
    
}

