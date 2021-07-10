//
//  FindPWViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/10.
//

import UIKit

class FindPWViewController: UIViewController {

    @IBOutlet weak var IDTextField: UITextField!
    
    @IBAction func IDCheckButton(_ sender: Any) {
        //DB id 있는지 체크
        
    }

    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var sendTextLabel: UILabel!
    @IBAction func sendMessageButton(_ sender: Any) {
    }
    
    @IBOutlet weak var authenTextField: UITextField!
    
    @IBOutlet weak var reAuthenText: UILabel!
    
    @IBOutlet weak var AuthenSuccess: UILabel!
    
    @IBAction func authenCodeButton(_ sender: Any) {
        //인증 코드 == 문자 인증 코드
//        reAuthenText.isHidden = true
//        AuthenSuccess.isHidden = false
        
//        else {
//            reAuthenText.isHidden = false
//            AuthenSuccess.isHidden = true
//
//        }
        
        
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
        reAuthenText.isHidden = true
        AuthenSuccess.isHidden = true
        sendTextLabel.isHidden = true
        
    }
    

}
