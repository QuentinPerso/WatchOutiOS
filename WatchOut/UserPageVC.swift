//
//  UserPageVC.swift
//  MarksHot
//
//  Created by Quentin Beaudouin on 25/02/2017.
//  Copyright © 2017 Quentin Beaudouin. All rights reserved.
//

import UIKit
import MessageUI

class UserPageVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topGradient: UIImageView!
    @IBOutlet weak var myMoviesView: UserMoviesView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        myMoviesView.selectMovieAction = { [weak self] movie in
            self?.showMovieVC(movie)
        }
    }
    

    @IBAction func backButtonClicked(_ sender: Any) {
        
//        _ = self.navigationController?.popViewController(animated: true)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        myMoviesView.reload()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.bringSubview(toFront: topGradient)
        
    }
    
    func showMailComposer(){
        
        let messageObject = "CONTACT_US_MAIL".localized
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["markscat@marksapp.io"])
        mailComposerVC.setSubject(messageObject)
        
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            // self.showSendMailErrorAlert()
        }
        
    }

    

}

//************************************
// MARK: - Navigation
//************************************
extension UserPageVC {
    
    func showMovieVC(_ movie:WOMovie) {
        
        let viewController = UIStoryboard(name: "MovieDetails", bundle: nil).instantiateInitialViewController() as! MovieVC
        
        viewController.movie = movie
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}



//************************************
// MARK: - Mail Compose View Controller Delegate
//************************************

extension UserPageVC: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}


//************************************
// MARK: - ScrollView Delegate
//************************************

extension UserPageVC : UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == self.scrollView {
            
            let yOffset = scrollView.contentOffset.y
            
            topGradient.alpha = min(0.65/40 * yOffset, 0.65)
            
        }
        
        
    }
}
