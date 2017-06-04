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
        
    }
    
    func style() {
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
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
        cell.pictureImage.af_setImage(withURL: movieShowtime.movie.imageURL)
        cell.filmTitleLabel.text = movieShowtime.movie.name
        cell.versionLabel.text = movieShowtime.version + (movieShowtime.screenFormat ?? "")
        cell.hoursLabel.text = movieShowtime.showTimes[0].date + " " + movieShowtime.showTimes[0].hours[0]
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
