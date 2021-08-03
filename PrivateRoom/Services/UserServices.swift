//
//  UserServices.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/03.
//

import Foundation
import Alamofire

class UserServices {
    //user에 대한 데이터 받아 올 것
    static var shared = UserServices()
    
    
    func signup(){
        
    }
    
    
    func sendMessage(number: String, completion: @escaping ((Int) -> Void) ){
        print("[API] sms send")
        let url = Config.base_url + "/api/send-sms"
        let parameters: [String: Any] = ["toNumber": number]
//        var request = URLRequest(url: URL(string: url)!)
//        request.httpMethod = "GET"
//
//        let formDataString = (parameters.compactMap({(key, value) -> String in
//            return "\(key)=\(value)" }) as Array).joined(separator: "&")
//
//        let formEncodedData = formDataString.data(using: .utf8)
//
//        request.httpBody = formEncodedData
        
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
}

struct Config {
    static var base_url = "http://172.30.1.34:9203"
}
