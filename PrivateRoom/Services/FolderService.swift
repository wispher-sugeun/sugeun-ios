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
    
    private let deviceToken: String
    private let userId: Int
    
    init(){
        userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        deviceToken = UserDefaults.standard.string(forKey: UserDefaultKey.deviceToken)!
    }
    
    
    //폴더 목록
    func getFolder(completion: @escaping ([GetFolderResponse]) -> (Void)){
        let url = Config.base_url + "/users/\(userId)/folders"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        
        print("[FolderService] 폴더 조회하기")
        
        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        

        AF.request(request).responseJSON(completionHandler: { (response) in
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
                    print("AF : \(error.localizedDescription)")
            }
        })
    }
    
    //타입 별 폴더 조회 PHRASE
    func getPhraseFolder(completion: @escaping ([GetByFolderResponse]) -> (Void) ){
        let url = Config.base_url + "/users/\(userId)/folders?type=PHRASE"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("[FolderService] PHRASE 폴더 조회하기")
        AF.request(request).responseJSON { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)")
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
                    print("AF : \(error.localizedDescription)")
            }
        }
    }
    
    //타입 별 폴더 조회 LINK
    func getLinkFolder(completion: @escaping ([GetByFolderResponse]) -> (Void)){
        let url = Config.base_url + "/users/\(userId)/folders?type=LINK"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("[FolderService] LINK 폴더 조회하기")
        AF.request(request).responseJSON { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)")
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
                    print("AF : \(error.localizedDescription)")
            }
        }
    }
    
    //폴더 생성 o
    func createFolder(folder: CreateFolderRequest){
        let url = Config.base_url + "/users/\(userId)/folders"
        
        let headers: HTTPHeaders = [
            "userId" : "\(userId)",
            "Authorization" : deviceToken
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
    
    //폴더 id로 조회 o
    func viewFolder(folderId: Int, completion: @escaping ((DetailFolderResponse) -> Void)){
        let url = Config.base_url + "/users/\(userId)/folders/\(folderId)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("[FolderService] 폴더 id \(folderId)로 조회하기")
        AF.request(request).responseJSON { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)")
                    print(type(of: obj))
                    let responses = obj as! NSDictionary
                    do {
                        //dictionary type to json object
                        print(responses)
            
                        let json = try JSONSerialization.data(withJSONObject: responses)
                        let response = try JSONDecoder().decode(DetailFolderResponse.self, from: json)
                        completion(response)  // DetailFolderResponse
                    }catch {
                        print(error)
                    }
                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        }
    }
    
    //폴더 이미지 변경
    func changeFolderImage(folderId: Int, changeImage: Data, completion: @escaping (Bool) -> (Void)){
        let url = Config.base_url + "/users/\(userId)/folders/\(folderId)"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PATCH"
        
        //post
        print("[UserProfileService] 폴더 \(folderId) 이미지 변경하기")
        
        let headers: HTTPHeaders = [
            "userId" : "\(userId)",
            "Authorization" : deviceToken,
            
        ]
        
        //let parameter: Parameters = ["imgFile" : changeImage]
        
        
        AF.upload(multipartFormData: { multipartFormData in
            print("[FolderService] 폴더 이미지 변경하기")

        
            var fileName = "\(changeImage).jpg"
            fileName = fileName.replacingOccurrences(of: " ", with: "_")
            print(fileName)
            multipartFormData.append(changeImage, withName: "imageFile", fileName: fileName, mimeType: "image/jpg")

        }, to: url, usingThreshold: UInt64.init(), method: .patch, headers: headers).validate().responseString { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)")
                    completion(true)
                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
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
    func changeFolderName(folderId: Int, changeName: String){
        let url = Config.base_url + "/users/\(userId)/folders/\(folderId)"
        
//        var request = URLRequest(url: URL(string: url)!)
//        request.httpMethod = "PATCH"
        
        let headers: HTTPHeaders = [
            "userId" : "\(userId)",
            "Authorization" : deviceToken
        ]
        
        let parameters: Parameters = ["folderName": changeName]
//        print(parameters)
//        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
//
//        request.httpBody = jsonData
//
//
//        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
//        request.addValue("\(userId)", forHTTPHeaderField: "userId")
//        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
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
        
        }, to: url, usingThreshold: UInt64.init(), method: .patch, headers: headers).validate().responseString { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)")
                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
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
    func deleteFolder(folderId: Int){
        let url = Config.base_url + "/users/\(userId)/folders/\(folderId)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "DELETE"
    

        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        

        AF.request(request).responseString { (response) in
            print("[UserProfileService] \(folderId) 폴더 삭제하기")
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)")
                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        }
    }
}
