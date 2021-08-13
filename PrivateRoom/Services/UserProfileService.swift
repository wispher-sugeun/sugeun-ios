//
//  UserProfileService.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/06.
//

import Foundation
import Alamofire

class UserProfileService {
    static var shared = UserProfileService()
    private let deviceToken: String
    private let userId: Int
    
    init(){
        deviceToken = UserDefaults.standard.string(forKey: UserDefaultKey.deviceToken)!
        userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        
        print("[UserProfileService] deviceToken : \(deviceToken)")
        print("[UserProfileService] userId : \(userId)")
    }
    
    //get 회원 프로필
    func getUserProfile(completion: @escaping ((GetProfileResponse) -> Void)){
        let headers: HTTPHeaders = ["Authorization" : deviceToken]
        let url = Config.base_url + "/user/\(userId)"
        AF.request(url, method: .get, headers: headers).validate(statusCode: 200...500).responseJSON {
            (response) in
            switch response.result {
                case .success(let obj):
                    let responses = obj as! GetProfileResponse
                    completion(responses)  // userResDTO
                    break
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    //이미지 업데이트
    func updateProfileImage(){
        let url = Config.base_url + "/user/\(userId)"
        let headers: HTTPHeaders = ["Authorization" : deviceToken]
        
    }
    
    //아이디 업데이트
    func updateProfileID(nickName: String){
        let url = Config.base_url + "/user/\(userId)"
        let headers: HTTPHeaders = ["Authorization" : deviceToken]
        let parameter: Parameters = ["updateNickName": nickName]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PATCH"
        let formDataString = (parameter.compactMap({(key, value) -> String in
            return "\(key)=\(value)" }) as Array).joined(separator: "&")
        let formEncodedData = formDataString.data(using: .utf8)
        
        
        request.httpBody = formEncodedData
        AF.request(url, method: .patch, parameters: parameter, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response) in
            switch response.result {
                case .success(let obj):
                    let responses = obj as! String
                   print(responses) //아이디 변경 완료
                    break
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    func updateProfilePassword(password: String){
        let url = Config.base_url + "/user/\(userId)"
        let headers: HTTPHeaders = ["Authorization" : deviceToken]
        
        
        let parameter: Parameters = ["updatePassword": password]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PATCH"
        let formDataString = (parameter.compactMap({(key, value) -> String in
            return "\(key)=\(value)" }) as Array).joined(separator: "&")
        let formEncodedData = formDataString.data(using: .utf8)
        
        
        request.httpBody = formEncodedData
        AF.request(url, method: .patch, parameters: parameter, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response) in
            switch response.result {
                case .success(let obj):
                    let responses = obj as! String
                   print(responses) //비밀번호 변경 완료
                    break
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    //회원 탈퇴
    func quitUser(){
        let url = Config.base_url + "/user/\(userId)"
        let headers: HTTPHeaders = ["Authorization" : deviceToken]
        AF.request(url, method: .delete, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response) in
            switch response.result {
                case .success(let obj):
                    let responses = obj as! String
                   print(responses) //회원 탈퇴 완료
                    break
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    //알림 허용
    func updateAlarmValue(){
        
        let url = Config.base_url + "/api/login"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PATCH"
        
        //post
        print("[UserProfileService] 알림 허용하기")

        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        

        AF.request(request).responseJSON { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)")
//                    let responses = obj as! LoginResponse
                
                    UserDefaults.standard.setValue("1", forKey: UserDefaultKey.isNewUser)
                    //completion(responses)
                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        }
        
        

//        let headers: HTTPHeaders = ["Authorization" : deviceToken]
//        AF.request(url, method: .patch, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response) in
//            switch response.result {
//                case .success(let obj):
//                    let responses = obj as! String
//                   print(responses) //알림허용 변경 완료
//                    break
//                case .failure(let error):
//                    print(error)
//            }
//        }
        
        
    }
    
    //북마크 조회
    func getMyBookMark(){
        let url = Config.base_url + "/user/\(userId)/bookmark"
        let headers: HTTPHeaders = ["Authorization" : deviceToken]
        AF.request(url, method: .get, headers: headers).responseJSON{ (response) in
            switch response.result {
                case .success(let obj):
                    let responses = obj as! String
                   print(responses) //북마크 조회 ~~ ing
                    break
                case .failure(let error):
                    print(error)
            }
        }
    }
}
