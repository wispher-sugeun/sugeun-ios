//
//  BookMarkProfileResponse.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/24.
//

import Foundation

struct BookMarkProfileResponse: Codable {
    var phraseResDTOList: [PhraseResDTO]?
    
    var linkResDTOList: [LinkResDTO]?
}
