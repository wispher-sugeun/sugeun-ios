//
//  LinkCollectionViewCell.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/21.
//

import UIKit

class LinkCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "LinkCollectionViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    static func nib() -> UINib {
           return UINib(nibName: "LinkCollectionViewCell", bundle: nil)
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
