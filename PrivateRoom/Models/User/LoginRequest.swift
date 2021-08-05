//
//  LoginRequest.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/06.
//

import Foundation

struct LoginRequest: Codable {
    var userId: Int
    var nickname: String
    var password: String
    var phone: String
    var alarm: Bool
    var folderPath: String
    var storeFilename: String
}
