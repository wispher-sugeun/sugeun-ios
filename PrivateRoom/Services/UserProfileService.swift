//
//  UserProfileService.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/06.
//

import Foundation
import Alamofire

class UserProfileService {
    static var shared = UserProfileService()
    private let deviceToken: String
    private let userId: Int
    
    init(){
        deviceToken = UserDefaults.standard.string(forKey: UserDefaultKey.deviceToken)!
        userId = UserDefaults.standard.integer(forKey:  UserDefaultKey.userID)
    }
    
    //get 회원 프로필
    func getUserProfile(completion: @escaping ((GetProgileResponse) -> Void)){
        let headers: HTTPHeaders = ["Authorization" : deviceToken]
        let url = Config.base_url + "/user/\(userId)"
        AF.request(url, method: .get, headers: headers).validate(statusCode: 200...500).responseJSON {
            (response) in
            switch response.result {
                case .success(let obj):
                    let responses = obj as! GetProgileResponse
                    completion(responses)  // userResDTO
                    break
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    //이미지 업데이트
    func updateProfileImage(){
        let url = Config.base_url + "/user/\(userId)"
        let headers: HTTPHeaders = ["Authorization" : deviceToken]
        //imageFile data 자체를 ?
    }
    
    //아이디 업데이트
    func updateProfileID(){
        let url = Config.base_url + "/user/\(userId)"
        let headers: HTTPHeaders = ["Authorization" : deviceToken]
    }
    
    func updateProfilePassword(){
        let url = Config.base_url + "/user/\(userId)"
        let headers: HTTPHeaders = ["Authorization" : deviceToken]
    }
    
    //회원 탈퇴
    func quitUser(){
        let url = Config.base_url + "/user/\(userId)"
        let headers: HTTPHeaders = ["Authorization" : deviceToken]
    }
    
    //알림 허용
    func updateAlarmValue(){
        let url = Config.base_url + "/user/\(userId)"
        let headers: HTTPHeaders = ["Authorization" : deviceToken]
    }
    
    //북마크 조회
    func getMyBookMark(){
        let url = Config.base_url + "/user/\(userId)"
        let headers: HTTPHeaders = ["Authorization" : deviceToken]
        AF.request(url, method: .get, headers: headers).responseJSON{ (response) in }
    }
}
