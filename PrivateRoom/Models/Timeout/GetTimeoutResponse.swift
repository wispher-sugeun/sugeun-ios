//
//  GetTimeoutResponse.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/18.
//

import Foundation

struct GetTimeoutResponse: Codable {
    var timeoutId: Int
    
    var userId: Int
    
    var title: String
    
    var deadline: String
    
    var isValid: Bool
    
    var selected: [Int]
    
    var imageData: Data?

}
