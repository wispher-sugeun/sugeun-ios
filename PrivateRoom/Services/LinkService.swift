//
//  LinkService.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/16.
//

import Foundation
import Alamofire

class LinkService {
    
    static var shared = LinkService()
    
    private let deviceToken: String
    private let userId: Int
    
    init(){
        userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        deviceToken = UserDefaults.standard.string(forKey: UserDefaultKey.deviceToken)!
    }
    
    func createLink(folderId: Int, linkRequest: CreateLinkRequest){
        let url = Config.base_url + "/users/\(userId)/folders/\(folderId)/links"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        
        print("[LinkService] 링크 생성하기")
        
        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(linkRequest)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            print(jsonString)
            request.httpBody = jsonData
            // and decode it back
            let decoded = try JSONDecoder().decode(CreateLinkRequest.self, from: jsonData)
            print(decoded)
        } catch { print(error) }
        
        AF.request(request).responseString { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)") //링크 생성 완료

                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        }
    }
    
}
