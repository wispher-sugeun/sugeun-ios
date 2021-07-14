//
//  CalendarViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/03.
//

import UIKit
import FSCalendar


//TO DO - edit

protocol calendarViewDelegate: NSObject {
    func editButton()
}

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func editButton(_ sender: Any) {
        delegate?.editButton()
    }
    
    @IBAction func addScheButton(_ sender: Any) {
        performSegue(withIdentifier: "addCalender", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let addCalender = segue.destination as? AddCalendarViewController
        if(calendar.selectedDate == nil){
            addCalender!.selectedDate = Date().addingTimeInterval(86400)
        }else {
            addCalender!.selectedDate = calendar.selectedDate?.addingTimeInterval(86400) // adding one day
        }
        
        
    }
    var delegate: calendarViewDelegate?
    var schedule = [Schedule]()
    var filtered = [Schedule]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calenderSetting()
        tableviewSetting()
        schedule.append(Schedule(scheduleId: 1, userId: 1, title: "test1", scheduleDate: "2021/07/04", selectedList: [1,2,3]))
        
        schedule.append( Schedule(scheduleId: 2, userId: 2, title: "test2", scheduleDate: "2021/07/14", selectedList: [1,2]))

        schedule.append(Schedule(scheduleId: 3, userId: 3, title: "test3", scheduleDate: "2021/07/15", selectedList: [1,2,7]))

   
        searchTextField.delegate = self
        filtered = schedule

    }
    
    func calenderSetting(){
        calendar.delegate = self
        calendar.dataSource = self
        calendar.scope = .month
        calendar.scrollDirection = .vertical
        calendar.allowsMultipleSelection = false
        calendar.locale = Locale(identifier: "ko_KR")
        
        
        // 달력의 년월 글자 바꾸기
        calendar.appearance.headerDateFormat = "YYYY년 M월" // 달력의 요일 글자 바꾸는 방법 1
        calendar.locale = Locale(identifier: "ko_KR") // 달력의 요일 글자 바꾸는 방법 2
        calendar.calendarWeekdayView.weekdayLabels[0].text = "일"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "월"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "화"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "수"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "목"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "금"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "토"

    
    }
    
    func tableviewSetting(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CalendarTableViewCell.nib(), forCellReuseIdentifier: CalendarTableViewCell.identifider)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    


}

extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate {
    
    func filtersetDayList(day: Int, month: Int, year: Int){
        filtered.removeAll()
        for i in schedule {
            print(DateUtil.parseDate(i.scheduleDate).day)
            if (day == DateUtil.parseDate(i.scheduleDate).day && month == DateUtil.parseDate(i.scheduleDate).month && year == DateUtil.parseDate(i.scheduleDate).year){
                print(i)
                filtered.append(i)
            }
        }
    
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(date.day)
        
        filtersetDayList(day: date.day, month: date.month, year: date.year)
        tableView.reloadData()
        
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let events = schedule.map{ DateUtil.parseDate($0.scheduleDate) }
        if events.contains(date) {
            return 1
        } else {
            return 0
        }

        
    }
    
}


extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CalendarTableViewCell.identifider) as! CalendarTableViewCell
        
        cell.configure(model: filtered[indexPath.row])
        return cell
    }
    
    
}

extension CalendarViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let searchText = textField.text! + string
        if searchText.count >= 2{
            filtered = schedule.filter({ (result) -> Bool in
                result.title.range(of: searchText, options: .caseInsensitive) != nil
            })
        }else {
            filtered = schedule
        }
       
        tableView.reloadData()
        return true
     
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        self.filtered.removeAll()
        for i in schedule {
            filtered.append(i)
        }
        tableView.reloadData()
        return false
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.count != 0 {
            self.filtered.removeAll()
            for str in schedule {
                let name = str.title.lowercased()
                let range = name.range(of: textField.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil {
                    self.filtered.append(str)
                }
                
            }
        }
        tableView.reloadData()
        return true
    }
}
