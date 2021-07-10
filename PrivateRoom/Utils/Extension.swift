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

extension UITextField {
    func updatePhoneNumber(_ replacementString: String?, _ textString: String?) -> Bool {
        guard let textCount = textString?.count else {return true}
        guard let currentString = self.text else {return true}
        if replacementString == "" {
            return true
        } else if textCount == 3 {
            self.text =  currentString + "-"
        } else if textCount == 8 {
            self.text = currentString + "-"
        } else if textCount > 12 || replacementString == " " {
            return false
        }
        return true
    }
}
