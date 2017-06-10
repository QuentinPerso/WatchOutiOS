//
//  NowAroundself.swift
//  WatchOut
//
//  Created by admin on 09/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import UIKit
import AlamofireImage

class NowAroundCollectionView: UIView {
    
    @IBOutlet weak var carousel:iCarousel!
    
    var movieCinemasArray = [WOMovieCinemas]()
    
    var didSelectMovieAction:((WOMovie) -> (Void))?
    var didBeginScrollAction:((Void) -> (Void))?
    var didScrollToMovieAction:((WOMovieCinemas) -> (Void))?
    
    var isScrolling = false
    
    func setup() {
        
        self.backgroundColor = UIColor.clear
        carousel.type = .coverFlow
        carousel.delegate = self
        carousel.dataSource = self
 
    }
    
    func reload(theaterShowTimes:[WOTheaterShowtime]) {
        
        movieCinemasArray = [WOMovieCinemas]()
        for theaterShowTime in theaterShowTimes {
            for movieST in theaterShowTime.moviesShowTime {
                let movieCinema = WOMovieCinemas()
                movieCinema.movie = movieST.movie
                if movieCinemasArray.count > 0 {
                    for movieCine in movieCinemasArray {
                        if movieCine == movieCinema {
                            movieCine.cinemas.append(theaterShowTime.cinema)
                            break
                        }
                        else if !movieCinemasArray.contains(movieCinema) {
                            movieCinema.cinemas = [theaterShowTime.cinema]
                            movieCinemasArray.append(movieCinema)
                            
                        }
                    }
                }
                else {
                    movieCinema.cinemas = [theaterShowTime.cinema]
                    movieCinemasArray.append(movieCinema)
                }
                
            }
        }
        carousel.reloadData()
        carouselDidEndScrollingAnimation(carousel)
    }

}

//************************************
// MARK: - collection Data Source
//************************************

extension NowAroundCollectionView : iCarouselDataSource, iCarouselDelegate {
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return movieCinemasArray.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        

        var cell: MovieAroundCellView
        
        //reuse view if available, otherwise create a new view
        if let view = view as? MovieAroundCellView {
            cell = view
        }
        else {
            //don't do anything specific to the index within
            //this `if ... else` statement because the view will be
            //recycled and used with other index values later
            cell = Bundle.main.loadNibNamed("MovieAroundCellView", owner: self, options: nil)?[0] as! MovieAroundCellView
            cell.frame = CGRect(x: 0, y: 0, width: 110, height: carousel.frame.size.height)
            
        }
        
        if movieCinemasArray.count > index, let movie = movieCinemasArray[index].movie {
            
            if let url = movie.imageURL {
                let filter = AspectScaledToFillSizeFilter(size: cell.pictureImage.frame.size)
                let placeH = filter.filter(#imageLiteral(resourceName: "defaultMovie"))
                cell.pictureImage.af_setImage(withURL: url, placeholderImage: placeH, filter: filter)
                cell.titleLabel.isHidden = true
            }
            else {
                cell.titleLabel.isHidden = false
                cell.pictureImage.image = #imageLiteral(resourceName: "defaultMovie")
                cell.titleLabel.text = movie.name
            }
            
            
        }

        return cell
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        if index == carousel.currentItemIndex, movieCinemasArray.count > index, let movie = movieCinemasArray[index].movie {
            didSelectMovieAction?(movie)
        }
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.1
        }
        return value
    }
    
    func carouselDidEndScrollingAnimation(_ carousel: iCarousel) {
        
        let index = carousel.currentItemIndex
        if movieCinemasArray.count > index,index >= 0 {
            let movieCines = movieCinemasArray[index]
            didScrollToMovieAction?(movieCines)
        }
        
    }
    
    func carouselWillBeginDragging(_ carousel: iCarousel) {
        didBeginScrollAction?()
    }
    
    
}


// MARK: - -------------  CELL ----------------

class MovieAroundCellView: UIView {
    

    @IBOutlet weak var pictureImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
}
