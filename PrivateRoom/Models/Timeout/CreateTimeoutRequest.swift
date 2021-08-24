//
//  CreateTimeoutRequest.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/18.
//

import Foundation


struct CreateTimeoutRequest: Codable {
    
    var userId: Int
    
    var title: String
    
    var deadline: String
    
    var isValid: Bool
    
    var selected: [Int]
    
    var imageFile: Data
}

struct UpdateTimeoutRequest: Codable {
    var timeoutId: Int
    
    var userId: Int
    
    var title: String
    
    var deadline: String
    
    var isValid: Bool
    
    var selected: [Int]

}
