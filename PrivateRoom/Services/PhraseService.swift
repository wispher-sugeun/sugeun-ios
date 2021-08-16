//
//  PhraseService.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/16.
//

import Foundation
import Alamofire

class PhraseService {
    static var shared = PhraseService()
    
    private let deviceToken: String
    private let userId: Int
    
    init(){
        userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        deviceToken = UserDefaults.standard.string(forKey: UserDefaultKey.deviceToken)!
    }
    
    func createPhrase(folderId: Int, createRequest: CreatePhraseRequest){
        let url = Config.base_url + "/users/\(userId)/folders/\(folderId)/phrases"
        
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        
        print("[PhraseService] 글귀 생성하기")
        
        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(createRequest)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            print(jsonString)
            request.httpBody = jsonData
            // and decode it back
            let decoded = try JSONDecoder().decode(CreatePhraseRequest.self, from: jsonData)
            print(decoded)
        } catch { print(error) }
        
        AF.request(request).responseString { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)") //글귀 생성 완료

                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        }
        
    }
    
    //테스트 x
    func updatePhrase(folderId: Int, phraseId: Int, text: String){
        let url = Config.base_url + "/users/\(userId)/folders/\(folderId)/phrases/\(phraseId)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PATCH"
        let parameter: Parameters = ["text" : text]
        
        print("[PhraseService] 글귀 수정하기")
        
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
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)") //글귀 TEXT 변경 완료

                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        }
    }
    
    func deletePhrase(folderId: Int, phraseId: Int){
        
        let url = Config.base_url + "/users/\(userId)/folders/\(folderId)/phrases/\(phraseId)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "DELETE"
        
        print("[PhraseService] \(phraseId) 글귀 삭제하기")
        
        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).responseString { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)") //글귀 삭제 완료

                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        }
    }
}
