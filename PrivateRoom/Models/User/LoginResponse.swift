//
//  LoginResponse.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/06.
//

import ObjectMapper

//ListFolderResDTO

struct LoginResponse: Mappable {
    var folderId: Int?
    var folderName: String?
    var userId: String?
    var imageData: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        folderId <- map["folderId"]
        folderName <- map["folderName"]
        userId <- map["userId"]
        imageData <- map["imageData"]
    }
}
