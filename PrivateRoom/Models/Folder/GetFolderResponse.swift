//
//  GetFolderResponse.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/13.
//

import Foundation

struct GetFolderResponse:Codable {
    private var folderId: Int

    private var folderName: String

    private var userId: Int

    private var imageData: Data
}
