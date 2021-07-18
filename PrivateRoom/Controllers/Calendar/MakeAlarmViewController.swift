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
        self.dismiss(animated: true, completion: nil)
    }
    
    var previousVC: AddCalendarViewController?
    
    var alarmRange = ["일주일 전", "6일 전", "5일 전", "4일 전", "3일 전", "2일 전", "하루 전"]
    var selectedIndex:[Int] = []
    
    private(set) var selectedAlarm: String? = nil {
      didSet {
        guard let previousVC = previousVC else { return }
        if(selectedIndex != []){
            var s = ""
            for i in selectedIndex {
                if i == selectedIndex.last {
                    s += alarmRange[i]
                }else {
                    s += alarmRange[i]
                    s += ", "
                }
            }
            previousVC.selectedAlarm.text = s
        }
        
      }
    }

    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func doneButton(_ sender: Any) {
        
        if let indexPaths: [IndexPath] = tableView.indexPathsForSelectedRows {
            print(indexPaths)
            if indexPaths.count == 0 {
                let alertVC = UIAlertController(title: "알람 선택", message: "알람을 하나 이상 선택해주세요", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                self.present(alertVC, animated: true, completion: nil)
                alertVC.addAction(OKAction)
                
            }else{
                for i in indexPaths {
                    self.selectedIndex.append(i.last!)
                }
                print(selectedIndex)
                let addCalendarVC = self.storyboard?.instantiateViewController(identifier: "addCalendar") as! AddCalendarViewController
                addCalendarVC.selectedIndex = selectedIndex
                print(addCalendarVC.selectedIndex)
                
                //addCalendarVC.tableView.reloadRows(at: [[0, 3]], with: .fade)
                self.dismiss(animated: true, completion: nil)
                
                
//                addCalendarVC.selectedIndex = selectedIndex
//                addCalendarVC.titleTextField.text = UserDefaults.standard.string(forKey: "titleTextField")
//                self.present(addCalendarVC, animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            }
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
