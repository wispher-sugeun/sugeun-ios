//
//  AlarmViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/14.
//

import UIKit

class AlarmViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "알림 설정"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
  

}
extension AlarmViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = "알림 설정"
        let lightSwitch = UISwitch(frame: .zero) as UISwitch
        lightSwitch.isOn = UserDefaults.standard.bool(forKey: UserDefaultKey.switchIsOn)
        lightSwitch.addTarget(self, action: #selector(switchTriggered), for: .valueChanged)
        lightSwitch.tag = indexPath.row
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = lightSwitch
        return cell
    }
    
    @objc func switchTriggered(sender: UISwitch) {
        sender.isOn ? UserDefaults.standard.setValue(true, forKey: UserDefaultKey.switchIsOn) : UserDefaults.standard.setValue(false, forKey: UserDefaultKey.switchIsOn)
        UserProfileService.shared.updateAlarmValue()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
}
