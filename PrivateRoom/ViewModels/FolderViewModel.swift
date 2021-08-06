//
//  MainViewModel.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/03.
//

import Foundation
import UIKit

struct FolderViewModel {
    let id: Int
    var name: String
    var image: UIImage
    var like: Bool
    
    //dependency injection(DI)
    init(allFolder: Folder){
        // 이 안에 계산된 로직을 넣는다
        self.id = allFolder.folderId
        self.name = allFolder.folderName
        self.image = allFolder.folderImage!
        self.like = allFolder.isLike
    }
}
