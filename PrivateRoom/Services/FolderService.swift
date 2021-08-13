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
    
    //폴더 조회
    func getFolder(){
        let url = Config.base_url + "/users/\(userId)/folders"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        
        print("[FolderService] 폴더 조회하기")
        
        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        

        AF.request(request).responseJSON { (response) in
            switch response.result {
                case .success(let obj):
                    print(obj)
                    //let responses = obj as! GetFolderResponse
                    //print(responses)
                    
                    //completion(responses)
                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        }
    }
    
    //타입 별 폴더 조회
    func tyoeFolder(){
        
    }
    
    //폴더 생성
    func createFolder(folder: CreateFolderRequest){
        let url = Config.base_url + "/users/\(userId)/folders"
        
//        var request = URLRequest(url: URL(string: url)!)
//        request.httpMethod = "POST"
//
//
//
//        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
//        request.addValue("\(userId)", forHTTPHeaderField: "userId")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
//        if(folder.parentFolderId == 0){
//
//        }else{
//
//        }
        
        let headers: HTTPHeaders = [
            //"Content-Type" : "application/json",
            "userId" : "\(userId)",
            "Authorization" : deviceToken
            //"Content-type": "multipart/form-data"
        ]
        
        let parameter: Parameters
        
        if(folder.parentFolderId == 0){
            parameter = CreateFolderRequestNull(folderName: folder.folderName, userId: folder.userId, type: folder.type).dictionary
        }else {
            parameter = CreateFolderRequestParameter(folderName: folder.folderName, userId: folder.userId, type: folder.type).dictionary
        }
    
        
        AF.upload(multipartFormData: { multipartFormData in
            print("[FolderService] 폴더 생성하기")

        
            var fileName = "\(folder.imageFile).jpg"
            fileName = fileName.replacingOccurrences(of: " ", with: "_")
            print(fileName)
            multipartFormData.append(folder.imageFile, withName: "images", fileName: fileName, mimeType: "image/jpg")
        
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
//                    let responses = obj as! LoginResponse
                
                    UserDefaults.standard.setValue("1", forKey: UserDefaultKey.isNewUser)
                    //completion(responses)
                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        }
       
        
        
    }
    
    //폴더 조회
    func viewFolder(){
        
    }
    
    //폴더 이미지 변경
    func changeFolderImage(){
        
    }
    
    //폴더 이름 변경
    func changeFolderName(){
        
    }
    
    
    //폴더 삭제
    func deleteFolder(){
        
    }
}
