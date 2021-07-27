//
//  TextCellTableViewCell.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/25.
//

import UIKit

protocol TextCellTableViewCellDelegate {
    func moreButton(cell: TextCellTableViewCell)
}
class TextCellTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var labelText: UILabel!
    
    @IBOutlet weak var bookmark: UIButton!
    
    @IBAction func bookMark(_ sender: UIButton) {
        sender.scalesLargeContentImage = true
        sender.isSelected = sender.isSelected ? false : true
        bookMarkToggle(sender)
    }
        
    @IBAction func moreButton(_ sender: UIButton) {
        delegate?.moreButton(cell: self)
    }
    
    @IBOutlet weak var dateLabel: UILabel!
    
    
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
    
    func configure(model: Phrase){
        if(model.bookmark) {
            bookmark.isSelected = true
            bookMarkToggle(bookmark)
        }
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormat.date(from: model.date) else {
            print("no date")
            return
        }
        
        let year = date.year
        let month = date.month
        let day = date.day
        let weekDay: String = getWeekDay(atYear: year, atMonth: month, atDay: day)
        
        labelText.text =  model.text
        dateLabel.text = "\(year)년 \(month)월 \(day)일 (\(weekDay))"
    }
    
    
    func checkLeap(year: Int) -> Bool {
        var checkValue: Bool = false
        if year % 4 == 0 && (year % 100 != 0 || year % 400 == 0){
            checkValue = true
        }else {
            checkValue = false
        }
        return checkValue
    }
    
    func getWeekDay(atYear:Int, atMonth:Int, atDay:Int) -> String {
        
        let dayDay:[String] = ["일", "월", "화", "수", "목", "금", "토"]
        var returnValue: String = ""
        var totalDay: Int = 0
        
        for i in 1..<atMonth {
            totalDay += endDayOfMonth(year: atYear, month: i)
        }
        
        var index: Int = 0
        if (totalDay + atDay) % 7 == 0 {
            index = 6
        }else {
            index = (totalDay + atDay) % 7 - 1
        }
        
        returnValue = dayDay[index]
        
        return returnValue
    }
    
    func endDayOfMonth(year: Int, month: Int) -> Int {
        
        var endDay: Int = 0
        let inputMonth: Int = month
        
        let monA: Set = [1,3,5,7,8,10,12]
        let monB: Set = [4,6,9,11]
        
        if monA.contains(inputMonth)  {
            endDay = 31
        }else if monB.contains(inputMonth) {
            endDay = 30
        }
        
        if inputMonth == 2 {
            if checkLeap(year: year) {
                endDay = 29
            }else {
                endDay = 28
            }
        }
        return endDay
    }
    
}
