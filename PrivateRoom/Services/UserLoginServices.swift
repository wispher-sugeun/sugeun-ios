//
//  UserServices.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/03.
//

import Foundation
import Alamofire

class UserLoginServices {
    
    private let deviceToken: String
    private let userId: Int
    
    init() {
        deviceToken = UserDefaults.standard.string(forKey: UserDefaultKey.deviceToken)!
        userId = UserDefaults.standard.integer(forKey: UserDefaultKey.userID)
    }
    
    //user에 대한 데이터 받아 올 것
    static var shared = UserLoginServices()
    
    //회원 가입 0
    func signup(signUpRequest : SignUpRequest, errorHandler: @escaping (Int) -> (Void)){
        //post
        print("[API] 회원가입 하기")
        let url = Config.base_url + "/api/signup"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"

        do {
            let jsonData = try JSONEncoder().encode(signUpRequest)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            print(jsonString)
            request.httpBody = jsonData
            // and decode it back
            let decoded = try JSONDecoder().decode(SignUpRequest.self, from: jsonData)
            print(decoded)
        } catch { print(error) }

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        AF.request(request).validate(statusCode: 200..<300).responseJSON { (response) in //->  Json
            switch response.result {
                case .success(let obj):
                    print(obj)
                    print(type(of: obj))
                    let userId = obj as! Int32
                    //print("response \(userId)")
                    UserDefaults.standard.setValue(userId, forKey: UserDefaultKey.userID)
                    UserDefaults.standard.setValue(signUpRequest.phone, forKey: UserDefaultKey.phoneNumber)
                    UserDefaults.standard.setValue(signUpRequest.nickname, forKey: UserDefaultKey.userNickName)
                    
                    break
                case .failure(let error):
                    errorHandler(500)
                    print("AF : \(error.localizedDescription)")
                       
            }
        }
        
    }
    
    //아이디 중복 확인 0
    func checkIDValid(nickName: String, completion: @escaping ((Bool) -> Void) ,errorHandler: @escaping (Int) -> (Void)){
        print("[API] post \(nickName) 아이디 중복 확인")
        let url = Config.base_url + "/api/duplicate"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let parameters: Parameters = ["nickname": nickName]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        AF.request(request).validate(statusCode: 200..<300).responseJSON { (response) in
            switch response.result {
                case .success(let obj):
                    print(obj)
                    let responses = obj as! Bool
                    completion(responses) // true, false
                    break
                case .failure(let error):
                    errorHandler(500)
                    print("AF : \(error.localizedDescription)")
            }
        }
    }
    
    //휴대폰 인증 요청 0
    func sendMessage(number: String, completion: @escaping ((Int) -> Void),errorHandler: @escaping (Int) -> (Void) ){
        print(number)
        let url = Config.base_url + "/api/send-sms"
        let parameters: [String: Any] = ["toNumber": number]

        AF.request(url, method: .get, parameters: parameters).validate(statusCode: 200..<300).responseJSON { (response) in
            print(response)
            print("[API] sms send")
            switch response.result {
                case .success(let obj):
                    print(obj)
                    print(type(of: obj))
                    
                    let responses = obj as! Int
                    print(responses)
                    completion(responses)
                case .failure(let error):
                        errorHandler(500)
                        print("AF : \(error.localizedDescription)")
            }
        }
        
    }
    
    func checkID(phoneNumber: String, completion: @escaping (String) -> (Void), errorHandler: @escaping (Int) -> (Void)){
        let url = Config.base_url + "/api/find-nickname"
        
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let parameters: Parameters = ["phone": phoneNumber]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        AF.request(request).validate(statusCode: 200..<300).responseString { (response) in
            print("[UserLoginSerive] 아이디 확인하기")
            switch response.result {
                case .success(let obj):
                    print(obj)
                    print(type(of: obj))
                    completion(obj)
                    break
            case .failure(_):
                    errorHandler(500)
            }
        }
    }
    
    //비밀번호 찾기 -> 아이디 있는 사용자인지 확인
    func checkValidID(nickName: String, completion: @escaping (Int) -> (Void), errorHandler: @escaping (Int) -> (Void)){
        let url = Config.base_url + "/api/check-nickname"
        
        print("[API] post \(nickName) 유효한 아이디인지 확인")
        
        let parameters: Parameters = ["nickname": nickName]

        AF.request(url, parameters: parameters).validate(statusCode: 200..<300).responseJSON { (response) in
            switch response.result {
                case .success(let obj):
                    print(obj)
                    let responses = obj as! Int
                    completion(responses) // userID, -1
                    break
                case .failure(let error):
                    errorHandler(500)
                    print("AF : \(error.localizedDescription)")
                       
            }
        }
        
    }
    
    //비밀번호 찾기 -> phone number 검증
    func checkPhoneNumber(userId: Int, phoneNumber: String, completed: @escaping (Int) -> (Void), errorHandler: @escaping (Int) -> (Void)){
        let url = Config.base_url + "/api/verify-phone"
        var request = URLRequest(url: URL(string: url)!)
        let parameters: Parameters = [ "userId": userId, "phone" : phoneNumber]
        print(parameters)
        do {
            let jsonData = try? JSONSerialization.data(withJSONObject: parameters)

            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonData
        }
        
        AF.request(request).validate(statusCode: 200..<300).responseJSON {
            (response) in
            print("[UserLoginService] 비밀번호 찾기 -> \(phoneNumber)로 검증 ")
                switch response.result {
                    case .success(let obj):
                        print("success : \(obj)")
                        print(type(of: obj))
                        let response = obj as? Int
                        completed(response ?? 0)
                    case .failure(let error):
                        
                        errorHandler(500)
                        print("AF : \(error.localizedDescription)")
                           
                }
        
        }
    }
        
    func checkingNewPassword(userId: Int, password: String, errorHandler: @escaping (Int) -> (Void)){
        let url = Config.base_url + "/api/new-password"
        var request = URLRequest(url: URL(string: url)!)
        let parameters: Parameters = [ "userId": userId, "password" : password]
        do {
            let jsonData = try? JSONSerialization.data(withJSONObject: parameters)

            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonData
        }
        
        AF.request(request).validate(statusCode: 200..<300).responseString {
            (response) in
                switch response.result {
                    case .success(let obj):
                        print("success : \(obj)")
                       
                    case .failure(let error):
                        errorHandler(500)
                        
                        print("AF : \(error.localizedDescription)")
                           
                }
        }
    }
    
    //로그인 0
    func login(loginUserInfo : LoginRequest, errorHandler: @escaping (Int) -> (Void)){
//        completion: @escaping ((LoginResponse) -> Void)
        let url = Config.base_url + "/api/login"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        //post
        print("[API] 로그인 하기")
        
        do {
            let jsonData = try JSONEncoder().encode(loginUserInfo)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            print(jsonString)
            request.httpBody = jsonData
            // and decode it back
//            let decoded = try JSONDecoder().decode(LoginRequest.self, from: jsonData)
//            print(decoded)
        } catch { print(error) }
        
        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print("deviceToken : \(deviceToken)")

        AF.request(request).validate(statusCode: 200..<300).responseJSON { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)")
//                    let responses = obj as! LoginResponse
                    //loginResDTO
                    UserDefaults.standard.setValue("1", forKey: UserDefaultKey.isNewUser)
                    UserDefaults.standard.setValue(loginUserInfo.nickname, forKey: UserDefaultKey.userNickName)
                    UserDefaults.standard.setValue(3, forKey: UserDefaultKey.userID)
                    //completion(responses)
                    break
                case .failure(let error):
                    //let statusCode = response.response?.statusCode
                    if let httpStatusCode = response.response?.statusCode {
                          switch(httpStatusCode) {
                          case 403:
                            errorHandler(403)
                            break
                          default:
                            break
                          }
                       }
                    else {
                        errorHandler(500)
                        print("AF : \(error.localizedDescription)")
                       }
            }
        }
        
        
    }

    
    //로그 아웃 0
    func logout(){
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.phoneNumber)
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.userID)
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.userEmail)
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.userNickName)
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.isNewUser)
        //로그인 화면으로 이동
        let loginStoryBoard = UIStoryboard(name: "Login", bundle: nil)
        guard let loginVC = loginStoryBoard.instantiateViewController(withIdentifier: "Login") as? LoginViewController else {
            print("can not find loginNavC")
            return
        }

        let rootNC = UINavigationController(rootViewController: loginVC)
        UIApplication.shared.windows.first?.rootViewController = rootNC
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    func autoLogin(){
        if(UserDefaults.standard.string(forKey: UserDefaultKey.isNewUser) == "1") {
            //자동 로그인 성공 -> 메인 화면으로 이동
            guard let mainVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "VC") as? ViewController else {
                print("can not find mainVC")
                return
            }
          
            let rootNC = UINavigationController(rootViewController: mainVC)
            
            print(rootNC)
            UIApplication.shared.windows.first?.rootViewController = rootNC
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            
        }else {
            let loginStoryBoard = UIStoryboard(name: "Login", bundle: nil)
            guard let loginVC = loginStoryBoard.instantiateViewController(withIdentifier: "Login") as? LoginViewController else {
                print("can not find loginNavC")
                return
            }

            let rootNC = UINavigationController(rootViewController: loginVC)
            UIApplication.shared.windows.first?.rootViewController = rootNC
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
}


    struct JSON {
        static let encoder = JSONEncoder()
    }

    extension Encodable {
        subscript(key: String) -> Any? {
            return dictionary[key]
        }
        var dictionary: [String: Any] {
            return (try? JSONSerialization.jsonObject(with: JSON.encoder.encode(self))) as? [String: Any] ?? [:]
        }
    }
    

