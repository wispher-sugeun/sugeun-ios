//
//  SignUpResponse.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/06.
//

import ObjectMapper

class SignUpResponse: Mappable {
    var message: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        message <- map["message"] // 회원가입 완료
    }
    
    
}
