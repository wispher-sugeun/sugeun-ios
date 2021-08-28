//
//  UpdateLinkRequest.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/28.
//

import Foundation

struct UpdateLinkRequest: Codable {

    var userId: Int
    
    var linkId: Int

    var folderId: Int

    var title: String

    var link: String

    var bookmark: Bool
}
