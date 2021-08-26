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
    
    func updateLink(folderId: Int, linkId: Int, link: UpdateLinkRequest){
        let url = Config.base_url + "/users/\(userId)/folders/\(folderId)/links/\(linkId)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PUT"

        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(link)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            print(jsonString)
            request.httpBody = jsonData
            // and decode it back
            let decoded = try JSONDecoder().decode(PutScheduleRequest.self, from: jsonData)
            print(decoded)
        } catch { print(error) }
        
        
        AF.request(request).responseString { (response) in
            print("[LinkService] 링크 수정하기")
            switch response.result {
                case .success(let obj):
                    print(obj) //링크 수정 완료
                
                    break
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    func deleteLink(){
        let url =  Config.base_url + "/users/\(userId)/folders/\(folderId)"
        let headers: HTTPHeaders = ["Authorization" : deviceToken,
                                    "userId" : "\(userId)",
                                    "Content-Type" : "application/json" ]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "DELETE"

        AF.request(url, method: .delete, encoding: URLEncoding.httpBody, headers: headers).responseString { (response) in
            print("[ScheduleService] 스케줄 삭제하기")
            switch response.result {
                case .success(let obj):
                    let responses = obj as! String
                   print(responses) //링크 삭제 완료
                    break
                case .failure(let error):
                    print(error)
            }
        }
    
    }
    
}
