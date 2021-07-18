//
//  AlarmTableViewCell.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/15.
//

import UIKit
protocol AlarmTableViewCellDelegate {
    func selected(cell: AlarmTableViewCell)
}
class AlarmTableViewCell: UITableViewCell {
    static let identifier = "AlarmTableViewCell"
    @IBOutlet weak var setLabelText: UILabel!
    
    @IBOutlet weak var selectButton: UIButton!
    
    @IBAction func selectButton(_ sender: Any) {
        delegate?.selected(cell: self)
    }
    var delegate: AlarmTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
           return UINib(nibName: "AlarmTableViewCell", bundle: nil)
    }
    
}
