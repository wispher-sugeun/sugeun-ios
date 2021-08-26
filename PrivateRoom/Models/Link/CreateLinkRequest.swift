//
//  CreateLinkRequest.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/16.
//

import Foundation

struct CreateLinkRequest: Codable {

    var userId: Int

    var folderId: Int

    var title: String

    var link: String

    var bookmark: Bool
}

struct UpdateLinkRequest: Codable {

    var userId: Int
    
    var linkId: Int

    var folderId: Int

    var title: String

    var link: String

    var bookmark: Bool
}
