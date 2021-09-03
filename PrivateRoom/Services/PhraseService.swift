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
    
    private let jwtToken: String
    private let userId: Int
    
    init(){
        userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        jwtToken = UserDefaults.standard.string(forKey: UserDefaultKey.jwtToken)!
    }
    
    func createPhrase(folderId: Int, createRequest: CreatePhraseRequest){
        let url = Config.base_url + "/users/\(userId)/folders/\(folderId)/phrases"
        
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        
        print("[PhraseService] \(folderId) 글귀 생성하기")
        
        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
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
        
        AF.request(request).validate(statusCode: 200..<300).responseString { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)") //글귀 생성 완료

                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        }
        
    }
    
    func updatePhrase(folderId: Int, phraseId: Int, text: String){
        let url = Config.base_url + "/users/\(userId)/folders/\(folderId)/phrases/\(phraseId)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PATCH"
        let parameter: Parameters = ["text" : text]
        
        print("[PhraseService] \(phraseId) 글귀 수정하기")
        
        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
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
        
        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).validate(statusCode: 200..<300).responseString { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)") //글귀 삭제 완료

                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        }
    }
    
    //글귀 북마크 수정
    func phraseBookMark(phraseId: Int){
        let url = Config.base_url + "/phrases/\(phraseId)/bookmark"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "PATCH"

        
        print("[PhraseService] \(phraseId) 글귀 북마크 수정하기")
        
        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).validate(statusCode: 200..<300).responseString { (response) in
            switch response.result {
                case .success(let obj):
                    print("success : \(obj)") //글귀 북마크 변경 완료

                    break
                case .failure(let error):
                    print("AF : \(error.localizedDescription)")
            }
        }
    }
}
