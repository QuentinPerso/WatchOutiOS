//
//  AutocompleteView.swift
//  MarksHot
//
//  Created by Quentin Beaudouin on 25/02/2017.
//  Copyright © 2017 Quentin Beaudouin. All rights reserved.
//

import UIKit
import AlamofireImage

class AutocompleteView: UIView, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var dimeBGView:UIView!
    @IBOutlet weak var tableView:UITableView!
    
    var didTapBG:(()->())?
    var didSelectSuggestion:((AnyObject)->())?
    var didClickDetailsSuggestion:((AnyObject)->())?
    
    var autocompletes = [AnyObject]() {
        
        didSet {
            if autocompletes.count == 0, tableView.alpha == 1  {
                UIView.animate(withDuration: 0.15, animations: {
                    self.tableView.alpha = 0
                })
                
                self.tableView.isUserInteractionEnabled = false
            }
            else if autocompletes.count > 0, tableView.alpha == 0  {
                UIView.animate(withDuration: 0.15, animations: {
                    self.tableView.alpha = 1
                })
                self.tableView.isUserInteractionEnabled = true
            }
            self.tableView.reloadData()
        }
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.dataSource = self
        tableView.delegate = self
        dimeBG(false, animated: false)
        
    }
    
    func updateLayout(topBarHeight:CGFloat) {
        
        tableView.contentInset = UIEdgeInsetsMake(topBarHeight + 8, 0, 0, tableView.contentInset.bottom)
        tableView.scrollIndicatorInsets = UIEdgeInsetsMake(topBarHeight + 8, 0, 0, tableView.contentInset.bottom)
        
    }
    
    @IBAction func dimeViewTapped(_ sender: Any) {
        didTapBG?()

    }
    
    func dimeBG(_ dimed:Bool, animated:Bool){
        
        UIView.animate(withDuration: animated ? 0.25:0) {
            self.dimeBGView.alpha = dimed ? 1:0
        }
        dimeBGView.isUserInteractionEnabled = dimed
        
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let hit = super.hitTest(point, with: event)
        
        if hit == self { return nil }

        return hit
    }
    
    //************************************
    // MARK: - Table view Data Source
    //************************************
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return autocompletes.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: AutocompleteCell.identifier, for: indexPath) as! AutocompleteCell
        
        if let resultMovie = autocompletes[indexPath.row] as? WOMovie {
            if let url = resultMovie.imageURL {
                let filter = AspectScaledToFillSizeFilter(size: cell.pictureImage.frame.size)
                let placeH = filter.filter(#imageLiteral(resourceName: "defaultMovie"))
                cell.pictureImage.af_setImage(withURL: url, placeholderImage: placeH, filter: filter)
            }
            cell.mainLabel.text = resultMovie.name + " " + resultMovie.productionYear
            cell.secondLabel.text = resultMovie.directors?.joined(separator: ", ")
            
        }
        else if let resultPerson = autocompletes[indexPath.row] as? WOPerson {
            if let url = resultPerson.imageURL {
                let filter = AspectScaledToFillSizeCircleFilter(size: cell.pictureImage.frame.size)
                let placeH = filter.filter(#imageLiteral(resourceName: "defaultPerson"))
                cell.pictureImage.af_setImage(withURL: url, placeholderImage: placeH, filter: filter)
            }
            cell.mainLabel.text = resultPerson.name
            cell.secondLabel.text = resultPerson.activities
            
        }

        cell.detailButton.tag = indexPath.row
        cell.detailButton.addTarget(self, action: #selector(self.clickDetailButton(_:)), for: .touchUpInside)
        cell.detailButton.isHidden = false

        return cell
        
        
        
    }
    
    //************************************
    // MARK: - Table view Delegate
    //************************************
    
    func clickDetailButton(_ sender:UIButton) {
        
        didClickDetailsSuggestion?(autocompletes[sender.tag])
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectSuggestion?(autocompletes[indexPath.row])
        
    }

}


// MARK: - -------------  CELL ----------------

class AutocompleteCell: UITableViewCell {
    
    static let identifier = "AutocompleteCell"
    
    
    @IBOutlet weak var pictureImage: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    
}
