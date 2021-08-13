//
//  CreateFolderRequest.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/13.
//

import Foundation


struct CreateFolderRequest {
    var folderId: Int

    var folderName: String

    var userId: Int

    var type: String

    var parentFolderId: Int

    var imageFile: Data
}
