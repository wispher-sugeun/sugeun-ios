//
//  CalendarTableViewCell.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/14.
//

import UIKit

class CalendarTableViewCell: UITableViewCell {

    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBAction func deleteButton(_ sender: Any) {
        
    }
    
    static let identifider = "CalendarTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        deleteButton.isHidden = true
        // Initialization code
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    static func nib() -> UINib {
           return UINib(nibName: "CalendarTableViewCell", bundle: nil)
    }
    
    public func configure(model: Schedule){
        let date = DateUtil.parseDate(model.scheduleDate).day
        
        dayLabel.text = "\(date)" // 날짜만
        nameLabel.text = model.title
        
    }
}
