//
//  GetByFolderResponse.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/13.
//

import Foundation

struct GetByFolderResponse: Codable {
    var folderId: Int

    var folderName: String

    var userId: Int

    var imageData: Data
}
