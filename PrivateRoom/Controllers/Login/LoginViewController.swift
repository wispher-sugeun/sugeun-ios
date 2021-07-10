//
//  LoginViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/03.
//

import UIKit
import JGProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var IDTextfield: UITextField!
    
    @IBOutlet weak var PasswordTextfield: UITextField!
    let spinner = JGProgressHUD()
    
    @IBAction func loginButton(_ sender: Any) {
        
        //로그인 성공시
        let mainVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "VC")
        UIApplication.shared.windows.first?.rootViewController = mainVC
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        
    }
    
    @IBAction func signInButton(_ sender: Any) {
        performSegue(withIdentifier: "signin", sender: nil)
    }
    
    @IBAction func findIDButton(_ sender: Any) {
        performSegue(withIdentifier: "findID", sender: nil)
    }
    
    @IBAction func findPWButton(_ sender: Any) {
        performSegue(withIdentifier: "findPW", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IDTextfield.delegate = self
        PasswordTextfield.delegate = self
     
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)



        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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



    func alertViewController(title: String, message: String){
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertVC.addAction(OKAction)
        self.present(alertVC, animated: true, completion: nil)
    }

    


}

extension LoginViewController: UISearchTextFieldDelegate {
    
    //enter button 눌렀을 때
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == IDTextfield){
            PasswordTextfield.becomeFirstResponder()
        }else if(textField == PasswordTextfield){
            //id, pw 값이 맞다면
            let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VC")
            UIApplication.shared.windows.first?.rootViewController = mainVC
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            
            // 맞지 않다면
//            alertViewController(title: "로그인 에러", message: "로그인 정보가 맞지 않습니다. 다시 입력해주세요")
        }
        return true
    }
    
}
