//
//  TitleAddTableViewCell.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/15.
//

import UIKit


class TitleAddTableViewCell: UITableViewCell {
    static let identifier = "TitleAddTableViewCell"
    @IBOutlet weak var titleTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
           return UINib(nibName: "TitleAddTableViewCell", bundle: nil)
    }
    
}
