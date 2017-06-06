//
//  Popup
//  Busity
//
//  Created by Quentin BEAUDOUIN on 08/06/2016.
//  Copyright © 2016 Instama. All rights reserved.
//

import UIKit

class DatePickerPopup: UIView {
    
    @IBOutlet weak var mainView: UIView!

    @IBOutlet weak var titleLbl: UILabel!

    @IBOutlet weak var datePicker: ClickablePickerView!
    
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var okButton: UIButton!
    
    
    var okAction:((Void) -> (Void))?


    
    override func awakeFromNib() {
    
        super.awakeFromNib()
  
        titleLbl.text = "Pick a date!"
        okButton.setTitle("OK", for: .normal)
        
        datePicker.didSelectAction = { [weak self] in
            
            self?.okAction?()
            self?.hide(good: true)
            
        }
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        
        datePicker.dataSource = self
        datePicker.delegate = self
        
        mainView.layer.cornerRadius = 4
        let shadowPath:UIBezierPath  = UIBezierPath.init(roundedRect: (mainView.bounds), cornerRadius: 4)
        
        mainView.layer.shadowRadius = 20
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOpacity = 0.3
        mainView.layer.shadowOffset = CGSize(width: 0, height: 6)
        mainView.layer.shadowPath = shadowPath.cgPath
        mainView.clipsToBounds = false
        
        okButton.layer.cornerRadius = 17
        okButton.layer.borderColor = UIColor.white.cgColor
        okButton.layer.borderWidth = 1
        
    }

    func showInWindow(_ window:UIWindow) {

        frame = window.bounds
        mainView.transform = CGAffineTransform(translationX: 0, y: -(mainView.frame.size.height + mainView.frame.origin.y / 10))
        
        self.alpha = 0
        
        window.addSubview(self)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.alpha = 1
            self.mainView.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: nil)


    }
    
    
    @IBAction func clickOkButton(_ sender: Any) {
        hide(good: true)
        okAction?()
        
    }

    
    @IBAction func closeClicked(_ sender: Any) {
       // clickOkButton(sender)
        
    }
    



    func hide(good:Bool){
        if good {
            
            UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2, animations: {
                    self.mainView.transform = CGAffineTransform(translationX: 0, y: self.mainView.frame.size.height / 7)
                })
                UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.8, animations: {
                    self.mainView.transform = CGAffineTransform(translationX: 0, y: -(self.mainView.frame.size.height + self.mainView.frame.origin.y/4))
                    self.alpha = 0
                })
                }, completion: { (finished) in
                    self.removeFromSuperview()
            })
        }
        else {
            
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveLinear, animations: {
                
                let rotate = CGFloat.pi / 24.0 * (CGFloat(arc4random_uniform(3)) + 1.5)
                
                
                self.mainView.transform = CGAffineTransform(translationX: 0, y: self.mainView.frame.size.height + self.mainView.frame.origin.y / 4).rotated(by: rotate)
                self.alpha = 0
                }, completion: { (finished) in
                    self.removeFromSuperview()

            })
        }
        
    }

}


//************************************
// MARK: - picker view D/D
//************************************

extension DatePickerPopup:UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 8
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = view as? UILabel == nil ? UILabel() : view as! UILabel
        label.font = UIFont.woFont(size: 15, weight: .demibold)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        if row == 0 {
            label.text = "tomorow"
        }
        else {
            let formater = DateFormatter()
            formater.dateFormat = "MM-dd"
            let date = Date().addingTimeInterval(Double(row+1) * 24 * 3600)
            let dateString = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
            
            label.text = dateString
        }
        
        label.textAlignment = .center
        
        return label
        
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36
    }
    
    
    
    
    
}
