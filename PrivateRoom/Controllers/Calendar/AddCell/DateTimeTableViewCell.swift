//
//  DateTimeTableViewCell.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/15.
//

import UIKit

class DateTimeTableViewCell: UITableViewCell {

    
    @IBOutlet weak var amButton: UIButton!
    
    @IBOutlet weak var pmButton: UIButton!
    
    @IBAction func amButton(_ sender: UIButton) {
        if(sender.isSelected == true) {
            amButton.setTitleColor(UIColor.init(cgColor: CGColor(red: 76, green: 88, blue: 144, alpha: 1)), for: .normal)
            pmButton.setTitleColor(UIColor.black, for: .normal)
        }
        
        
    }
    
    @IBAction func pmButton(_ sender: UIButton) {
        if(sender.isSelected == true) {
            pmButton.setTitleColor(UIColor.init(cgColor: CGColor(red: 76, green: 88, blue: 144, alpha: 1)), for: .normal)
            amButton.setTitleColor(UIColor.black, for: .normal)
        }
    
    }
    @IBOutlet weak var timeTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
