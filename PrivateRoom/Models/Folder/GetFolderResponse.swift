//
//  GetFolderResponse.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/13.
//

import Foundation

struct GetFolderResponse: Codable {
    var folderId: Int?

    var folderName: String?

    var userId: Int?

    var imageData: Data?
    
    init(folderId: Int, folderName: String, userId: Int, imageData: Data){
        self.folderId = folderId
        self.folderName = folderName
        self.userId = userId
        self.imageData = imageData
    }
}
