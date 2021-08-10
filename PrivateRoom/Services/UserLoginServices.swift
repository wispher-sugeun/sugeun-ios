//
//  UserServices.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/03.
//

import Foundation
import Alamofire

class UserLoginServices {
    private let userEmail: String
    private let deviceToken: String
    
    init() {
        userEmail = "spqjf12345@gmail.com"
        deviceToken = UserDefaults.standard.string(forKey: UserDefaultKey.deviceToken)!
    }
    
    //user에 대한 데이터 받아 올 것
    static var shared = UserLoginServices()
    
    //회원 가입
    func signup(signUpRequest : SignUpRequest, completion: @escaping ((String) -> Void)){
        //post
        let url = Config.base_url + "/api/signup"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        let formDataString = (signUpRequest.dictionary.compactMap({(key, value) -> String in
            return "\(key)=\(value)" }) as Array).joined(separator: "&")
        let formEncodedData = formDataString.data(using: .utf8)

        request.httpBody = formEncodedData
        AF.request(url, method: .post, encoding: URLEncoding.httpBody).responseJSON { (response) in
            switch response.result {
                case .success(let obj):
                    let responses = obj as! String
                    completion(responses) // 회원가입 완료
                    break
                case .failure(let error):
                    print(error)
            }
        }
        
    }
    
    //아이디 중복 확인
    func checkIDValid(nickName: String, completion: @escaping ((Bool) -> Void) ){
        let url = Config.base_url + "/api/duplicate"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let parameters: [String: Any] = ["nickname": nickName]
        let formDataString = (parameters.compactMap({(key, value) -> String in
            return "\(key)=\(value)" }) as Array).joined(separator: "&")

        let formEncodedData = formDataString.data(using: .utf8)

        request.httpBody = formEncodedData
        AF.request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody).responseJSON { (response) in
            switch response.result {
                case .success(let obj):
                    print(obj)
                    //let responses = obj as! NSDictionary
                    //completion(responses) // true, false
                    break
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    //휴대폰 인증 요청
    func sendMessage(number: String, completion: @escaping ((Int) -> Void) ){
        print("[API] sms send")
        let url = Config.base_url + "/api/send-sms"
        let parameters: [String: Any] = ["toNumber": number]

        AF.request(url,method: .get, parameters: parameters).validate().responseJSON { (response) in
            print(response)
            print("[API] sms send")
            switch response.result {
            case .success(let obj):
                print(obj)
                print(type(of: obj))
                
                let responses = obj as! Int
                completion(responses)
                
            case .failure(let e):
                print(e.localizedDescription)
            }
        }
        
    }
    
    //로그인
    func login(loginUserInfo : LoginRequest, completion: @escaping ((LoginResponse) -> Void) ){
        let header: HTTPHeaders = [ "Authorization" : deviceToken]
        let url = Config.base_url + "/api/login"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        let formDataString = (loginUserInfo.dictionary.compactMap({(key, value) -> String in
            return "\(key)=\(value)" }) as Array).joined(separator: "&")
        let formEncodedData = formDataString.data(using: .utf8)

        request.httpBody = formEncodedData
        AF.request(url, method: .post, encoding: URLEncoding.httpBody, headers: header).responseJSON { (response) in
            switch response.result {
                case .success(let obj):
                    let responses = obj as! LoginResponse
                    UserDefaults.standard.setValue(loginUserInfo.userId, forKey: UserDefaultKey.userID)
                    UserDefaults.standard.setValue("1", forKey: UserDefaultKey.isNewUser)
                    UserDefaults.standard.setValue(loginUserInfo.phone, forKey: UserDefaultKey.phoneNumber)
                    UserDefaults.standard.setValue(loginUserInfo.nickname, forKey: UserDefaultKey.userNickName)
                    completion(responses)
                    break
                case .failure(let error):
                    print(error)
            }
        }
        
        
    }
    
    //로그 아웃
    func logout(){
        
    }
    
    func autoLogin(){
        if(UserDefaults.standard.string(forKey: UserDefaultKey.isNewUser) == "1") {
            //자동 로그인 성공 -> 화면으로 이동
            let mainVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "VC")
            let rootNC = UINavigationController(rootViewController: mainVC)
            
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

struct Config {
    static var base_url = "http://192.168.35.223:9203"
    //static var base_url = "http://172.30.1.34:9203"
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
