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
                }})
        }
       
    }

    @IBOutlet weak var inValidIDText: UILabel!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var sendTextLabel: UILabel!
    
    @IBAction func sendMessageButton(_ sender: Any) {
        if(phoneNumberTextField.text! == ""){
            alertViewController(title: "전화번호 입력", message: "전화번호를 입력해주세요", completion: {response in print(response)})
        }
        else if(!phoneNumberTextField.text!.isEmpty && phoneNumberTextField.text!.isNumeric() && phoneNumberTextField.text!.isValid()){ // 숫자인지 확인
            //send message
            guard let number = phoneNumberTextField.text?.phoneMake() else { return }
            sendTextLabel.isHidden = false
            UserLoginServices.shared.sendMessage(number: number, completion: { (response) in
                self.authenCode = response
            })
            
        }else{
            alertViewController(title: "전화번호 입력", message: "전화번호 형식이 맞지 않습니다. 다시 입력해주세요", completion: {response in print(response)})
        }
        
    }
    
    @IBOutlet weak var authenTextField: UITextField!
    
    @IBOutlet weak var reAuthenText: UILabel!
    
    @IBOutlet weak var AuthenSuccess: UILabel!
    
    var authenCode: Int = 0
    @IBAction func authenCodeButton(_ sender: Any) {
        if(String(authenCode) == authenTextField.text) {
            AuthenSuccess.isHidden = false
            reAuthenText.isHidden = true
        }else {
            reAuthenText.isHidden = false
            AuthenSuccess.isHidden = true
            //indicator ~~
            //get by userId -> password
            self.alertViewController(title: "비밀번호", message: "spqjf12345", completion: { (response) in })
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
    

}
