//
//  CalendarViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/03.
//

import UIKit
import FSCalendar
import NVActivityIndicatorView

class CalendarViewController: UIViewController, UIGestureRecognizerDelegate {

    let refreshControl = UIRefreshControl()
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    let indicator = NVActivityIndicatorView(frame: CGRect(x: 162, y: 100, width: 50, height: 50),
                                            type: .circleStrokeSpin,
                                            color: #colorLiteral(red: 0.5568627451, green: 0.6392156863, blue: 0.8, alpha: 1),
                                            padding: 0)
    
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!

    @IBAction func addButton(_ sender: Any) {
        let addCalendarVC = self.storyboard?.instantiateViewController(identifier: "addCalendar") as! AddCalendarViewController
        if(calendar.selectedDate == nil){
            addCalendarVC.selectedDate = calendar.today // 오늘 날로 datepicker 설정
        }else {
            addCalendarVC.selectedDate = calendar.selectedDate // 선택한 날로 datepicker 설정
        }
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.pushViewController(addCalendarVC, animated: true)
    }
    //public var delegate: calendarViewDelegate?
    var schedule = [GetScheduleResponse]()
    var filtered = [GetScheduleResponse]()

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchData()
    }
    
    func fetchData(){
        indicator.startAnimating()
        ScheduleService.shared.getSchedule(completion: { (response) in
            self.schedule = response
            self.filtered = self.schedule
            self.calendar.reloadData()
            self.tableView.reloadData()
        })
        indicator.stopAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did Load")

        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        indicator.frame = CGRect(x: screenWidth/2, y: screenHeight/2, width: 50, height: 50)
        indicator.center = self.view.center
        view.addSubview(indicator)

        calenderSetting()
        tableviewSetting()

        textfieldSetting()

        handleSwipeDelete()
        refreshing()
    }
    
    func refreshing(){
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        refreshControl.beginRefreshing()
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        fetchData()
        refreshControl.endRefreshing()
    }
    
    
    func textfieldSetting(){
        searchTextField.delegate = self
        searchTextField.circle()
        searchTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0));
        searchTextField.leftViewMode = .always
    }
    
    func calenderSetting(){
        calendar.delegate = self
        calendar.dataSource = self
        calendar.scope = .month
        calendar.appearance.todayColor = #colorLiteral(red: 0.8247025609, green: 0.8317034245, blue: 0.9540250897, alpha: 1)
        calendar.appearance.selectionColor = #colorLiteral(red: 0.5568627451, green: 0.6392156863, blue: 0.8, alpha: 1)
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
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(CalendarTableViewCell.nib(), forCellReuseIdentifier: CalendarTableViewCell.identifider)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
//    func handleSwipeDelete() {
//        if let pageController = parent?.parent as? UIPageViewController {
//            let gestureRecognizer = UIPanGestureRecognizer(target: self, action: nil)
//            gestureRecognizer.delaysTouchesBegan = true
//            gestureRecognizer.cancelsTouchesInView = false
//            gestureRecognizer.delegate = self
//            tableView.addGestureRecognizer(gestureRecognizer)
//
//            pageController.scrollView?.canCancelContentTouches = false
//            pageController.scrollView?.panGestureRecognizer.require(toFail: gestureRecognizer)
//        }
//        print("here")
//    }
    
    func handleSwipeDelete() {
        guard let pageController = parent as? UIPageViewController else {
            print("return")
            return
        }

        pageController.scrollView?.canCancelContentTouches = false
        tableView.gestureRecognizers?.forEach { recognizer in
            let name = String(describing: type(of: recognizer))
            guard name == "_UISwipeActionPanGestureRecognizer" else {
                return
            }
            pageController.scrollView?
                .panGestureRecognizer
                .require(toFail: recognizer)
        }
    }

    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }

        let translation = panGesture.translation(in: tableView)
        print(translation)
        return translation.x < 0
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer.view == tableView
    }

}

extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate {
    
    func filtersetDayList(day: Int, month: Int, year: Int){
        filtered.removeAll()
        for i in schedule {
            if (day == DateUtil.parseDateTime(i.scheduleDate).day && month == DateUtil.parseDateTime(i.scheduleDate).month && year == DateUtil.parseDateTime(i.scheduleDate).year){
                print(i)
                filtered.append(i)
            }
        }
            

        }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(date.day)
        
        filtersetDayList(day: date.day, month: date.month, year: date.year)
        self.tableView.reloadData()
        
    }
    
    //event dot
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let events = filtered.map{ DateUtil.parseDateTime($0.scheduleDate) }

        for i in events {
            if(i.day == date.day){
                return 1
            }
        }
        return 0
        
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
    
    //swipe 일정 삭제
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { (action, view, completion) in
            let scheduleTitle = self.filtered[indexPath.row].title
            print(scheduleTitle)
            self.alertWithNoViewController(title: "일정 삭제", message: "\(scheduleTitle) 일정을 삭제하시겠습니까?", completion: { (response) in
                if(response == "OK"){
                    let deleteItem = self.filtered[indexPath.row]
                    ScheduleService.shared.deleteSchedule(scheduleID: deleteItem.scheduleId)
                    
                    self.filtered.remove(at: indexPath.row)
                    tableView.reloadData()
                    self.alertViewController(title: "일정 삭제 완료", message: "일정이 삭제 되었습니다", completion: { (response) in
                        ////TO DO noti delete
                        let notiInfo = LocalNotificationManager()
                        let notiidentifier = "s_\(deleteItem.scheduleId)_"
                        notiInfo.deleteSchedule(notificationId: notiidentifier + "0")
                        
                        for i in deleteItem.selected {
                            notiInfo.deleteSchedule(notificationId: notiidentifier + "\(i)")
                        }
                    })
                    completion(true)
                }else{
                    completion(false)
                }
            })
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false
        return config
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // 수정 모드
        let selectedIndex = filtered[indexPath.row]
        let addCalendarVC = self.storyboard?.instantiateViewController(identifier: "addCalendar") as! AddCalendarViewController
        addCalendarVC.viewMode = true
        addCalendarVC.selectedScheduled = selectedIndex
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.pushViewController(addCalendarVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
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
        textField.resignFirstResponder()
        return true
    }
}
