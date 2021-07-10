//
//  ProfileEditViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/04.
//

import UIKit
import PhotosUI

class ProfileEditViewController: UIViewController {

    
    var settingArray:[String] = ["아이디", "비밀번호 변경"]
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var editButton: UIButton!
    @IBAction func editButton(_ sender: Any) {
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        //UserService post
        alertDone(title: "수정 완료",message: "회원 정보가 정상적으로 수정되었습니다", completionHandler: { response in
            if response == "OK" {
                //UserService post
                
                self.dismiss(animated: true, completion: nil)
            }
        })
       
        
    }
    @IBAction func quitApp(_ sender: Any) {
        //UserService
        alertDoneCancel(title: "회원 탈퇴", message: "회원 탈퇴하시겠습니까?", completionHandler: { action in
            if(action == "OK"){
                //userService 회원 탈퇴
                self.alertDone(title: "회원 탈퇴 완료", message: "그동안 저의 앱을 이용해주셔서 감사합니다.", completionHandler: {action in print(action)
                    exit(0)
                    
                })
            }
        })
    }
    
    private var nameTextField: UITextField = {
        var textfield = UITextField()
        return textfield
    }()
    
    private var passwordTextField: UITextField = {
        var textfield = UITextField()
        return textfield
    }()
    
    var configuration = PHPickerConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.circle()
        editButton.circle()
        configuration.filter = .any(of: [.images])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
 
    }
    
    func alertDone(title: String, message: String, completionHandler: @escaping ((String) -> Void)) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { action in  completionHandler("OK")})
        alertVC.addAction(OKAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func alertDoneCancel(title: String, message: String, completionHandler: @escaping ((String) -> Void)) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { action in  completionHandler("OK")})
        let CANCELAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        alertVC.addAction(OKAction)
        alertVC.addAction(CANCELAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    

}

extension ProfileEditViewController: UITableViewDelegate, UITableViewDataSource, IDInputTableViewCellDelegate {
    
    //check for validate name from server
    func haveSamenickName(name: String) -> Bool{
        if name == "jouureee"{
           return true
        }
        return false
    }
    
    func correctPassword(password: String) -> Bool {
        if(password == "1234"){
            return true
        }
        return false
    }
    
    //alertVC with textfield
    func alertEditName(textfield: UITextField){
        let alertVC = UIAlertController(title:"아이디 수정", message: nil, preferredStyle: .alert)
       
        alertVC.addTextField(configurationHandler: { (textField) -> Void in
            self.nameTextField = textField
            self.nameTextField.placeholder = "새로 수정할 아이디를 입력해주세요"
        })
        let label = UILabel(frame:CGRect(x: 0, y: 40, width: 270, height:18))
        let editAction = UIAlertAction(title: "EDIT", style: .default, handler: { [self] (action) -> Void in
            if let userInput = self.nameTextField.text  {
               
                label.isHidden = true
                
                label.textColor = .red
                label.font = label.font.withSize(12)
                label.textAlignment = .center
                label.text = ""
                alertVC.view.addSubview(label)
                
                if userInput == ""{
                    label.text = "이름을 입력해주세요"
                    label.isHidden = false
                    self.present(alertVC, animated: true, completion: nil)

                }else if self.haveSamenickName(name: userInput){
                    label.text = "이미 같은 이름을 가진 사용자가 있습니다"
                    label.isHidden = false
                    self.present(alertVC, animated: true, completion: nil)
                }else{
                   // Services
                    //API.shared.updateNickname(nickName: userInput)
                    textfield.text = userInput
                   
                }
            }
           
        })
        
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        alertVC.addAction(editAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func alertEditPassWord(title: String, message: String){
        let alertVC = UIAlertController(title: title, message: nil, preferredStyle: .alert)
       
        alertVC.addTextField(configurationHandler: { (textField) -> Void in
            self.passwordTextField = textField
            self.passwordTextField.placeholder = message
        })
        let label = UILabel(frame:CGRect(x: 0, y: 40, width: 270, height:18))
        
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { [self] (action) -> Void in
            if let userInput = self.passwordTextField.text  {

                
                label.isHidden = true
                
                label.textColor = .red
                label.font = label.font.withSize(12)
                label.textAlignment = .center
                label.text = ""
                alertVC.view.addSubview(label)
                
                if userInput == ""{
                    label.text = "비밀번호를 입력해주세요"
                    label.isHidden = false
                    self.present(alertVC, animated: true, completion: nil)

                }else if self.correctPassword(password: userInput) == false {

                    label.text = "비밀번호가 일치하지 않습니다. 다시 입력해주세요."
                    label.isHidden = false
                    self.present(alertVC, animated: true, completion: nil)
                }else if self.correctPassword(password: userInput) { // 비밀번호 변경
                    alertNewPassWord(title: "새 비밀번호 입력", message: "변경할 비밀번호를 입력해주세요")
                }
                
            }
           
        })
        
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        alertVC.addAction(OKAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    
    func alertNewPassWord(title: String, message: String){
        let alertVC = UIAlertController(title: title, message: nil, preferredStyle: .alert)
       
        alertVC.addTextField(configurationHandler: { (textField) -> Void in
            self.passwordTextField = textField
            self.passwordTextField.placeholder = message
        })
        let label = UILabel(frame:CGRect(x: 0, y: 40, width: 270, height:18))
        
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { [self] (action) -> Void in
            if let userInput = self.passwordTextField.text  {

                
                label.isHidden = true
                
                label.textColor = .red
                label.font = label.font.withSize(12)
                label.textAlignment = .center
                label.text = ""
                alertVC.view.addSubview(label)
                
                if userInput == ""{
                    label.text = "비밀번호를 입력해주세요"
                    label.isHidden = false
                    self.present(alertVC, animated: true, completion: nil)

                }else {
                    //비밀번호 반영
                    alertDone(title: "변경 완료", message: "비밀번호가 정상적으로 변경 되었습니다. ", completionHandler: { response in
                        if(response == "OK"){
                            //UserService
                            //update password with userInput
                            print("비밀번호 \(userInput)으로 수정")
                            
                        }
                    })
                }
                
            }
           
        })
        
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        alertVC.addAction(OKAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    
    
    func changID(cell: IDInputTableViewCell) {
        alertEditName(textfield: cell.textfield)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(IDInputTableViewCell.nib(), forCellReuseIdentifier: IDInputTableViewCell.identifier)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: IDInputTableViewCell.identifier) as! IDInputTableViewCell
            cell.delegate = self
            return cell
        }
        if(indexPath.row == 1){
            cell.textLabel!.textColor = #colorLiteral(red: 0.8832129836, green: 0.4130137265, blue: 0.4133844972, alpha: 1)
        }
        cell.textLabel!.text = settingArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.row == 1){ // 비밀번호 변경
            alertEditPassWord(title: "현 비밀번호 입력", message: "현재 비밀번호를 입력해주세요")
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
}

extension ProfileEditViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) { // 3
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in // 4
            DispatchQueue.main.async { self.profileImage.image = image as? UIImage // 5
            }
            }
            
        } else { // TODO: Handle empty results or item providernot being able load UIImage
            print("can't load image")
            
        }

    }
    
    
}
