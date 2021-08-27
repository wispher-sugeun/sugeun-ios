//
//  GetFolderResponse.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/13.
//

import Foundation

struct GetFolderResponse: Codable {
    var folderId: Int

    var folderName: String?

    var userId: Int?

    var imageData: Data?
    
    var type: String?
    
    init(folderId: Int, folderName: String, userId: Int, imageData: Data, type: String){
        self.folderId = folderId
        self.folderName = folderName
        self.userId = userId
        self.imageData = imageData ?? Data()
        self.type = type
    }
}
