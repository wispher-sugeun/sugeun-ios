//
//  SignInViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/10.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var IDTextField: UITextField!
    
    @IBOutlet weak var IDCheckButton: UIButton!
    
    @IBOutlet weak var authenRequestButton: UIButton!
    
    @IBOutlet weak var authenOKButton: UIButton!
    
    @IBAction func SameIDCheck(_ sender: Any) {
        //api 호출
        if(IDTextField.text! == ""){
            self.alertViewController(title: "아이디 입력", message: "아이디를 입력해주세요", completion: { (response) in })
        }
        
        UserLoginServices.shared.checkIDValid(nickName: IDTextField.text!, completion: { (response) in
            if(response) {
                self.IDSameText.isHidden = true
                self.IDValidText.isHidden = false
            }
            else {
                self.IDValidText.isHidden = true
                self.IDSameText.isHidden = false
       
            }
        }, errorHandler: { (error) in})
      
    }
    
    @IBOutlet weak var IDSameText: UILabel!
    
    @IBOutlet weak var IDValidText: UILabel!
    
    @IBOutlet weak var PasswordTextfield: UITextField!
    
    @IBOutlet weak var rePasswordTextfield: UITextField!
    
    @IBOutlet weak var passwordGuideText: UILabel!
    
    @IBOutlet weak var PasswordInValidText: UILabel!
    
    
    @IBAction func phoneNumberTextField(_ sender: Any) {
    }
    
    @IBOutlet weak var phoneNumberGuideText: UILabel!
    
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBAction func sendPhoneNumberButton(_ sender: Any) {
        //API 호출
    }
    
    @IBOutlet weak var authenTextField: UITextField!
    
    @IBOutlet weak var authenValidText: UILabel!
    
    @IBOutlet weak var authenInValidText: UILabel!

    var autheCode: Int = 0
    
    @IBAction func sendMessage(_ sender: Any) {
        if(phoneNumberTextField.text!.isValid()){
            let number = phoneNumberTextField.text?.phoneMake() // dash delete string
            UserLoginServices.shared.sendMessage(number: number!, completion: { (response) in
                self.autheCode = response
                let messageNoti = LocalNotificationManager()
                messageNoti.autheMessage(authenCode: self.autheCode)
            }, errorHandler:  { (error) in})
            let messageNoti = LocalNotificationManager()
            messageNoti.autheMessage(authenCode: 5555)
            //문자 보내기 성공시
            phoneNumberGuideText.isHidden = false
        }else {
            self.alertViewController(title: "전송 실패", message: "전화번호를 입력해주세요", completion: { (response) in })
        }
    }
    
    
    @IBAction func authenButton(_ sender: Any) {
        print(" authenTextField.text \(String(describing: authenTextField.text))")
        print("authen Code \(autheCode)")
        
        if authenTextField.text == String(autheCode) {
            print("same authen")
            authenValidText.isHidden = false
            authenInValidText.isHidden = true
        }else{
            print("diff authen")
            authenValidText.isHidden = true
            authenInValidText.isHidden = false
        }
    }
    
    
    @IBAction func signInButton(_ sender: Any) {
        
        //check
        if(signInValidCheck()){
            //post 성공시
            let signInRequest = SignUpRequest(nickname: IDTextField.text!, password: PasswordTextfield.text!, phone: phoneNumberTextField.text!)
            UserLoginServices.shared.signup(signUpRequest: signInRequest, errorHandler:  { (error) in})
                
            self.alertViewController(title: "회원가입 완료", message: "회원 가입을 완료하였습니다. 로그인으로 이동합니다", completion: { response in
                if(response == "OK"){
                    self.navigationController?.popToRootViewController(animated: true)
                }
            })
        
        }else {  //else 빈칸이 있으면 입력해주쇼
            self.alertViewController(title: "회원가입 실패", message: "빈칸을 입력해주세요", completion: { (response) in })
        }
       
    
    }
    
    func signInValidCheck() -> Bool{
        if(IDValidText.isHidden == false && PasswordInValidText.isHidden == true && validpassword(mypassword: PasswordTextfield.text!) == true ){
            //&& authenValidText.isHidden == false
            return true
        }
        return false
    }
    
   // let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textfieldDelegate()
        UISetting()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)



        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        
    

    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        
        self.view.frame.origin.y = -150 // Move view 150 points upward
        }

    @objc func keyboardWillHide(_ sender: Notification) {

        self.view.frame.origin.y = 0 // Move view to original position
        }
    
    func UISetting(){
        IDValidText.isHidden = true
        IDSameText.isHidden = true
        PasswordInValidText.isHidden = true
        phoneNumberGuideText.isHidden = true
        authenValidText.isHidden = true
        authenInValidText.isHidden = true
        
        
    }
    
    func textfieldDelegate(){
        IDTextField.delegate = self
        PasswordTextfield.delegate = self
        rePasswordTextfield.delegate = self
        phoneNumberTextField.delegate = self
        authenTextField.delegate = self
        
    }
    
    
    
    func validpassword(mypassword : String) -> Bool {//숫자+문자 포함해서 8~20글자 사이의 text 체크하는 정규표현식
        let passwordreg = ("(?=.*[A-Za-z])(?=.*[0-9]).{8,20}")
        let passwordtesting = NSPredicate(format: "SELF MATCHES %@", passwordreg)
        return passwordtesting.evaluate(with: mypassword)
        
    }
//
//    func passWordSpecial() {
//        PasswordTextfield.rx.text.throttle(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance).map { $0! }.subscribe(onNext: { text in
//            if !text.isEmpty {
//                self.passwordGuideText.textColor =
//                    #colorLiteral(red: 0.8832129836, green: 0.4130137265, blue: 0.4133844972, alpha: 1)
//            }else {
//                self.passwordGuideText.isHidden = true
//            }
//
//        }).disposed(by: disposeBag)
//    }
    
//    func passWordSpecial() -> Bool {
//        let regex:String = "^[\\w~!@#\\$%\\^&\\*]*$"
//        guard let passString = PasswordTextfield.text as String? else {
//            return false
//        }
//
//        guard let range = passString.range(of: regex, options: .regularExpression) else {
//            return false
//        }
//        print("passWordSpecial")
//        print(range)
//        print(passString[range])
//
//        if(passString[range] != ""){
//           return true
//        }
//        return false
//
//    }
    

    func passwordValidCheck() -> Bool{
        if(PasswordTextfield.text == rePasswordTextfield.text){
            return true
        }
        return false
    }
    
    

}

extension SignInViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(textField == PasswordTextfield){
            //print(validpassword(mypassword: PasswordTextfield.text!))
        }else if(textField == rePasswordTextfield){
            if(passwordValidCheck() == false) {
                PasswordInValidText.isHidden = false
            }else{
                PasswordInValidText.isHidden = true
            }
        }
        
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == IDTextField){
            PasswordTextfield.becomeFirstResponder()
        }else if(textField == PasswordTextfield){
            rePasswordTextfield.becomeFirstResponder()
        }else if(textField == rePasswordTextfield){
            phoneNumberTextField.becomeFirstResponder()
        }else if(textField == phoneNumberTextField){
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


