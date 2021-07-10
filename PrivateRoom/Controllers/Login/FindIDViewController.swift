//
//  FindIDViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/10.
//

import UIKit

class FindIDViewController: UIViewController {

    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var authenCodeTextField: UITextField!
    
    @IBOutlet weak var sendMessageText: UILabel!
    
    @IBOutlet weak var AuthenSuccessText: UILabel!
    @IBOutlet weak var reAuthenText: UILabel!
    
    @IBAction func sendMessageButton(_ sender: Any) {
        
        if(phoneNumberTextField.text! == ""){
            alertViewController(title: "전화번호 입력", message: "전화번호를 입력해주세요", completion: {response in print(response)})
        }
        else if(!phoneNumberTextField.text!.isEmpty && phoneNumberTextField.text!.isNumeric() && phoneNumberTextField.text!.isValid()){ // 숫자인지 확인
            //send message
            //print(phoneNumberTextField.text?.phoneMake())
            
        }else{
            alertViewController(title: "전화번호 입력", message: "전화번호 형식이 맞지 않습니다. 다시 입력해주세요", completion: {response in print(response)})
        }
    }
    
    //인증코드 확인시
    @IBAction func checkAuthenCode(_ sender: Any) {
        //auth code == authenCodeTextField.text
        //        AuthenSuccessText.isHidden = false
        //            reAuthenText.isHidden = true
//        else {
//            reAuthenText.isHidden = false
//        AuthenSuccessText.isHidden = true
//
//        }

    }
    
    @IBAction func findPWButton(_ sender: Any) {
        performSegue(withIdentifier: "findPW", sender: nil)
    }
    
    
    @IBAction func goToLogin(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumberTextField.delegate = self
        authenCodeTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)



        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        UISetting()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){

         self.view.endEditing(true)

   }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        
        self.view.frame.origin.y = -150 // Move view 150 points upward
        }

    @objc func keyboardWillHide(_ sender: Notification) {

        self.view.frame.origin.y = 0 // Move view to original position
        }
    
    func UISetting(){
        sendMessageText.isHidden = true
        AuthenSuccessText.isHidden = true
        reAuthenText.isHidden = true
        
    }

}

extension FindIDViewController:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == phoneNumberTextField){
            guard let text = phoneNumberTextField.text else {
                return true
            }
            return phoneNumberTextField.updatePhoneNumber(string, text)
            
        }
        return true
    }
}
