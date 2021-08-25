//
//  TimoutService.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/18.
//

import Foundation
import Alamofire

class TimeoutService {
    static var shared = TimeoutService()
    
    private let deviceToken: String
    private let userId: Int
    
    init(){
        userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        deviceToken = UserDefaults.standard.string(forKey: UserDefaultKey.deviceToken)!
    }
    
    
    //타임 아웃 생성
    func createTimeout(createTimoutRequest: CreateTimeoutRequest){
        let url =  Config.base_url + "/users/\(userId)/timeouts"
        
    
        let headers: HTTPHeaders = [
            "userId" : "\(userId)",
            "Authorization" : deviceToken
        ]
        
        let parameter: Parameters = [ "userId" : createTimoutRequest.userId,
                                        "title" : createTimoutRequest.title,
                                        "deadline" : createTimoutRequest.deadline,
                                        "isValid" : createTimoutRequest.isValid,
                                        "selected" : createTimoutRequest.selected ]

        
        print("parameter : \(parameter)")
    
        
        AF.upload(multipartFormData: { multipartFormData in
            print("[TimeoutService] 타임아웃 생성하기")

        
            var fileName = "\(createTimoutRequest.imageFile).jpg"
            fileName = fileName.replacingOccurrences(of: " ", with: "_")
            print(fileName)
            multipartFormData.append(createTimoutRequest.imageFile, withName: "imageFile", fileName: fileName, mimeType: "image/jpg")

        
            for (key, value) in parameter {
                if let temp = value as? Int {
                    multipartFormData.append("\(temp)".data(using: .utf8)!, withName: key)
                    print(temp)
                }

                if let temp = value as? String {
                    multipartFormData.append(temp.data(using: .utf8)!, withName: key)
                    print(temp)
               }
                
                if let temp = value as? Bool {
                    multipartFormData.append(Bool(temp).description.data(using: .utf8)!, withName: key)
                    print(temp)
               }

                if let temp = value as? NSArray { // Int array
                    temp.forEach({ element in
                        let keyObj = key + "[]"
                        if let string = element as? String {
                            multipartFormData.append(string.data(using: .utf8)!, withName: keyObj)
                        } else
                            if let num = element as? Int {
                                let value = "\(num)"
                                multipartFormData.append(value.data(using: .utf8)!, withName: keyObj)
                        }
                    })
                    print(temp)
                }

            }


        }, to: url, usingThreshold: UInt64.init(), method: .post, headers: headers).validate().responseString { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)")
                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        }
       

    }
    
    //타임아웃 조화
    func getTimeout(completion: @escaping (([GetTimeoutResponse?]) -> (Void))) {
        let url = Config.base_url + "/users/\(userId)/timeouts"
        
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        
        print("[TimeoutService] 타임아웃 조회하기")
        
        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        

        AF.request(request).responseJSON(completionHandler: { (response) in
            switch response.result {
                case .success(let obj):
                    do {
                        print(obj)
                        let dataJSON = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                        
                        let postData = try JSONDecoder().decode([GetTimeoutResponse?].self, from: dataJSON)
                        print(postData)
                        
                        completion(postData)
                    }catch let DecodingError.dataCorrupted(context) {
                        print(context)
                    } catch let DecodingError.keyNotFound(key, context) {
                        print("Key '\(key)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch let DecodingError.valueNotFound(value, context) {
                        print("Value '\(value)' not found:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch let DecodingError.typeMismatch(type, context)  {
                        print("Type '\(type)' mismatch:", context.debugDescription)
                        print("codingPath:", context.codingPath)
                    } catch {
                        print("error: ", error)
                    }
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        })
    }
    
    //타임아웃 사용
    func useTiemout(timeoutId: Int){
        let url = Config.base_url + "/timeouts/\(timeoutId)/valid"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PATCH"
        
        print("[TimeoutService] \(timeoutId) 타임아웃 사용시키기")
        
        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).responseString { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)") //타임아웃 사용 완료

                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        }
    }
    
    //타임 아웃 이미지 변경
    func updateTimeoutImage(timeoutId: Int, imageFile: Data){
        let url = Config.base_url + "/users/\(userId)/timeouts/\(timeoutId)"
        
        let headers: HTTPHeaders = [
            "userId" : "\(userId)",
            "Authorization" : deviceToken
        ]

        AF.upload(multipartFormData: { multipartFormData in
            print("[TimeoutService] 타임아웃 이미지 변경하기")

            var fileName = "\(imageFile).jpg"
            fileName = fileName.replacingOccurrences(of: " ", with: "_")
            print(fileName)
            multipartFormData.append(imageFile, withName: "imageFile", fileName: fileName, mimeType: "image/jpg")


        }, to: url, usingThreshold: UInt64.init(), method: .patch, headers: headers).responseString { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)")
                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        }
    }
    
    //타임아웃 정보 업데이트
    func updateTimeoutInfo(timeoutId: Int, timeoutRequest: UpdateTimeoutRequest){
        let url = Config.base_url + "/users/\(userId)/timeouts/\(timeoutId)"

        let headers: HTTPHeaders = [
            "userId" : "\(userId)",
            "Authorization" : deviceToken
        ]
        let parameter: Parameters = timeoutRequest.dictionary
//
//        do {
//            let jsonData = try JSONEncoder().encode(timeoutRequest)
//            let jsonString = String(data: jsonData, encoding: .utf8)!
//            print(jsonString)
//            request.httpBody = jsonData
//            // and decode it back
//            let decoded = try JSONDecoder().decode(UpdateTimeoutRequest.self, from: jsonData)
//            print(decoded)
//        } catch { print(error) }
        
        AF.upload(multipartFormData: { multipartFormData in
            print("[TimeoutService] 타임아웃 정보 변경하기")
            
            for (key, value) in parameter {
                if let temp = value as? Int {
                    multipartFormData.append("\(temp)".data(using: .utf8)!, withName: key)
                    print(temp)
                }

                if let temp = value as? String {
                    multipartFormData.append(temp.data(using: .utf8)!, withName: key)
                    print(temp)
               }
                
                if let temp = value as? Bool {
                    multipartFormData.append(Bool(temp).description.data(using: .utf8)!, withName: key)
                    print(temp)
               }

                if let temp = value as? NSArray { // Int array
                    temp.forEach({ element in
                        let keyObj = key + "[]"
                        if let string = element as? String {
                            multipartFormData.append(string.data(using: .utf8)!, withName: keyObj)
                        } else
                            if let num = element as? Int {
                                let value = "\(num)"
                                multipartFormData.append(value.data(using: .utf8)!, withName: keyObj)
                        }
                    })
                    print(temp)
                }

            }


        }, to: url, usingThreshold: UInt64.init(), method: .post, headers: headers).validate().responseString { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)")
                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        }
        
        
    }
    
    //타임아웃 삭제
    func deleteTimeout(timeoutId: Int){
        let url = Config.base_url + "/users/\(userId)/timeouts/\(timeoutId)"
        
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "DELETE"
        
        print("[PhraseService] \(timeoutId) 타임아웃 삭제하기")
        
        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).responseString { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)") //타임아웃 삭제 완료

                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        }
    }
    
    
    
    
    
}
