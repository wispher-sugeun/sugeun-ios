//
//  getProfileResponse.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/06.
//

import Foundation

struct GetProfileResponse: Codable {
    var userId: Int
    var nickname: String
    var phone: String
    var alarm: Bool
    var imageData: Data // data
}
