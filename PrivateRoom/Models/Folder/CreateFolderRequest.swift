//
//  CreateFolderRequest.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/13.
//

import Foundation


struct CreateFolderRequest: Codable {

    var folderName: String

    var userId: Int

    var type: String

    var parentFolderId: Int

    var imageFile: Data
}

struct CreateFolderRequestNull: Codable {

    var folderName: String

    var userId: Int

    var type: String
}

struct CreateFolderRequestParameter: Codable {
    
    var parentFolderId: Int
    var folderName: String

    var userId: Int

    var type: String
}
