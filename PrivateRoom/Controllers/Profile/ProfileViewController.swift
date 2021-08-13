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
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    var sec = ["내 글", "정보"]
    var sec1 = ["알림 허용", "버전 정보", "로그 아웃"]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorColor = .gray
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
            }else if(indexPath.row == 1){ //앱 버전
                let versionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 42, height: 20))
                var version: String? {
                    guard let dictionary = Bundle.main.infoDictionary, let version = dictionary["CFBundleShortVersionString"] as? String else { return ""}
                    return version
                }
                versionLabel.text = version
                cell.accessoryView = versionLabel
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
        if(indexPath.section == 0 && indexPath.row == 0){ //내 북마크
            performSegue(withIdentifier: "bookmark", sender: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        else if(indexPath.section == 1 && indexPath.row == 0){ // 알림 허용
            performSegue(withIdentifier: "alarmSetting", sender: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }else if(indexPath.section == 1 && indexPath.row == 2){ // 로그아웃
            self.alertWithNoViewController(title: "로그아웃", message: "로그아웃 하시겠습니까?", completion: { (response) in
                if(response) == "OK"
                {
                    UserLoginServices.shared.logout()
                }
            })
            tableView.deselectRow(at: indexPath, animated: true)
        }else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    
}
