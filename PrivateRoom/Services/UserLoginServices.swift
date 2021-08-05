//
//  UserServices.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/03.
//

import Foundation
import Alamofire

class UserServices {
    private let userEmail: String
    private let deviceToken: String
    
    init() {
        userEmail = "spqjf12345@gmail.com"
        deviceToken = UserDefaults.standard.string(forKey: UserDefaultKey.deviceToken)!
    }
    
    //user에 대한 데이터 받아 올 것
    static var shared = UserServices()
    
    //회원 가입
    func signup(){
        
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
                    let responses = obj as! Bool
                    completion(responses) // true, false
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
    func login(userDTO : User){
        let header: HTTPHeaders = [ "Authorization" : deviceToken]
        
        
    }
    
    //로그 아웃
    func logout(){
        
    }
}

struct Config {
    static var base_url = "http://192.168.35.223:9203"
    //static var base_url = "http://172.30.1.34:9203"
}
