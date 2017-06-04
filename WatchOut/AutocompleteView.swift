//
//  AutocompleteView.swift
//  MarksHot
//
//  Created by Quentin Beaudouin on 25/02/2017.
//  Copyright © 2017 Quentin Beaudouin. All rights reserved.
//

import UIKit

class AutocompleteView: UIView, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView:UITableView!
    
    var didSelectSuggestion:((AnyObject)->())?
    
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
        
        if let resultMovie = autocompletes[indexPath.row] as? WOMovieSearchResult {
            cell.filmTitleLabel.text = resultMovie.name + " " + resultMovie.productionYear
            cell.filmCastLabel.text = resultMovie.directors
        }
        else if let resultPerson = autocompletes[indexPath.row] as? WOPersonSearchResult {
            cell.filmTitleLabel.text = resultPerson.name
            cell.filmCastLabel.text = resultPerson.activities
        }

        
        

        return cell
        
        
        
    }
    
    //************************************
    // MARK: - Table view Delegate
    //************************************
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectSuggestion?(autocompletes[indexPath.row])
        
    }

}


// MARK: - -------------  CELL ----------------

class AutocompleteCell: UITableViewCell {
    
    static let identifier = "AutocompleteCell"
    
    
    @IBOutlet weak var filmCastLabel: UILabel!
    @IBOutlet weak var filmTitleLabel: UILabel!
    
}
