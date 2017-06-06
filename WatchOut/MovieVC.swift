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
    @IBOutlet weak var viewersLabel: UILabel!
    
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
        
    }
    
    func setupMovie() {
        
        moviePosterImage.af_setImage(withURL: movie.imageURL)
        
        titleLabel.text = movie.name.uppercased()
        if let duration = movie.duration {
            durationAndGenreLabel.text = duration + " - " + movie.genre
        }
        else {
            durationAndGenreLabel.text = movie.genre
        }
        
        
        if let date = movie.releaseDate {
            releaseDateLabel.text = "Released on " + date
        }
        else {
            infosLabel.text = ""
            releaseDateLabel.text = ""
        }
        
        if let actors = movie.actors {
            if let directors = movie.directors {
                realisatorAndActorsLabel.text = "Director : " + directors.joined(separator: ", ") + "\n" + "Actors : " + actors.joined(separator: ", ")
            }
            else {
                realisatorAndActorsLabel.text = "Actors : " + actors.joined(separator: ", ")
            }
            
        }
        else  if let directors = movie.directors {
            realisatorAndActorsLabel.text = "Director : " + directors.joined(separator: ", ")
            
        }
        else {
            castingLabel.text = ""
            realisatorAndActorsLabel.text = ""
        }
        
        if let synopsis = movie.synopsis {
            synopsisLabel.text = synopsis
            if synopsisLabel.alpha == 0 {
                UIView.animate(withDuration: 0.2, animations: {
                    self.synopsisLabel.alpha = 1
                })
            }
        }
        else if !isDetailsRequestDone{
            isDetailsRequestDone = true
            synopsisLabel.alpha = 0
            _ = APIConnector.getMovieSynospsi(movie: movie, completion: { [weak self] (movie) in
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
