//
//  DateTimeTableViewCell.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/15.
//

import UIKit

class DateTimeTableViewCell: UITableViewCell {

    static let identifier = "DateTimeTableViewCell"
    
    @IBOutlet weak var amButton: UIButton!
    
    @IBOutlet weak var pmButton: UIButton!
    
    @IBAction func amButton(_ sender: UIButton) {
        sender.isSelected = true
        pmButton.isSelected = false
        APButtonSetting(sender: pmButton)
        APButtonSelectedSetting(sender: amButton)
        
        
    }
    
    @IBAction func pmButton(_ sender: UIButton) {
        sender.isSelected = true
        amButton.isSelected = false
        APButtonSetting(sender: amButton)
        APButtonSelectedSetting(sender: pmButton)
        
    
    }
    
    @IBOutlet weak var timeTextField: UITextField!
    
    @IBOutlet weak var minuteTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
         self.contentView.endEditing(true)

   }
    
    static func nib() -> UINib {
           return UINib(nibName: "DateTimeTableViewCell", bundle: nil)
    }
    
    func APButtonSetting(sender: UIButton){
        sender.setTitleColor(UIColor.black, for: .normal)
    }
    
    func APButtonSelectedSetting(sender: UIButton){
        sender.setTitleColor(UIColor.init(cgColor: CGColor(red: 76, green: 88, blue: 144, alpha: 0)), for: .normal)
        
    }
   
    
}
