//
//  FolderService.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/13.
//

import Foundation
import Alamofire

class FolderService {
    static var shared = FolderService()
    
    //폴더 목록
    func getFolder(completion: @escaping ([GetFolderResponse]) -> (Void), errorHandler: @escaping (Int) -> (Void)){
        let userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        let jwtToken = UserDefaults.standard.string(forKey: UserDefaultKey.jwtToken)!
        let url = Config.base_url + "/users/\(userId)/folders"
        print(url)
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        
        print("[FolderService] 폴더 조회하기")
        
        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        

        AF.request(request).validate(statusCode: 200..<300).responseJSON(completionHandler: { (response) in
            switch response.result {
                case .success(let obj):
                    do {
                        
                        let dataJSON = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                        
                        let postData = try JSONDecoder().decode([GetFolderResponse].self, from: dataJSON)
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
                    if let httpStatusCode = response.response?.statusCode {
                        if(httpStatusCode == 403){
                            errorHandler(403)
                        }else if(httpStatusCode == 500){
                            errorHandler(500)
                        }
                        
                    }else {
                        print("AF : \(error.localizedDescription)")
                        errorHandler(500)
                       
                       }
                    
            }
        })
    }
    
    //타입 별 폴더 조회 PHRASE
    func getPhraseFolder(completion: @escaping ([GetByFolderResponse]) -> (Void),errorHandler: @escaping (Int) -> (Void) ){
        
        let userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        let jwtToken = UserDefaults.standard.string(forKey: UserDefaultKey.jwtToken)!
        let url = Config.base_url + "/users/\(userId)/folders?type=PHRASE"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("[FolderService] PHRASE 폴더 조회하기")
        AF.request(request).validate(statusCode: 200..<300).responseJSON { (response) in
            switch response.result {
                case .success(let obj):
//                    print(o)
//                    print(type(of: obj))
                    
                    let responses = obj as! [NSDictionary]
                    do {
                        //dictionary type to json object
                        let json = try JSONSerialization.data(withJSONObject: responses)

                        let response = try JSONDecoder().decode([GetByFolderResponse].self, from: json)
                        completion(response)  // GetByFolderResponse
                    }catch {
                        print(error)
                    }
                    break
                case .failure(let error):
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
    
    //타입 별 폴더 조회 LINK
    func getLinkFolder(completion: @escaping ([GetByFolderResponse]) -> (Void), errorHandler: @escaping (Int) -> (Void)) {
        let userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        let jwtToken = UserDefaults.standard.string(forKey: UserDefaultKey.jwtToken)!
        let url = Config.base_url + "/users/\(userId)/folders?type=LINK"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("[FolderService] LINK 폴더 조회하기")
        AF.request(request).validate(statusCode: 200..<300).responseJSON { (response) in
            switch response.result {
                case .success(let obj):
                    //print("success : \(obj)")
                    
                    let responses = obj as! [NSDictionary]
                    do {
                        //dictionary type to json object
                        let json = try JSONSerialization.data(withJSONObject: responses)

                        let response = try JSONDecoder().decode([GetByFolderResponse].self, from: json)
                        completion(response)  // GetByFolderResponse
                    }catch {
                        print(error)
                    }
                    break
                case .failure(let error):
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
    
    //폴더 생성 o
    func createFolder(folder: CreateFolderRequest, completion: @escaping (Bool) -> (Void), errorHandler: @escaping (Int) -> (Void)){
        let userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        let jwtToken = UserDefaults.standard.string(forKey: UserDefaultKey.jwtToken)!
        let url = Config.base_url + "/users/\(userId)/folders"
        
        let headers: HTTPHeaders = [
            "Authorization" : jwtToken
        ]
        
        let parameter: Parameters
        
        if(folder.parentFolderId == 0){
            parameter = CreateFolderRequestNull(folderName: folder.folderName, userId: folder.userId, type: folder.type).dictionary
        }else {
            parameter = CreateFolderRequestParameter(parentFolderId: folder.parentFolderId, folderName: folder.folderName, userId: folder.userId, type: folder.type).dictionary
        }
        
        print("parameter : \(parameter)")
    
        
        AF.upload(multipartFormData: { multipartFormData in
            print("[FolderService] 폴더 생성하기")

        
            var fileName = "\(folder.imageFile).jpg"
            fileName = fileName.replacingOccurrences(of: " ", with: "_")
            print(fileName)
            multipartFormData.append(folder.imageFile, withName: "imageFile", fileName: fileName, mimeType: "image/jpg")
        
            for (key, value) in parameter {
                if let temp = value as? Int {
                    multipartFormData.append("\(temp)".data(using: .utf8)!, withName: key)
                    print(temp)
                }

                if let temp = value as? String {
                    multipartFormData.append(temp.data(using: .utf8)!, withName: key)
                    print(temp)
               }

            }


        }, to: url, usingThreshold: UInt64.init(), method: .post, headers: headers).validate(statusCode: 200..<300).responseString { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)")
                    completion(true)
                    break
                case .failure(let error):
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
    
    //폴더 id로 조회 o
    func viewFolder(folderId: Int, completion: @escaping ((DetailFolderResponse) -> Void), errorHandler: @escaping (Int) -> (Void)){
        let userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        let jwtToken = UserDefaults.standard.string(forKey: UserDefaultKey.jwtToken)!
        let url = Config.base_url + "/users/\(userId)/folders/\(folderId)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("[FolderService] 폴더 id \(folderId)로 조회하기")
        AF.request(request).validate(statusCode: 200..<300).responseJSON { (response) in
            switch response.result {
                case .success(let obj):
                    //print("success : \(obj)")
                    //print(type(of: obj))
                    let responses = obj as! NSDictionary
                    do {
                        //dictionary type to json object
                        //print(responses)
            
                        let json = try JSONSerialization.data(withJSONObject: responses)
                        let response = try JSONDecoder().decode(DetailFolderResponse.self, from: json)
                        completion(response)  // DetailFolderResponse
                    }catch {
                        print(error)
                    }
                    break
                case .failure(let error):
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
    
    //폴더 이미지 변경
    func changeFolderImage(folderId: Int, changeImage: Data, completion: @escaping (Bool) -> (Void), errorHandler: @escaping (Int) -> (Void)){
        let userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        let jwtToken = UserDefaults.standard.string(forKey: UserDefaultKey.jwtToken)!
        let url = Config.base_url + "/users/\(userId)/folders/\(folderId)"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PATCH"
        
        //post
        print("[UserProfileService] 폴더 \(folderId) 이미지 변경하기")
        
        let headers: HTTPHeaders = [
            "Authorization" :jwtToken,
            
        ]
        
        
        AF.upload(multipartFormData: { multipartFormData in
            print("[FolderService] 폴더 이미지 변경하기")

        
            var fileName = "\(changeImage).jpg"
            fileName = fileName.replacingOccurrences(of: " ", with: "_")
            print(fileName)
            multipartFormData.append(changeImage, withName: "imageFile", fileName: fileName, mimeType: "image/jpg")

        }, to: url, usingThreshold: UInt64.init(), method: .patch, headers: headers).validate(statusCode: 200..<300).responseString { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)")
                    completion(true)
                    break
                case .failure(let error):
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

//        AF.request(request).responseString { (response) in
//            switch response.result {
//                case .success(let obj):
//                    print("success : \(obj)")
////                    let responses = obj as! LoginResponse
//
//                    UserDefaults.standard.setValue("1", forKey: UserDefaultKey.isNewUser)
//                    //completion(responses)
//                    break
//                case .failure(let error):
//                    print("AF : \(error.localizedDescription)")
//            }
    }
    
    //폴더 이름 변경
    func changeFolderName(folderId: Int, changeName: String, errorHandler: @escaping (Int) -> (Void)){
        let userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        let jwtToken = UserDefaults.standard.string(forKey: UserDefaultKey.jwtToken)!
        let url = Config.base_url + "/users/\(userId)/folders/\(folderId)"

        let headers: HTTPHeaders = [
            "Authorization" :jwtToken
        ]
        
        let parameters: Parameters = ["folderName": changeName]
        print(parameters)

        
        AF.upload(multipartFormData: { multipartFormData in
            print("[FolderService] 폴더 정보 변경하기")
            for (key, value) in parameters {
                if let temp = value as? Int {
                    multipartFormData.append("\(temp)".data(using: .utf8)!, withName: key)
                    print(temp)
                }

                if let temp = value as? String {
                    multipartFormData.append(temp.data(using: .utf8)!, withName: key)
                    print(temp)
               }

            }
        
        }, to: url, usingThreshold: UInt64.init(), method: .patch, headers: headers).validate(statusCode: 200..<300).responseString { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)")
                    break
                case .failure(let error):
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
        
        
//        AF.request(request).responseString { (response) in
//            print("[UserProfileService] \(folderId) 폴더 이름 변경하기")
//            switch response.result {
//                case .success(let obj):
//                    print("success : \(obj)")
//                    break
//                case .failure(let error):
//                    print("AF : \(error.localizedDescription)")
//            }
//        }
        
    }
    
    
    //폴더 삭제
    func deleteFolder(folderId: Int, errorHandler: @escaping (Int) -> (Void)){
        let userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        let jwtToken = UserDefaults.standard.string(forKey: UserDefaultKey.jwtToken)!
        let url = Config.base_url + "/users/\(userId)/folders/\(folderId)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "DELETE"
    

        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        

        AF.request(request).validate(statusCode: 200..<300).responseString { (response) in
            print("[UserProfileService] \(folderId) 폴더 삭제하기")
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)")
                    break
                case .failure(let error):
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
}
