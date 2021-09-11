//
//  TextBookMarkTableViewCell.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/09/05.
//

import UIKit

class TextBookMarkTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!

    
    @IBOutlet weak var textView: UITextView!
    static let identifier = "TextBookMarkTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "TextBookMarkTableViewCell", bundle: nil)
    }
    
    func configure(model: PhraseResDTO){
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy/MM/dd"
        guard let date = dateFormat.date(from: model.textDate) else {
            dateLabel.text = ""
            return
        }
        
        let year = date.year
        let month = date.month
        let day = date.day
      
        let week: [String] = ["일", "월", "화", "수", "목", "금", "토"]
        let weekDay = Calendar.current.component(.weekday, from: date) - 1
        dateLabel.text = "\(year)년 \(month)월 \(day)일 (\(week[weekDay]))"
        textView.text = model.text
        textView.isEditable = false

    }
        
    
    
}
