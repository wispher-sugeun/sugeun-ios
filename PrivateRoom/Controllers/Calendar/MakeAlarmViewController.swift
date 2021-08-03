//
//  MakeAlarmViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/15.
//

import UIKit

class MakeAlarmViewController: UIViewController {
    var selectedDate = [Int]()
    
    @IBAction func cancelButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
//        self.dismiss(animated: true, completion: nil)
    }
    
    
    var alarmRange = ["선택하지 않음", "일주일 전", "6일 전", "5일 전", "4일 전", "3일 전", "2일 전", "하루 전"]
    var selectedIndex:[Int] = []
    
    func selectedAlarm(selectedIndex: [Int]) -> String {
        var s: String = ""
        for i in selectedIndex {
            if i == selectedIndex.last {
                s += alarmRange[i]
            }else if(i == 0){
               continue
            }
            else {
                s += alarmRange[i]
                s += ", "
            }
        }
        return s
    }


    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func doneButton(_ sender: Any) {
        
        if let indexPaths: [IndexPath] = tableView.indexPathsForSelectedRows {
            print(indexPaths)
            if(indexPaths.count == 1 && indexPaths[0][1] == 0){ //선택하지 않음 클릭시
                print("선택하지 않음 클릭")
                self.navigationController?.popViewController(animated: true)
                let previousVC = self.navigationController?.viewControllers.last as! AddCalendarViewController
                previousVC.selectedString = ""
                previousVC.isSelectedIndex = true
            }
            else if indexPaths.count == 0 {
                let alertVC = UIAlertController(title: "알람 선택", message: "알람을 하나 이상 선택해주세요", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                self.present(alertVC, animated: true, completion: nil)
                alertVC.addAction(OKAction)
                
            }else{
                for i in indexPaths {
                    self.selectedIndex.append(i.last!)
                }

                self.navigationController?.popViewController(animated: true)
                let previousVC = self.navigationController?.viewControllers.last as! AddCalendarViewController
                previousVC.selectedString = selectedAlarm(selectedIndex: selectedIndex)
                previousVC.isSelectedIndex = true
               
                //addCalendarVC.tableView.reloadRows(at: [[0, 3]], with: .fade)
                //self.dismiss(animated: true, completion: nil)
                
                
//                addCalendarVC.selectedIndex = selectedIndex
//                addCalendarVC.titleTextField.text = UserDefaults.standard.string(forKey: "titleTextField")
//                self.present(addCalendarVC, animated: true, completion: nil)
               // self.dismiss(animated: true, completion: nil)
            }
        }else{
            let alertVC = UIAlertController(title: "알람 선택", message: "알람을 하나 이상 선택해주세요", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertVC.addAction(OKAction)
            self.present(alertVC, animated: true, completion: nil)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsMultipleSelection = true
    }
}

extension MakeAlarmViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarmRange.count // 7 days
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        if(indexPath.row == 0){ // default setting
            cell.isSelected = true
            cell.selectionStyle = .gray
        }
        cell.textLabel?.text = alarmRange[indexPath.row]
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        cell.isSelected = cell.isSelected == true ? false : true
        if cell.isSelected == true {
            print(cell.isSelected)
            cell.selectionStyle = .gray
        }else {
            print(cell.isSelected)
            cell.textLabel?.textColor = UIColor.black
        }
        

    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("deselect called")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.isSelected = false
        cell.selectionStyle = .none

    }
    
    
    
}
