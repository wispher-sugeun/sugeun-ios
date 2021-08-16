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
    func getUserProfile(completion: @escaping ((GetProfileResponse?) -> Void)){
        let url = Config.base_url + "/users/\(userId)"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        

        
        AF.request(request).responseJSON { [self]
            (response) in
            print("[UserProfileService] get \(userId) 회원 프로필")
            switch response.result {
            
                case .success(let obj):
                    //print(obj)
                    let responses = obj as! NSDictionary
                    do {
                        //dictionary type to json object
                        let json = try JSONSerialization.data(withJSONObject: responses)

                        let response = try JSONDecoder().decode(GetProfileResponse?.self, from: json)
                        completion(response)  // userResDTO
                    }catch {
                        print(error)
                    }
                    
                    
                    break
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    //이미지 업데이트
    func updateProfileImage(imgeFile: Data){
        let url = Config.base_url + "/users/\(userId)"
        
        let headers: HTTPHeaders = [
            "userId" : "\(userId)",
            "Authorization" : deviceToken
        ]
        
        
        //let dataResponseSerializer = DataResponseSerializer(emptyResponseCodes: [200, 204, 205])
        // Default is [204, 205]

        AF.upload(multipartFormData: { multipartFormData in
            print("[UserProfileService] 이미지 변경하기")

            var fileName = "\(imgeFile).jpg"
            fileName = fileName.replacingOccurrences(of: " ", with: "_")
            print(fileName)
            multipartFormData.append(imgeFile, withName: "imgeFile", fileName: fileName, mimeType: "image/jpg")


        }, to: url, usingThreshold: UInt64.init(), method: .patch, headers: headers).responseString { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)")
                    print(type(of: obj))
                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        }
    }

    
    //아이디 업데이트
    func updateProfileID(nickName: String){
        let url = Config.base_url + "/users/\(userId)"
        
        let parameter: Parameters = ["updateNickname": nickName]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PATCH"

        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameter)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            print(jsonString)
            request.httpBody = jsonData
        }catch {
            print(error)
        }
        
        

        AF.request(request).responseString { (response) in
            print("[UserProfileService] 아이디 변경 하기")
            print(url)

            switch response.result {
            
                case .success(let obj):
                    //let responses = obj as! String
                   print("success \(obj)") //아이디 변경 완료
                    break
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    //기존 비밀번호 검증
    func verifyPassword(password: String, completion: @escaping (Bool) -> (Void)){
        let url = Config.base_url + "/users/\(userId)/verify"
        
        
        let parameter: Parameters = ["password": password]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"

        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameter)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            print(jsonString)
            request.httpBody = jsonData
        }catch {
            print(error)
        }

        AF.request(request).responseJSON { (response) in
            print("[UserProfileService] 비밀번호 검증 하기")

            switch response.result {
            
                case .success(let obj):
                    let responses = obj as! Bool
                   completion(responses)
                   print("success \(obj)") //true, false
                    break
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    
    //비밀번호 변경하기
    func updateProfilePassword(password: String){
        let url = Config.base_url + "/users/\(userId)"
        
        
        let parameter: Parameters = ["updatePassword": password]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PATCH"

        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameter)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            print(jsonString)
            request.httpBody = jsonData
        }catch {
            print(error)
        }
        

        AF.request(request).responseString { (response) in
            print("[UserProfileService] 비밀번호 변경 하기")

            switch response.result {
            
                case .success(let obj):
                    //let responses = obj as! String
                   print("success \(obj)") //비밀번호 변경 완료
                    break
                case .failure(let error):
                    print(error)
            }
        }
    
    }
    
    //회원 탈퇴
    func quitUser(){
        let url = Config.base_url + "/users/\(userId)"
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
        
        let url = Config.base_url + "/users/\(userId)/alarm"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PATCH"
        
        //post
        print("[UserProfileService] 알림 허용하기")

        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        

        AF.request(request).responseString { (response) in
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
        
    }
    
    //북마크 조회
    func getMyBookMark(){
        let url = Config.base_url + "/users/\(userId)/bookmark"
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

