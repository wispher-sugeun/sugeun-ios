//
//  AddCalendarViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/15.
//

import UIKit

class AddCalendarViewController: UIViewController {
    var viewMode: Bool = false
    var selectedScheduled: GetScheduleResponse?
    var selectedDate: Date?
    var selectedIndex = [Int]()
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var amButton: UIButton!
    @IBOutlet weak var pmButton: UIButton!

    
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var selectedAlarm: UILabel!
    
    var alarmRange = ["x", "하루 전", "2일 전", "3일 전", "4일 전", "5일 전", "6일 전", "일주일 전"]
    
    var isSelectedIndex = false
    var selectedString: String?
    
    lazy var leftButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(buttonPressed(_:)))
        button.tintColor = .black
        button.tag = 1
        return button
        
    }()
    
    lazy var rightButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(buttonPressed(_:)))
        button.tintColor = .black
        button.tag = 2
        return button
        
    }()
    
    @objc private func buttonPressed(_ sender: Any) {
        if let button = sender as? UIBarButtonItem {
            switch button.tag {
            case 1: 
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.navigationController?.popViewController(animated: true)
            case 2:
                //post
                guard let naviTitle = navigationItem.title else {
                    return
                }
                if(naviTitle == "일정 수정"){
                    alertViewController(title: "스케줄 수정", message: "스케줄이 수정되었습니다", completion: { [self](string) in
                        self.navigationController?.popViewController(animated: true)
                        
                        let putSchedule = PutScheduleRequest(scheduleId: selectedScheduled!.scheduleId, userId: selectedScheduled!.userId, title: titleTextField.text!, selected: selectedIndex, scheduleDate: postScheduleFormat(date: datePicker.date))
                        print("post edit Schedule : \(putSchedule)")
                        ScheduleService.shared.editSchedule(schedule: putSchedule)
                    })
                }
                
                else{
                    if(validCheck() == true){
                        alertViewController(title: "스케줄 생성", message: "스케줄이 생성되었습니다", completion: { [self](string) in
                            self.navigationController?.popViewController(animated: true)
                            let userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
                            let scheduleDateString = postScheduleFormat(date: datePicker.date)
                            print(scheduleDateString)
                            let postSchedule = PostScheduleRequest(userId: userId, title: titleTextField.text!, selected: selectedIndex, scheduleDate: scheduleDateString)
                            print("postSchedule : \(postSchedule)")
                            
                            ScheduleService.shared.createSchedule(schedule: postSchedule)
                            
                        })
                    } else {
                        self.alertViewController(title: "알림 생성 실패", message: "비어 있는 곳들을 채워주세요", completion: {(string) in
                        })
                    }
                }
            default:
                print("error")
                
            }
            
            }
        
    }
    
    func postScheduleFormat(date: Date) -> String {
        var string = ""
        string = DateUtil.serverSendDateFormat(date) + " "
        if(!amButton.isSelected){ // true이면
            string += "0" + timeTextField.text! + ":00"
        }else if (!pmButton.isSelected){
            guard let tempInt = Int(timeTextField.text!) else { return "" }
            string += String(tempInt + 12) + ":00"
        }
        return string
    }


    func validCheck() -> Bool{
        if let _ = titleTextField.text, let _ = timeTextField.text, (amButton.isSelected || pmButton.isSelected) != false, selectedIndex != [] {
            return true
        }
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if(isSelectedIndex){
            print("alarm view selected String \(selectedString!)")
            tableView.reloadData()
        }
        
    }

    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("selectedDate \(selectedDate)")

        if(viewMode){
            self.navigationItem.title = "일정 수정"
        }else{
            self.navigationItem.title = "일정 추가"
        }
        
        self.navigationItem.leftBarButtonItem = self.leftButton
        self.navigationItem.rightBarButtonItem = self.rightButton
   
        
        tableViewSetting()
        
        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        dismissKeyboardGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(dismissKeyboardGesture)
        
//        if(selectedDate != nil){
//            datePicker.setDate(selectedDate!, animated: true)
//        }
        
        
    }
    
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
  
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
         self.view.endEditing(true)

   }
    
    func tableViewSetting(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(TitleAddTableViewCell.nib(), forCellReuseIdentifier: TitleAddTableViewCell.identifier)
        tableView.register(DateAddTableViewCell.nib(), forCellReuseIdentifier: DateAddTableViewCell.identifier)
        tableView.register(DateTimeTableViewCell.nib(), forCellReuseIdentifier: DateTimeTableViewCell.identifier)
        tableView.register(AlarmTableViewCell.nib(), forCellReuseIdentifier: AlarmTableViewCell.identifier)
        tableView.isEditing = false
        tableView.allowsSelection = false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }


}

extension AddCalendarViewController: UITableViewDelegate, UITableViewDataSource, AlarmTableViewCellDelegate {
    
    func selected(cell: AlarmTableViewCell) {
        let MakeAlarmView = self.storyboard?.instantiateViewController(identifier: "makeAlarmView") as! MakeAlarmViewController
        self.navigationController?.pushViewController(MakeAlarmView, animated: true)
//        UserDefaults.standard.setValue(self.titleTextField.text, forKey: "titleTextField")
//        UserDefaults.standard.setValue(self.datePicker.text, forKey: "titleTextField")
        //self.present(MakeAlarmView, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
      return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        if(viewMode == true){
            if(indexPath.row == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: TitleAddTableViewCell.identifier) as! TitleAddTableViewCell
                self.titleTextField = cell.titleTextField
                self.titleTextField.text = selectedScheduled?.title
                return cell
            }else if(indexPath.row == 1){
                let cell = tableView.dequeueReusableCell(withIdentifier: DateAddTableViewCell.identifier) as! DateAddTableViewCell
                self.datePicker = cell.datePicker
                let date = DateUtil.parseDateTime(selectedScheduled!.scheduleDate)
                self.datePicker.date = date
                return cell
            }else if(indexPath.row == 2){
                let cell = tableView.dequeueReusableCell(withIdentifier: DateTimeTableViewCell.identifier) as! DateTimeTableViewCell
                self.amButton = cell.amButton
                self.pmButton = cell.pmButton
                self.timeTextField = cell.timeTextField
                let date = DateUtil.parseDateTime(selectedScheduled!.scheduleDate)
                if(date.hour > 12){
                    amButton.isSelected = true
                    self.timeTextField.text = "\(date.hour - 12)"
                }else{
                    pmButton.isSelected = true
                    self.timeTextField.text = "\(date.hour)"
                }
                return cell
            }else if(indexPath.row == 3){
                let cell = tableView.dequeueReusableCell(withIdentifier: AlarmTableViewCell.identifier) as! AlarmTableViewCell
                let indexesToRedraw = [indexPath]
                print(indexesToRedraw)
                self.selectedAlarm = cell.setLabelText
                
                if(selectedScheduled?.selected == []){ // 선택된 알림이 없다면
                    cell.setLabelText.isHidden = true
                }else {
                    var string = ""
                    for i in selectedScheduled!.selected {
                        if(i == selectedScheduled!.selected.last){
                            string += alarmRange[i]
                        }else{
                            string += alarmRange[i] + ", "
                        }
                    }
                    cell.setLabelText.text = string
                    cell.setLabelText.isHidden = false
                }
                viewMode = false
                cell.delegate = self
                return cell
            }
            
        }else {
            if(indexPath.row == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: TitleAddTableViewCell.identifier) as! TitleAddTableViewCell
                self.titleTextField = cell.titleTextField
                return cell
            }else if(indexPath.row == 1){
                let cell = tableView.dequeueReusableCell(withIdentifier: DateAddTableViewCell.identifier) as! DateAddTableViewCell
                self.datePicker = cell.datePicker
                return cell
            }else if(indexPath.row == 2){
                let cell = tableView.dequeueReusableCell(withIdentifier: DateTimeTableViewCell.identifier) as! DateTimeTableViewCell
                self.amButton = cell.amButton
                self.pmButton = cell.pmButton
                self.timeTextField = cell.timeTextField
                return cell
            }else if(indexPath.row == 3){
                let cell = tableView.dequeueReusableCell(withIdentifier: AlarmTableViewCell.identifier) as! AlarmTableViewCell
                let indexesToRedraw = [indexPath]
                print(indexesToRedraw)
                self.selectedAlarm = cell.setLabelText
                
                if(isSelectedIndex == false){ // 선택된 알림이 없다면
                    cell.setLabelText.isHidden = true
                }else {
                    cell.setLabelText.text = selectedString
                    cell.setLabelText.isHidden = false
                }
                
                cell.delegate = self
                return cell
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
