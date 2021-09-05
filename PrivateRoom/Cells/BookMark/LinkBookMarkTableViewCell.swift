//
//  LinkBookMarkTableViewCell.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/09/05.
//

import UIKit

class LinkBookMarkTableViewCell: UITableViewCell {
    static let identifier = "LinkBookMarkTableViewCell"
    
    @IBOutlet weak var linkTitle: UILabel!
    
    
    @IBOutlet weak var link: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "LinkBookMarkTableViewCell", bundle: nil)
    }
    
    func configure(model: LinkResDTO){
        linkTitle.text = model.title
        link.text = model.link
        
    }
    
}
