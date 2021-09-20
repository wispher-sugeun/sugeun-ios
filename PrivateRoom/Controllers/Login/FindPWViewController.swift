//
//  FindPWViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/10.
//

import UIKit

class FindPWViewController: UIViewController {

    @IBOutlet weak var IDTextField: UITextField!
    var userID: Int = 0
    var authenCode: Int = 0
    //아이디 중복 체크
    @IBAction func IDCheckButton(_ sender: Any) {
        //DB id 있는지 체크
        if(IDTextField.text! == ""){
            self.alertViewController(title: "아이디 입력", message: "아이디를 입력해주세요", completion: { (response) in})
        }else{
            UserLoginServices.shared.checkValidID(nickName: IDTextField.text!, completion: { (response) in
                if(response != -1) {
                    self.phoneNumberTextField.becomeFirstResponder()
                    self.userID = response
                    self.inValidIDText.isHidden = true
                }else if(response == -1){
                    
                    self.alertViewController(title: "존재하지 않는 아이디", message: "존재하지 않는 아이디입니다.", completion: { (response) in})
                    self.inValidIDText.isHidden = false
                }}, errorHandler: { (error) in})
        }
       
    }

    @IBOutlet weak var inValidIDText: UILabel!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var sendTextLabel: UILabel!
    
    @IBAction func sendMessageButton(_ sender: Any) {
        if(phoneNumberTextField.text! == ""){
            alertViewController(title: "전화번호 입력", message: "전화번호를 입력해주세요", completion: {response in print(response)})
        }
        else if(phoneNumberTextField.text!.isValid()){ // 숫자인지 확인
            //send message
//            guard let number = phoneNumberTextField.text?.phoneMake() else { return }
            sendTextLabel.isHidden = false
            UserLoginServices.shared.checkPhoneNumber(userId: userID, phoneNumber: phoneNumberTextField.text!, completed: { (response) in
                if(response != 0){
                    self.authenCode = response
                    let message = LocalNotificationManager()
                    message.autheMessage(authenCode: self.authenCode)
                }
            
            }, errorHandler: { (error ) in
                self.alertViewController(title: "문자 발송 실패", message: "다시 문자 발송 해주세요", completion: { (response) in})
            })
            
        }else{
            alertViewController(title: "전화번호 입력", message: "전화번호 형식이 맞지 않습니다. 다시 입력해주세요", completion: {response in print(response)})
        }
        
    }
    
    @IBOutlet weak var authenTextField: UITextField!
    
    @IBOutlet weak var reAuthenText: UILabel!
    
    @IBOutlet weak var AuthenSuccess: UILabel!
    
    
    private var passwordTextField: UITextField = {
        var textfield = UITextField()
        return textfield
    }()
    
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
                
                if userInput == "" {
                    label.text = "비밀번호를 입력해주세요"
                    label.isHidden = false
                    self.present(alertVC, animated: true, completion: nil)

                }
                else {
                    if(validpassword(mypassword: userInput) == true) {
                        alertRePassWord(title: "새 비밀번호 입력", message: "한번 더 입력해주세요")
                    }else{
                        alertViewController(title: "비밀번호 변경 실패", message: "숫자와 문자를 포함해서 8 ~ 20글자 사이로 입력해주세요", completion: { (response) in})
                    }
                   
                }
                
            }
           
        })
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertVC.addAction(OKAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func validpassword(mypassword : String) -> Bool {//숫자+문자 포함해서 8~20글자 사이의 text 체크하는 정규표현식
        let passwordreg = ("(?=.*[A-Za-z])(?=.*[0-9]).{8,20}")
        let passwordtesting = NSPredicate(format: "SELF MATCHES %@", passwordreg)
        return passwordtesting.evaluate(with: mypassword)
        
    }
    
    func alertRePassWord(title: String, message: String){
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
                    self.alertViewController(title: "변경 완료", message: "비밀번호가 정상적으로 변경되었습니다. 로그인 화면으로 이동합니다.", completion: { (response) in
                        if(response == "OK") {
                            UserLoginServices.shared.checkingNewPassword(userId: userID, password: userInput, errorHandler: { (error ) in})
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    })
                  
                }
                
            }
           
        })
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertVC.addAction(OKAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func authenCodeButton(_ sender: Any) {
        print("authenCode \(authenCode)")
        if(String(authenCode) == authenTextField.text) {
            //인증 번호가 같다면
            AuthenSuccess.isHidden = false
            reAuthenText.isHidden = true
            alertNewPassWord(title: "새 비밀번호 입력", message: "새 비밀번호를 입력해주세요")
        }else {
            reAuthenText.isHidden = false
            AuthenSuccess.isHidden = true
            
//            self.alertViewController(title: "비밀번호", message: "spqjf12345", completion: { (response) in })
        }
        
        
    }
    
    @IBAction func goToLogin(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)



        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        UISetting()
        textfieldDelegate()
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        
        self.view.frame.origin.y = -150 // Move view 150 points upward
        }

    @objc func keyboardWillHide(_ sender: Notification) {

        self.view.frame.origin.y = 0 // Move view to original position
        }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){

         self.view.endEditing(true)

   }
    
    func UISetting(){
        inValidIDText.isHidden = true
        reAuthenText.isHidden = true
        AuthenSuccess.isHidden = true
        sendTextLabel.isHidden = true
        
    }
    
    func textfieldDelegate(){
        IDTextField.delegate = self
        phoneNumberTextField.delegate = self
        authenTextField.delegate = self
        
    }
    

}

extension FindPWViewController: UITextFieldDelegate {
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//       if(textField == phoneNumberTextField){
//            authenTextField.becomeFirstResponder()
//        }
//
//    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == phoneNumberTextField){
            authenTextField.becomeFirstResponder()
        }
        return true
    }
    
    
    //phon number valid check
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == phoneNumberTextField){
            guard let phoneNumber = phoneNumberTextField.text as String? else {
                return true
            }
            return phoneNumberTextField.updatePhoneNumber(string, phoneNumber)
        }
        return true
    }
}
