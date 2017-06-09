//
//  MovieVC.swift
//  WatchOut
//
//  Created by admin on 05/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import UIKit
import AlamofireImage

class MovieVC: UIViewController {

    @IBOutlet weak var topGradient: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var saveButton: UIButton!

    @IBOutlet weak var moviePosterImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationAndGenreLabel: UILabel!
    
    @IBOutlet weak var infosLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var presseLabel: UILabel!
    @IBOutlet weak var pressStarsView: StarRatingView!
    @IBOutlet weak var pressRatingValue: UILabel!
    
    
    @IBOutlet weak var viewersLabel: UILabel!
    @IBOutlet weak var viewersStarsView: StarRatingView!
    @IBOutlet weak var viewerRatingValue: UILabel!
    
    @IBOutlet weak var castingLabel: UILabel!
    @IBOutlet weak var realisatorAndActorsLabel: UILabel!
    
    @IBOutlet weak var synopsisTitleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    
    var movie:WOMovie!
    var isDetailsRequestDone = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        
        setupMovie()
        
        saveButton.isSelected = SavedMovies.movies.contains(movie)
        
    }
    
    func setupMovie() {
        
        //******* Background Images
        if let url = movie.imageURL {
            moviePosterImage.af_setImage(withURL: url)
        }
        
        
        //******* Movie title
        titleLabel.text = movie.name.uppercased()
        
        
        //******* Movie Infos
        if let duration = movie.duration {
            durationAndGenreLabel.text = duration + " - " + movie.genre
        }
        else {
            durationAndGenreLabel.text = movie.genre
        }
        
        //******* Release Date
        if movie.releaseDate != "" {
            infosLabel.text = "INFOS"
            releaseDateLabel.text = "Released on " + movie.releaseDate
        }
        else {
            infosLabel.text = ""
            releaseDateLabel.text = ""
        }
        
        //******* Ratings
        if let pressRating = movie.pressRating {
            pressStarsView.rating = CGFloat(pressRating)
            pressRatingValue.text = "(\(String(format: "%.1f", pressRating)))"
            
        }
        if let viewerRating = movie.userRating {
            viewersStarsView.rating = CGFloat(viewerRating)
            viewerRatingValue.text = "(\(String(format: "%.1f", viewerRating)))"
            
        }
        
        //******* Casting Infos
        if let actors = movie.actors {
            castingLabel.text = "CASTING"
            if let directors = movie.directors {
                realisatorAndActorsLabel.text = "Director : " + directors.joined(separator: ", ") + "\n" + "Actors : " + actors.joined(separator: ", ")
            }
            else {
                realisatorAndActorsLabel.text = "Actors : " + actors.joined(separator: ", ")
            }
            
        }
        else  if let directors = movie.directors {
            castingLabel.text = "CASTING"
            realisatorAndActorsLabel.text = "Director : " + directors.joined(separator: ", ")
            
        }
        else {
            castingLabel.text = ""
            realisatorAndActorsLabel.text = ""
        }
        
        //******* Synopsis
        if let synopsis = movie.synopsis {
            synopsisLabel.text = synopsis
            if synopsisLabel.alpha == 0 {
                UIView.animate(withDuration: 0.2, animations: {
                    self.synopsisLabel.alpha = 1
                    self.synopsisTitleLabel.alpha = 1
                })
            }
        }
        else if !isDetailsRequestDone{
            isDetailsRequestDone = true
            synopsisTitleLabel.alpha = 0
            synopsisLabel.alpha = 0
            _ = APIConnector.getMovieDetails(movie: movie, completion: { [weak self] (movie) in
                self?.movie = movie
                self?.setupMovie()
            })
        }
        else {
            synopsisLabel.text = ""
            synopsisTitleLabel.text = ""
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.bringSubview(toFront: topGradient)
        
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        sender.isSelected ? SavedMovies.save(movie: movie) : SavedMovies.unsave(movie: movie)
        
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)

    }
}



//************************************
// MARK: - ScrollView Delegate
//************************************

extension MovieVC : UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == self.scrollView {
            
            let yOffset = scrollView.contentOffset.y
                        
            topGradient.alpha = min(0.65/40 * yOffset, 0.65)
            
        }
        
        
    }
}
