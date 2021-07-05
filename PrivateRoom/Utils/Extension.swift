//
//  Extension.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/04.
//

import Foundation
import UIKit

extension UIImageView {
    func circle(){
        self.layer.cornerRadius = self.frame.height/2
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.clear.cgColor
                    // 뷰의 경계에 맞춰준다
        self.clipsToBounds = true
    }
}

extension UIButton {
    func circle(){
        self.layer.cornerRadius = 0.5
         * self.bounds.size.width
        self.clipsToBounds = true
    }
   
}
