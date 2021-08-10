//
//  getProfileResponse.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/06.
//

import Foundation

struct GetProfileResponse: Codable {
    private var userId: Int
    private var nickname: String
    private var phone: String
    private var alarm: Bool
    private var imageData: String // data
}
