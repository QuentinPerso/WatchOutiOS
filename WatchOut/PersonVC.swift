//
//  PersonVC.swift
//  WatchOut
//
//  Created by admin on 05/06/2017.
//  Copyright © 2017 quentin. All rights reserved.
//

import UIKit
import AlamofireImage

class PersonVC: UIViewController {

    @IBOutlet weak var topGradient: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var saveButton: UIButton!

    @IBOutlet weak var pictureImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var birtDateNationalityLabel: UILabel!
    
    @IBOutlet weak var activityTitleLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    
    @IBOutlet weak var filmographyView: FilmographyView!
    
    
    var personID:Int!
    fileprivate var person:WOPerson?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        
        APIConnector.getPersonDetails(personID: personID) { [weak self] (person) in
            if person == nil || self == nil { return }
            self?.person = person
            UIView.transition(with: self!.view, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self?.setupPerson(person!)
            }, completion: nil)
            self?.saveButton.isSelected = SavedPersons.persons.contains(person!)
            
        }
        
        
        
    }
    
    func setupPerson(_ person:WOPerson) {
        
        //******* Background Images
        pictureImage.af_setImage(withURL: person.imageURL)
        
        //******* Name And Infos
        nameLabel.text = person.name
        
        if let natio = person.nationality, let bd = person.birthDate {
            birtDateNationalityLabel.text = natio + " \(bd)"
        }
        else if let natio = person.nationality {
            birtDateNationalityLabel.text = natio
        }
        else if let bd = person.birthDate {
            birtDateNationalityLabel.text = "\(bd)"
        }
        else {
            birtDateNationalityLabel.text = ""
        }

        //******* Activities
        if let activities = person.activities {
            activityLabel.text = activities
        }
        
        //******* Filmography
        if let participation = person.particiations {
            filmographyView.participations = participation
            filmographyView.selectMovieAction = { [weak self] movie in
                self?.showMovieVC(movie)
            }
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
        
        if person == nil { return }
        
        sender.isSelected = !sender.isSelected
        sender.isSelected ? SavedPersons.save(person!) : SavedPersons.unsave(person!)
        
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)

    }
}

//************************************
// MARK: - Navigation
//************************************
extension PersonVC {
    
    func showMovieVC(_ movie:WOMovie) {
        
        let viewController = UIStoryboard(name: "MovieDetails", bundle: nil).instantiateInitialViewController() as! MovieVC
        
        viewController.movie = movie
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}



//************************************
// MARK: - ScrollView Delegate
//************************************

extension PersonVC : UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == self.scrollView {
            
            let yOffset = scrollView.contentOffset.y
                        
            topGradient.alpha = min(0.65/40 * yOffset, 0.65)
            
        }
        
        
    }
}
