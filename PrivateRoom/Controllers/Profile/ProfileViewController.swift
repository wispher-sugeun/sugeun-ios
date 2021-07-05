//
//  ProfileViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/05/10.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var editButton: UIButton!

    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var sec1 = ["알림 허용", "앱 정보", "로그 아웃"]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        profileImage.circle()
        editButton.circle()
        editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
    }
    
    @objc func didTapEditButton(){
        performSegue(withIdentifier: "edit", sender: nil)
    }
    



}

extension ProfileViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return sec1.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        if(indexPath.section == 0){
            if(indexPath.row == 0){ //알림 허용
                let lightSwitch = UISwitch(frame: .zero) as UISwitch
                lightSwitch.isOn = false
                lightSwitch.addTarget(self, action: #selector(switchTriggered), for: .valueChanged)
                lightSwitch.tag = indexPath.row
                cell.accessoryView = lightSwitch
            }
            cell.textLabel?.text = sec1[indexPath.row]
            if(indexPath.row == 2){ //로그 아웃
                cell.textLabel?.textColor = #colorLiteral(red: 0.8832129836, green: 0.4130137265, blue: 0.4133844972, alpha: 1)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    @objc func switchTriggered(sender: UISwitch) {
        sender.isOn ? UserDefaults.standard.setValue(true, forKey: "SwitchisOn") : UserDefaults.standard.setValue(false, forKey: "SwitchisOn")
    }
    
    
}
