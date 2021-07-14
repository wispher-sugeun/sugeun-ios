//
//  Model.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/05/18.
//

import Foundation
import UIKit

struct Folder {
    var folderName: String
    var folderImage: UIImage?
    var isLike: Bool
    var Content: [FolderIn]
}

struct FolderIn {
    var FolderType: String //text. link, image
    var content: Any
}
