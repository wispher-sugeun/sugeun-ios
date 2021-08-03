//
//  AddCalendarViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/15.
//

import UIKit

class AddCalendarViewController: UIViewController {
    var selectedDate: Date?
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var amButton: UIButton!
    @IBOutlet weak var pmButton: UIButton!

    
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var selectedAlarm: UILabel!
    
    var alarmRange = ["일주일 전", "6일 전", "5일 전", "4일 전", "3일 전", "2일 전", "하루 전"]
    
    var isSelectedIndex = false
    var selectedString: String?
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        //tableView.reloadData()
        //make new alarm
        if(validCheck() == true){
            //post
            alertViewController(title: "알림 생성", message: "알림이 생성되었습니다", completion: {(string) in
                self.dismiss(animated: true, completion: nil)
            })
        }else {
            alertViewController(title: "알림 생성 실패", message: "비어 있는 곳들을 채워주세요", completion: {(string) in
            })
        }
        print(titleTextField.text!)
        print(timeTextField.isSelected)
        print(datePicker.date)
        print(!amButton.isSelected)
        print(!pmButton.isSelected)
    }
    
    func validCheck() -> Bool{
        if let _ = titleTextField.text, let _ = timeTextField.text, (amButton.isSelected || pmButton.isSelected) != false   {
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
        print("selectedDate \(selectedDate)")
        
   
        tableViewSetting()
        
        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        dismissKeyboardGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(dismissKeyboardGesture)
        
        if(selectedDate != nil){
            datePicker.setDate(selectedDate!, animated: true)
        }
        
        
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
