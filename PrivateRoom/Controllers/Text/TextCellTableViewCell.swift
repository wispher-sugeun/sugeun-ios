//
//  TextCellTableViewCell.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/25.
//

import UIKit

class TextCellTableViewCell: UITableViewCell {
    
    
    static let identifier = "TextCellTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
           return UINib(nibName: "TextCellTableViewCell", bundle: nil)
    }
    
}
