//
//  CalendarViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/03.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func addScheButton(_ sender: Any) {
        //addCalender segue
    }
    
    var schedule = [Schedule]()
    var filtered = [Schedule]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calenderSetting()
        tableviewSetting()
        schedule.append(Schedule(scheduleId: 1, userId: 1, title: "test1", scheduleDate: "2021/02/04", selectedList: [1,2,3]))
        //searchTextField.delegate = self
        filtered = schedule

    }
    
    func calenderSetting(){
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
