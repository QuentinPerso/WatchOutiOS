//
//  AZCalloutView.swift
//  AZCustomCallout
//
//  Created by Alexander Andronov on 23/06/16.
//  Copyright © 2016 Alexander Andronov. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

class TheaterShowTimesView : UIView {
    
    let padInsetBot:CGFloat = 60.0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var titleHConstraint: NSLayoutConstraint!
    
    var didSelectMovieAction:((WOMovie) -> (Void))?
    
    var theaterShowTime:WOTheaterShowtime! {
        didSet {
            UIView.transition(with: titleLabel, duration: 0.2, options: [], animations: {
                self.titleLabel.text = self.theaterShowTime.cinema.name.uppercased()
            }, completion: nil)
            
            tableView.delegate = self
            tableView.dataSource = self
            //tableView.register(UINib(nibName: "MovieHoursCell", bundle: nil), forCellReuseIdentifier: "MovieHoursCell")
            tableView.reloadSections([0], with: .left)
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.contentInset = UIEdgeInsetsMake(0, 0, padInsetBot, 0)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        style()
    }
    
    func style() {
        
        let cornerR = CGFloat(12.0)
        
        layer.cornerRadius = cornerR
        
//        tableView.contentInset = UIEdgeInsets(top: cornerR/2, left: 0, bottom: 0, right: 0)
//        tableView.layer.cornerRadius = cornerR/2
        
        let shadowPath = UIBezierPath(roundedRect: (bounds), cornerRadius: cornerR)
    
        layer.shadowRadius = 1
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: -1)
        layer.shadowPath = shadowPath.cgPath
        clipsToBounds = false
        
    }
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        let viewPoint = superview?.convert(point, to: self) ?? point
//    
//        let view = super.hitTest(viewPoint, with: event)
//    
//        return view
//    }
//    
}

extension TheaterShowTimesView:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theaterShowTime.moviesShowTime.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieHoursCell") as! MovieHoursCell
        let movieShowtime = theaterShowTime.moviesShowTime[indexPath.row]
        cell.pictureImage.af_setImage(withURL: movieShowtime.movie.imageURL, placeholderImage: #imageLiteral(resourceName: "defaultMovie"))
        cell.filmTitleLabel.text = movieShowtime.movie.name
        cell.versionLabel.text = movieShowtime.version + (movieShowtime.screenFormat ?? "")
        if let date = movieShowtime.showTimes?[0].date, let hours = movieShowtime.showTimes?[0].hours {
            cell.hoursLabel.text = date + " -- " + hours.joined(separator: " • ")
        }
        else {
            cell.hoursLabel.text = "N/A"
//            cell.hoursLabel.text = "Bug date: \(String(describing: movieShowtime.showTimes?[0].date)), hours[0]: \(String(describing:  movieShowtime.showTimes?[0].hours[0]))"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}

extension TheaterShowTimesView:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let movie = theaterShowTime.moviesShowTime[indexPath.row].movie {
            didSelectMovieAction?(movie)
        }
        
    }

}




