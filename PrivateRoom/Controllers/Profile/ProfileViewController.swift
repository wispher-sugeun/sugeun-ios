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
    
    var sec = ["내 글", "정보"]
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
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 1
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        if(indexPath.section == 0 && indexPath.row == 0){
            cell.textLabel?.text = "내 북마크"
            cell.accessoryType = .disclosureIndicator
        }
        if(indexPath.section == 1){
            if(indexPath.row == 0){ //알림 허용
                cell.textLabel?.text = sec1[indexPath.row]
                cell.accessoryType = .disclosureIndicator
                return cell
            }else if(indexPath.row == 1){ //앱 정보
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = sec1[indexPath.row]
                return cell
            } else if(indexPath.row == 2){ //로그 아웃
                cell.textLabel?.text = sec1[indexPath.row]
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.textColor = #colorLiteral(red: 0.8832129836, green: 0.4130137265, blue: 0.4133844972, alpha: 1)
                return cell
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0 && indexPath.row == 0){
            performSegue(withIdentifier: "bookmark", sender: nil)
        }
        else if(indexPath.section == 1 && indexPath.row == 0){
            performSegue(withIdentifier: "alarmSetting", sender: nil)
        }else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    
}
