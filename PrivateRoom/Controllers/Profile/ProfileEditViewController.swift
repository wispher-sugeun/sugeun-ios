//
//  ProfileEditViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/04.
//

import UIKit
import PhotosUI
import NVActivityIndicatorView

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
    
    let indicator = NVActivityIndicatorView(frame: CGRect(x: 162, y: 100, width: 50, height: 50),
                                            type: .circleStrokeSpin,
                                            color: #colorLiteral(red: 0.5568627451, green: 0.6392156863, blue: 0.8, alpha: 1),
                                            padding: 0)
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UserProfileService.shared.getUserProfile(completion:  { [self] response in
            if(response?.imageData != nil){
    
                profileImage.image = UIImage(data: (response?.imageData)!)
            }
        })
    }
    
    @IBAction func quitApp(_ sender: Any) {
        //UserService
        alertDoneCancel(title: "회원 탈퇴", message: "회원 탈퇴하시겠습니까?", completionHandler: { action in
            if(action == "OK"){
                //userService 회원 탈퇴
                UserProfileService.shared.quit(completion: { (response) in
                    if(response == true){
                        self.alertDone(title: "회원 탈퇴 완료", message: "그동안 저의 앱을 이용해주셔서 감사합니다.", completionHandler: {action in print(action)
                            exit(0)
                            
                        })
                    }else {
                        self.alertDone(title: "회원 탈퇴 실패", message: "회원 탈퇴가 이루어지지 않았습니다. 다시 시도해주세요.", completionHandler: { (response) in})
                    }
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
        UISetting()
    
        indicator.center = self.view.center
        view.addSubview(indicator)
        
        configuration.filter = .any(of: [.images])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.tableFooterView = UIView(frame: .zero)
 
    }
    
    func UISetting(){
        profileImage.circle()
        profileImage.contentMode = .scaleToFill
        editButton.circle()
    }
    
    func alertDone(title: String, message: String, completionHandler: @escaping ((String) -> Void)) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "확인", style: .default, handler: { action in  completionHandler("OK")})
        alertVC.addAction(OKAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func alertDoneCancel(title: String, message: String, completionHandler: @escaping ((String) -> Void)) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { action in  completionHandler("OK")})
        let CANCELAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertVC.addAction(OKAction)
        alertVC.addAction(CANCELAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    

}

extension ProfileEditViewController: UITableViewDelegate, UITableViewDataSource, IDInputTableViewCellDelegate {
    
    
//    func correctPassword(password: String) -> Bool {
//        UserProfileService.shared.verifyPassword(password: password, completion: {(response) in
//
//        }
//
//        if(password == "1234"){
//            return true
//        }
//        return false
//    }
    
    //alertVC with textfield
    func alertEditName(textfield: UITextField){
        let alertVC = UIAlertController(title:"아이디 수정", message: nil, preferredStyle: .alert)
       
        alertVC.addTextField(configurationHandler: { (textField) -> Void in
            self.nameTextField = textField
            self.nameTextField.placeholder = "새로 수정할 아이디를 입력해주세요"
        })
        let label = UILabel(frame:CGRect(x: 0, y: 40, width: 270, height:18))
        let editAction = UIAlertAction(title: "수정", style: .default, handler: { [self] (action) -> Void in
            if let userInput = self.nameTextField.text  {
               
                label.isHidden = true
                label.textColor = .red
                label.font = label.font.withSize(12)
                label.textAlignment = .center
                label.text = ""
                alertVC.view.addSubview(label)
                
                if userInput == "" {
                    label.text = "이름을 입력해주세요"
                    label.isHidden = false
                    self.present(alertVC, animated: true, completion: nil)

                }else {
                    UserLoginServices.shared.checkIDValid(nickName: userInput, completion: { (response) in
                        if(response == true){ // 사용 가능
                            // Services
                            UserProfileService.shared.updateProfileID(nickName: userInput, completion: { (response) in
                                if(response == true){
                                    textfield.text = userInput
                                   UserDefaults.standard.setValue(userInput, forKey: UserDefaultKey.userNickName)
                                    self.alertViewController(title: "변경 완료", message: "아이디가 변경되었습니다.", completion: { (response) in})
                                }
                            }, errorHandler: {(response) in } )
                             
                        }else{
                            label.text = "이미 같은 이름을 가진 사용자가 있습니다"
                            label.isHidden = false
                            self.present(alertVC, animated: true, completion: nil)
                        }
                    }, errorHandler:  { (error) in} )
                }
            }
           
        })
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
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
        
        let OKAction = UIAlertAction(title: "확인", style: .default, handler: { [self] (action) -> Void in
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
                    UserProfileService.shared.verifyPassword(password: userInput, completion: {(response) in
                        if(response){
                            alertNewPassWord(title: "새 비밀번호 입력", message: "변경할 비밀번호를 입력해주세요")
                        }else{
                            label.text = "비밀번호가 일치하지 않습니다. 다시 입력해주세요."
                            label.isHidden = false
                            self.present(alertVC, animated: true, completion: nil)
                        }
                    })
                }
//                    if self.correctPassword(password: userInput) == false {
//
//                    label.text = "비밀번호가 일치하지 않습니다. 다시 입력해주세요."
//                    label.isHidden = false
//                    self.present(alertVC, animated: true, completion: nil)
//                }else if self.correctPassword(password: userInput) { // 비밀번호 변경
//                    alertNewPassWord(title: "새 비밀번호 입력", message: "변경할 비밀번호를 입력해주세요")
//                }
                
            }
           
        })
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
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
        
        let OKAction = UIAlertAction(title: "확인", style: .default, handler: { [self] (action) -> Void in
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
                    UserProfileService.shared.updateProfilePassword(password: userInput, completion: { (response) in
                        if(response) {
                            print("비밀번호 \(userInput)으로 수정")
                            alertDone(title: "변경 완료", message: "비밀번호가 정상적으로 변경 되었습니다. ", completionHandler: { response in
                                }
                            )}
                    
                    }, errorHandler: { (response) in })
                  
                }
                
            }
           
        })
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
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
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                DispatchQueue.main.async {
                    let uploadImage = image as? UIImage
                    self.indicator.startAnimating()
                    UserProfileService.shared.updateProfileImage(imgeFile: (uploadImage?.jpeg(.lowest))!, completed: { (response) in
                        if(response == true){
                            self.profileImage.image = uploadImage
                            self.alertViewController(title: "변경 완료", message: "프로필 이미지가 변경 되었습니다.", completion: { (response) in})
                            self.indicator.stopAnimating()
                        }
                    })
                    
                }
            }
            
        } else { // TODO: Handle empty results or item providernot being able load UIImage
            print("can't load image")
            
        }

    }
    
    
}
