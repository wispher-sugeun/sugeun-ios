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
        
        //post
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
    func createFolder(){
        
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
