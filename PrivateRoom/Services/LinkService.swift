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
    
    func createLink(folderId: Int, linkRequest: CreateLinkRequest){
        let userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        let jwtToken = UserDefaults.standard.string(forKey: UserDefaultKey.jwtToken)!
        let url = Config.base_url + "/users/\(userId)/folders/\(folderId)/links"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        
        print("[LinkService] 링크 생성하기")
        
        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
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
        
        AF.request(request).validate(statusCode: 200..<300).responseString { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)") //링크 생성 완료

                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        }
    }
    
    //링크 수정
    func updateLink(folderId: Int, linkId: Int, link: UpdateLinkRequest){
        let userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        let jwtToken = UserDefaults.standard.string(forKey: UserDefaultKey.jwtToken)!
        let url = Config.base_url + "/users/\(userId)/folders/\(folderId)/links/\(linkId)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PUT"

        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(link)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            print(jsonString)
            request.httpBody = jsonData
            // and decode it back
            let decoded = try JSONDecoder().decode(UpdateLinkRequest.self, from: jsonData)
            print(decoded)
        } catch { print(error) }
        
        
        AF.request(request).validate(statusCode: 200..<300).responseString { (response) in
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
    
    //링크 삭제
    func deleteLink(folderId: Int, linkId: Int, completion: @escaping (Bool)->(Void)){
        let userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        let jwtToken = UserDefaults.standard.string(forKey: UserDefaultKey.jwtToken)!
        
        let url =  Config.base_url + "/users/\(userId)/folders/\(folderId)/links/\(linkId)"
        let headers: HTTPHeaders = ["Authorization" : jwtToken,
                                    "userId" : "\(userId)",
                                    "Content-Type" : "application/json" ]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "DELETE"

        AF.request(url, method: .delete, encoding: URLEncoding.httpBody, headers: headers).validate(statusCode: 200..<300).responseString { (response) in
            print("[LinkService] 링크 삭제하기")
            switch response.result {
                case .success(let obj):
                    let responses = obj 
                   print(responses) //링크 삭제 완료
                    completion(true)
                    break
                case .failure(let error):
                    print(error)
            }
        }
    
    }
    
    //링크 북마크 수정
    func linkBookMark(linkId: Int){
        let userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        let jwtToken = UserDefaults.standard.string(forKey: UserDefaultKey.jwtToken)!
        let url = Config.base_url + "/links/\(linkId)/bookmark"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PATCH"

        
        print("[LinkService] \(linkId) 링크 북마크 수정하기")
        
        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).validate(statusCode: 200..<300).responseString { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)") //링크 북마크 변경 완료

                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        }
    }
    
}
