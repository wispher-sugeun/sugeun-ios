//
//  LoginResponse.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/06.
//

import ObjectMapper


struct LoginResponse: Codable {
    var userId: Int
    var jwtToken: String
}
