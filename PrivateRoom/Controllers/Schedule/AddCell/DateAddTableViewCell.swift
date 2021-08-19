//
//  DateAddTableViewCell.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/15.
//

import UIKit

class DateAddTableViewCell: UITableViewCell {
    
    static let identifier = "DateAddTableViewCell"
    
    @IBOutlet weak var datePicker: UIDatePicker!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
           return UINib(nibName: "DateAddTableViewCell", bundle: nil)
    }
    
    
    }
    

