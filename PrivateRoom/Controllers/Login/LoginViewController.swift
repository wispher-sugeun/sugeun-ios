//
//  LoginViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/03.
//

import UIKit
import NVActivityIndicatorView

enum LoginError: Error {
    case idTextfield
    case passwordTextfield
}

class LoginViewController: UIViewController {

    @IBOutlet weak var IDTextfield: UITextField!
    
    @IBOutlet weak var PasswordTextfield: UITextField!
    
    let indicator = NVActivityIndicatorView(frame: CGRect(x: 162, y: 100, width: 50, height: 50),
                                            type: .circleStrokeSpin,
                                            color: #colorLiteral(red: 0.5568627451, green: 0.6392156863, blue: 0.8, alpha: 1),
                                            padding: 0)
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    @IBAction func loginButton(_ sender: Any) {
        do {
            try validate()
            //로그인 성공시
            self.indicator.startAnimating()
            let loginRequest = LoginRequest(nickname: IDTextfield.text!, password: PasswordTextfield.text!)
            UserLoginServices.shared.login(loginUserInfo: loginRequest, completion: { (response) in
                if(response){
                    let mainVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "VC")
                    let rootNC = UINavigationController(rootViewController: mainVC)
                    
                    UIApplication.shared.windows.first?.rootViewController = rootNC
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                }
                self.indicator.stopAnimating()
            }, errorHandler:  { (error) in
                if(error == 401) { // 존재하지 않는 아이디
                    self.indicator.stopAnimating()
                    self.alertViewController(title: "로그인 실패", message: "존재하지 않는 사용자입니다. 다시 입력해주세요", completion: { (response) in})
                    return
                }else {
                    self.networkError()
                }
            })
        }
        catch {
            var errorMessage: String = ""
            switch error as! LoginError {
                case .idTextfield:
                    errorMessage = "아이디를 입력해주세요"
                case .passwordTextfield:
                    errorMessage = "비밀번호를 입력해주세요"
            }
            
            self.alertViewController(title: "로그인 실패", message: errorMessage, completion: { (response) in
                
            })
        }
        
    }
    
    func time() {
        let calendar = Calendar.current
        let timeDate = calendar.date(byAdding: .hour, value: 9, to: Date())
        print("time date : \(String(describing: timeDate))")
        
        print(TimeZone.current.identifier)
        let date = DateFormatter()
        date.locale = Locale(identifier: Locale.current.identifier)
        date.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        date.dateFormat = "HH:mm"
        print(date.string(from: Date()))
    }
    
    func validate() throws {
        if(IDTextfield.text == ""){
            throw LoginError.idTextfield
        }
        if(PasswordTextfield.text == ""){
            throw LoginError.passwordTextfield
        }
    }
    
    func networkError(){
        self.alertViewController(title: "네트워크 에러", message: "네트워크가 불안정합니다. 네트워크 상태를 확인해주세요", completion: { (response) in})
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
        view.addSubview(indicator)
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        indicator.frame = CGRect(x: screenWidth/2, y: screenHeight/2, width: 50, height: 50)
        indicator.center = self.view.center
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
        }
        textField.resignFirstResponder()
        return true
    }
    
}
