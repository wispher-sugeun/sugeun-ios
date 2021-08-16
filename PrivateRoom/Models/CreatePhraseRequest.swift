//
//  CreatePhraseRequest.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/16.
//

import Foundation

struct CreatePhraseRequest: Codable {

    var userId: Int

    var folderId: Int

    var text: String

    var bookmark: Bool

    var textDate: String
}
