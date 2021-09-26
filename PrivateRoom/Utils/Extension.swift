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
    
    func circle(){
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
    }
    
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
    
    func alertWithNoViewController(title: String, message: String, completion: @escaping  (String) -> Void){
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "확인", style: .default, handler:  { _ in
            completion("OK")
        })
        let CANCELAction = UIAlertAction(title: "취소", style: .default, handler:  nil)
        alertVC.addAction(OKAction)
        alertVC.addAction(CANCELAction)
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
        if(self == ""){
            return false
        }
        if(string.count != 13){
            print("not 11 count")
            return false
        }
        
        string = string.phoneMake()
        let start = string.index(string.startIndex, offsetBy: 0)
        let end = string.index(string.startIndex, offsetBy: 3)
        let range = start ..< end
        if(string[range] != "010"){
            print("not 010")
            return false
        }
        return true
    }
}

extension UIViewController {

    func showToast(message : String) {

        let toastLabel = UILabel(frame: CGRect(x: 50, y: self.view.frame.size.height - 100, width: self.view.frame.width - 100, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont(name: message, size: 8)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.5, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
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
    
        public var hour: Int {
             return Calendar.current.component(.hour, from: self)
        }
    
        public var minute: Int {
            return Calendar.current.component(.minute, from: self)
        }
        
        public var monthName: String {
            let nameFormatter = DateFormatter()
            nameFormatter.dateFormat = "MMMM" // format January, February, March, ...
            return nameFormatter.string(from: self)
        }
}

extension UITextView {
    func circle(){
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
    }
}

extension UIView {
    class func getAllSubviews<T: UIView>(from parentView: UIView) -> [T] {
     
        return parentView.subviews.flatMap { subView -> [T] in
            var result = getAllSubviews(from: subView) as [T]
            if let view = subView as? T { result.append(view) }
            return result
        }
    }
     class func getAllSubviews(from parentView: UIView, types: [UIView.Type]) -> [UIView] {
          
         return parentView.subviews.flatMap { subView -> [UIView] in
             var result = getAllSubviews(from: subView) as [UIView]
             for type in types {
                 if subView.classForCoder == type {
                     result.append(subView)
                     return result
                 }
             }
             return result
         }
     }
     func getAllSubviews<T: UIView>() -> [T] {
          return UIView.getAllSubviews(from: self) as [T]
     }
     
     func get<T: UIView>(all type: T.Type) -> [T] {
          return UIView.getAllSubviews(from: self) as [T]
     }
     
     func get(all type: UIView.Type) -> [UIView] {
          return UIView.getAllSubviews(from: self)
     }
}

extension UIPageViewController {

    var scrollView: UIScrollView? {
        return view.subviews.first { $0 is UIScrollView } as? UIScrollView
    }

}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

//var version: String? {
//    guard let dictionary = Bundle.main.infoDictionary, let version = dictionary["CFBundleShortVersionString"] as? String, let build = dictionary["CFBundleVersion"] as? String else {return nil}
//    let versionAndBuild: String = "vserion: \(version), build: \(build)"
//    print(versionAndBuild)
//    return version
//}
