//
//  SignUpRequest.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/06.
//
import Foundation

struct SignUpRequest: Codable {
    var nickname: String
    var password: String
    var phone: String
}
