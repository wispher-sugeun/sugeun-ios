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

struct FolderIn: Codable {
    var FolderType: String //text. link, image
    var content: String
}

struct Schedule: Codable {
    var scheduleId: Int
    var userId: Int
    var title: String
    var scheduleDate: String
    var selectedList: [Int] //선택된 알림 날
}

struct Phrase: Codable {
    var userId: Int
    var folderId: Int
    var phraseId: Int
    var text: String
    var bookmark: Bool
    var date: String
}

struct Link:Codable {
    var userId: Int
    var folderId: Int
    var linkId: Int
    var link: String
    var title: String
    var bookmark: Bool
    var date: String
}


struct Timeout {
    var userId: Int
    var timeoutId: Int
    var title: String
    var timeoutImage: UIImage
    var deadLine: String
    var selectedList: [Int]
    var isValid: Bool
}

struct User {
    var userId: Int
    var nickname: String
    var password: String
    var phone: String
    var alarm: Bool
    var folderPath: String
    var storeFilename: String
}

