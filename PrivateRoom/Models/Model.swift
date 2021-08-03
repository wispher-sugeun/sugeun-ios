//
//  Model.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/05/18.
//

import Foundation
import UIKit

struct Folder {
    var folderId: Int
    var folderName: String
    var folderImage: UIImage?
    var isLike: Bool
}

struct FolderIn {
    var FolderType: String //text. link, image
    var content: Any
}

struct Schedule {
    var scheduleId: Double
    var userId: Double
    var title: String
    var scheduleDate: String
    var selectedList: [Int] //선택된 알림 날
}

struct Phrase {
    var userId: Double
    var folderId: Double
    var phraseId: Double
    var text: String
    var bookmark: Bool
    var date: String
}

struct Link {
    var userId: Double
    var folderId: Double
    var linkId: Double
    var link: String
    var title: String
    var bookmark: Bool
    var date: String
}



//struct Timeout {
//    var userId: Double
//    var timeoutId: Double
//    var title: String
//    var timeoutImage: Data
//    var deadLine: String
//    var selectedList: [Int]
//    var isValid: Bool
//}

struct Timeout {
    var userId: Double
    var timeoutId: Double
    var title: String
    var timeoutImage: UIImage
    var deadLine: String
    var selectedList: [Int]
    var isValid: Bool
}

