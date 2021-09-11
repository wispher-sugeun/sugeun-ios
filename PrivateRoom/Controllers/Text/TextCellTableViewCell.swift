//
//  TextCellTableViewCell.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/25.
//

import UIKit

protocol TextCellTableViewCellDelegate {
    func moreButton(cell: TextCellTableViewCell)
    func bookMark(cell: TextCellTableViewCell)
}

class TextCellTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var labelText: UILabel!
    
    @IBOutlet weak var bookmark: UIButton!
    
    @IBAction func bookMark(_ sender: UIButton) {
        sender.scalesLargeContentImage = true
        sender.isSelected = sender.isSelected ? false : true
        bookMarkToggle(sender)
        
        //to server
        delegate?.bookMark(cell: self)
    }
        
    @IBOutlet weak var moreButton: UIButton!
    
    @IBAction func moreButton(_ sender: UIButton) {
        delegate?.moreButton(cell: self)
        
    }
    
    @IBOutlet weak var dateLabel: UILabel!
    
    var indexPath: IndexPath = []
    
    var delegate: TextCellTableViewCellDelegate?
    
    static let identifier = "TextCellTableViewCell"
    
    
    func bookMarkToggle(_ sender: UIButton){
            
        sender.isSelected ?  sender.setBackgroundImage(UIImage(systemName: "bookmark.fill"), for: .normal) :   sender.setBackgroundImage(UIImage(systemName: "bookmark"), for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
        contentView.layer.borderWidth = 2
        contentView.layer.cornerRadius = 10

        contentView.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
           return UINib(nibName: "TextCellTableViewCell", bundle: nil)
    }
    
    func configure(model: PhraseResDTO){
        if(model.bookmark) {
            bookmark.isSelected = true
            bookMarkToggle(bookmark)
        }
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormat.date(from: model.textDate) else {
            print("no date")
            return
        }
        //let cal = Calendar(identifier: .gregorian)
        let year = date.year
        let month = date.month
        let day = date.day
        let week: [String] = ["일", "월", "화", "수", "목", "금", "토"]
        let weekDay = Calendar.current.component(.weekday, from: date) - 1
        //let formatter = DateFormatter()
        //let weekDay: String = TextCellTableViewCell.getWeekDay(atYear: year, atMonth: month, atDay: day)
        
        labelText.text =  model.text
        dateLabel.text = "\(year)년 \(month)월 \(day)일 (\(week[weekDay]))"
    }
    
    
//    static func checkLeap(year: Int) -> Bool {
//        var checkValue: Bool = false
//        if year % 4 == 0 && (year % 100 != 0 || year % 400 == 0){
//            checkValue = true
//        }else {
//            checkValue = false
//        }
//        return checkValue
//    }
    
    static func getWeekDay(atYear:Int, atMonth:Int, atDay:Int) -> String {
        
        let week: [String] = ["일", "월", "화", "수", "목", "금", "토"]
           var totalDay: Int = 0

           if atMonth > 1 {
               for i in 1..<atMonth {
                   let endDay: Int = endOfMonth(atMonth: i)
                   totalDay += endDay
               }
               
               totalDay = totalDay + atDay
               
           }else if atMonth == 1 {
               totalDay = atDay
           }
           
           var index: Int = (totalDay) % 7

           if index > 0 {
               index = index - 1
           }
           
           return week[index]
    }
    
    static func endOfMonth(atMonth: Int) -> Int {
        let set30: [Int] = [1,3,5,7,8,10,12]
        var endDay: Int = 0
        if atMonth == 2 {
            endDay = 28
        }else if set30.contains(atMonth) {
            endDay = 31
        }else {
            endDay = 30
        }
        
        return endDay
    }
}
