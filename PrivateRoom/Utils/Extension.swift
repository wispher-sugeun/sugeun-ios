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

extension UIViewController{
    func alertViewController(title: String, message: String, completion: @escaping  (String) -> Void){
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "확인", style: .default, handler:  { _ in
            completion("OK")
        })
        alertVC.addAction(OKAction)
        self.present(alertVC, animated: true, completion: nil)
    }
}


extension String {
    func isNumeric() -> Bool {
        let set = CharacterSet.decimalDigits
        var string = self
        string.remove(at: string.index(string.startIndex, offsetBy: 3))
        string.remove(at: string.index(string.startIndex, offsetBy: 7))
       print(string)
        for us in string.unicodeScalars where (!set.contains(us)) {
                return false
                
        }
        
        
        return true
    }
    
    func phoneMake() -> String {
    
        var string = self
        string.remove(at: string.index(string.startIndex, offsetBy: 3))
        string.remove(at: string.index(string.startIndex, offsetBy: 7))
        return string
    }
    
    func isValid() -> Bool {
        var string = self
        string = string.phoneMake()
        let start = string.index(string.startIndex, offsetBy: 0)
        let end = string.index(string.startIndex, offsetBy: 3)
        let range = start ..< end
        print(string)
        if(string.count != 11){
            print("not 11 count")
            return false
        }
        if(string[range] != "010"){
            print("not 010")
            return false
        }
        return true
    }
}

extension Date {
        public var year: Int {
            return Calendar.current.component(.year, from: self)
        }
        
        public var month: Int {
             return Calendar.current.component(.month, from: self)
        }
        
        public var day: Int {
             return Calendar.current.component(.day, from: self)
        }
        
        public var monthName: String {
            let nameFormatter = DateFormatter()
            nameFormatter.dateFormat = "MMMM" // format January, February, March, ...
            return nameFormatter.string(from: self)
        }
}

