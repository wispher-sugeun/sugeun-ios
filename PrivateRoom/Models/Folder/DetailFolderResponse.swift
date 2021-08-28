//
//  DetailFolderResponse.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/13.
//

import Foundation

struct DetailFolderResponse: Codable {
    var phraseResDTOList: [PhraseResDTO]?
    
    var linkResDTOList: [LinkResDTO]?
    
    var folderResDTOList: [GetByFolderResponse]?
//    private List<PhraseResDTO> phraseResDTOList = new ArrayList<>()
//
//    private List<LinkResDTO> linkResDTOList = new ArrayList<>()
//
//    private List<FolderResDTO> folderResDTOList = new ArrayList<>()
}

struct PhraseResDTO: Codable, Equatable {
    
    var phraseId: Int

    var text: String
    
    var bookmark: Bool
    
    var textDate: String
}

struct LinkResDTO: Codable, Equatable {
    var linkId: Int

    var title: String
    
    var link: String
    
    var bookmark: Bool
}

//struct FolderResDTO: Codable {
//
//    var folderId: Int
//
//    var folderName: String
//
//    var userId: Int
//
//    var imageData: Data?
//
//}
