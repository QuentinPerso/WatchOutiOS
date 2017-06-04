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

class CinemaHoursCallout : UIView {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var titleHConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomHConstraint: NSLayoutConstraint!
    
    var theaterShowTime:WOTheaterShowtime! {
        didSet {
            titleLabel.text = theaterShowTime.cinema.name
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: "MovieHoursCell", bundle: nil), forCellReuseIdentifier: "MovieHoursCell")
            tableView.reloadData()
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        style()
        
    }
    
    func style() {
        
        let cornerR = CGFloat(4.0)
        
        layer.cornerRadius = cornerR
        
//        tableView.contentInset = UIEdgeInsets(top: cornerR/2, left: 0, bottom: 0, right: 0)
        tableView.layer.cornerRadius = cornerR/2
        
        var shadowPath = UIBezierPath(roundedRect: (bounds), cornerRadius: cornerR)
        
        shadowPath  = UIBezierPath(roundedRect: (bounds), cornerRadius: bounds.height/2)
        layer.shadowRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowPath = shadowPath.cgPath
        clipsToBounds = false
        
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let viewPoint = superview?.convert(point, to: self) ?? point
    
        let view = super.hitTest(viewPoint, with: event)
    
        return view
    }
    
}

extension CinemaHoursCallout:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return theaterShowTime.moviesShowTime.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieHoursCell") as! MovieHoursCell
        let movieShowtime = theaterShowTime.moviesShowTime[indexPath.row]
        cell.pictureImage.af_setImage(withURL: movieShowtime.movie.imageURL, placeholderImage: #imageLiteral(resourceName: "defaultMovie"))
        cell.filmTitleLabel.text = movieShowtime.movie.name
        cell.versionLabel.text = movieShowtime.version + (movieShowtime.screenFormat ?? "")
        print("debug nil something : ", movieShowtime.showTimes?[0].date, movieShowtime.showTimes?[0].hours[0])
        cell.hoursLabel.text = (movieShowtime.showTimes?[0].date)! + " " + (movieShowtime.showTimes?[0].hours[0])!
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}

extension CinemaHoursCallout:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = theaterShowTime.moviesShowTime[indexPath.row].movie
        print(movie?.directors)
        print(movie?.actors)
    }

}
