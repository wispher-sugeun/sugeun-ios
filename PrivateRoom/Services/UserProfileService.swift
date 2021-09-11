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
    private let jwtToken: String
    private let userId: Int
    
    init(){
        jwtToken = UserDefaults.standard.string(forKey: UserDefaultKey.jwtToken)!
        userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        
        print("[UserProfileService] jwtToken : \(jwtToken)")
        print("[UserProfileService] userId : \(userId)")
    }
    
    //get 회원 프로필
    func getUserProfile(completion: @escaping ((GetProfileResponse?) -> Void)){
        let url = Config.base_url + "/users/\(userId)"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        

        
        AF.request(request).validate(statusCode: 200..<300).responseJSON { [self]
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
                        print(response ?? "")
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
    func updateProfileImage(imgeFile: Data, completed: @escaping (Bool) -> (Void)){
        let url = Config.base_url + "/users/\(userId)"
        
        let headers: HTTPHeaders = [
            "userId" : "\(userId)",
            "Authorization" : jwtToken
        ]
        
        
        //let dataResponseSerializer = DataResponseSerializer(emptyResponseCodes: [200, 204, 205])
        // Default is [204, 205]

        AF.upload(multipartFormData: { multipartFormData in
            print("[UserProfileService] 이미지 변경하기")

            var fileName = "\(imgeFile).jpg"
            fileName = fileName.replacingOccurrences(of: " ", with: "_")
            print(fileName)
            multipartFormData.append(imgeFile, withName: "imageFile", fileName: fileName, mimeType: "image/jpg")


        }, to: url, usingThreshold: UInt64.init(), method: .patch, headers: headers).validate(statusCode: 200..<300).responseString { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)")
                    completed(true)
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

        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
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
        
        

        AF.request(request).validate(statusCode: 200..<300).responseString { (response) in
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

        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
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

        AF.request(request).validate(statusCode: 200..<300).responseJSON { (response) in
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
    func updateProfilePassword(password: String, completion: @escaping (Bool) -> (Void)){
        let url = Config.base_url + "/users/\(userId)"
        
        
        let parameter: Parameters = ["updatePassword": password]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PATCH"

        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
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
        

        AF.request(request).validate(statusCode: 200..<300).responseString { (response) in
            print("[UserProfileService] 비밀번호 변경 하기")

            switch response.result {
            
                case .success(let obj):
                    //let responses = obj as! String
                   print("success \(obj)") //비밀번호 변경 완료
                    completion(true)
                case .failure(let error):
                    print(error)
            }
        }
    
    }
    
    //회원 탈퇴
    func quit(completion: @escaping ((Bool) -> (Void))){
        let url = Config.base_url + "/users/\(userId)"
//        var request = URLRequest(url: URL(string: url)!)
//        request.httpMethod = "DELETE"
        
        //post
        print("[UserLoginServices] 회원 탈퇴 하기")
        print("jwtToken \(jwtToken)")
        let header : HTTPHeaders = ["Authorization" : jwtToken,
                                    "Content-Type" :"application/json"]

        

        AF.request(url, method: .delete, headers: header).validate(statusCode: 200..<300).responseString {
            (response) in
                switch response.result {
                    case .success(let obj):
                        print("success : \(obj)")
                        UserDefaults.standard.removeObject(forKey: UserDefaultKey.phoneNumber)
                        UserDefaults.standard.removeObject(forKey: UserDefaultKey.userID)
                        UserDefaults.standard.removeObject(forKey: UserDefaultKey.userNickName)
                        UserDefaults.standard.removeObject(forKey: UserDefaultKey.isNewUser)
                        UserDefaults.standard.removeObject(forKey: UserDefaultKey.jwtToken)
                        
                        completion(true)
                        break
                    case .failure(let error):
                        print("AF : \(error.localizedDescription)")
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

        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        

        AF.request(request).validate(statusCode: 200..<300).responseString { (response) in
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
    func getMyBookMark(completion: @escaping (BookMarkProfileResponse) -> (Void)){
        let url = Config.base_url + "/users/\(userId)/bookmark"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        //post
        print("[UserProfileService] 북마크 조회 하기")

        
        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).validate(statusCode: 200..<300).responseJSON{ (response) in
            switch response.result {
            case .success(let obj):
                print("success : \(obj)")
                print(type(of: obj))
                let responses = obj as! NSDictionary
                do {
                    let json = try JSONSerialization.data(withJSONObject: responses)
                    
                    let response = try JSONDecoder().decode(BookMarkProfileResponse.self, from: json)
                    completion(response)  // BookMarkProfileResponse
                }catch {
                    print(error)
                }
                break
                case .failure(let error):
                    print(error)
            }
        }
    }
}

