//
//  MainViewModel.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/03.
//

import Foundation
import UIKit
import SDWebImage

struct FolderViewModel {
    
    var folderId: Int

    var folderName: String

    var userId: Int

    var imageData: Data
    
    
    
    //dependency injection(DI)
    init(allFolder: GetFolderResponse){
        // 이 안에 계산된 로직을 넣는다
        self.folderId = allFolder.folderId ?? 0
        self.folderName = allFolder.folderName ?? ""
        self.userId = allFolder.userId ?? 0
        self.imageData = allFolder.imageData ?? Data()
    }
}
