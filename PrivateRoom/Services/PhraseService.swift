//
//  PhraseService.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/16.
//

import Foundation

class PhraseService {
    static var shared = PhraseService()
    
    private let deviceToken: String
    private let userId: Int
    
    init(){
        userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
        deviceToken = UserDefaults.standard.string(forKey: UserDefaultKey.deviceToken)!
    }
    
    func createPhrase(folderId: Int, createRequest: CreatePhraseRequest){
        let url = Config.base_url + "users/\(userId)/folders/\(folderId)/phrases"
        
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        
        print("[PhraseService] 글귀 생성하기")
        
        request.addValue(deviceToken, forHTTPHeaderField: "Authorization")
        request.addValue("\(userId)", forHTTPHeaderField: "userId")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
    }
}
