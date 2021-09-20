//
//  MakeLinkViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/27.
//

import UIKit

enum MakeLinkError: Error {
    case nolinkTitle
    case nolink
    case linkTitleName
}

class MakeLinkViewController: UIViewController {

    @IBOutlet weak var linkMainView: UIView!
    
    @IBOutlet var linkTextView: UITextView!
    
    @IBOutlet weak var linkTitleTextField: UITextField!
    var link: LinkResDTO?
    var editMode : Bool = false
    
    var folderId: Int = 0
    @IBAction func dismissButton(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        
        let userId = UserDefaults.standard.integer(forKey: UserDefaultKey.userID)
        do {
            try validate()
            if(editMode == true){ //수정에서 넘어온 뷰
                let updateLink = UpdateLinkRequest(userId: userId, linkId: link!.linkId, folderId: folderId, title: linkTitleTextField.text!, link: linkTextView.text, bookmark: (link?.bookmark)!)
                LinkService.shared.updateLink(folderId: folderId, linkId: link!.linkId, link: updateLink)
                self.alertViewController(title: "수정 완료", message: "링크가 수정되었습니다", completion: {(response) in
                    if response == "OK" {
                        self.navigationController?.popViewController(animated: true)
                        let previous = self.navigationController?.viewControllers.last as? LinkInViewController
                        previous?.fetchData(folderId: self.folderId)
                        //self.dismiss(animated: true, completion: nil)
                    }
                })
                
            }else { // 생성뷰
                    let linkRequest = CreateLinkRequest(userId: userId, folderId: folderId, title: linkTitleTextField.text!, link: linkTextView.text!, bookmark: false)
                    print(linkRequest)
                    LinkService.shared.createLink(folderId: folderId, linkRequest: linkRequest)
                    self.alertViewController(title: "작성 완료", message: "링크가 생성되었습니다", completion: {(response) in
                        if response == "OK" {
                            self.navigationController?.popViewController(animated: true)
                            let previous = self.navigationController?.viewControllers.last as? LinkInViewController
                            previous?.fetchData(folderId: self.folderId)
                        }
                    })
                    
                }

        }catch {
            var errorMessage: String = ""
            switch error as! MakeLinkError {
                case .nolinkTitle:
                    errorMessage = "링크 이름을 입력해주세요"
                case .nolink:
                    errorMessage = "링크를 입력해주세요"
                case .linkTitleName:
                    errorMessage = "5글자 이내로 링크 이름을 지어주세요"
            }
            
            self.alertViewController(title: "생성 실패", message: errorMessage, completion: { (response) in
                
            })
        }
    }
        
        
       
    
    func validate() throws {
        
        guard (linkTitleTextField.text!.count < 5) else {
            throw MakeLinkError.linkTitleName
        }
        
        guard (linkTitleTextField.text!) != "" else {
            throw MakeLinkError.nolinkTitle
        }
        
        guard ((linkTextView.text!) != "" && linkTextView.text != "링크 입력") else {
            throw MakeLinkError.nolink
        }

        

    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        linkTextViewSetting()
        if(editMode == true) {
            linkTitleTextField.text = link?.title
            linkTextView.text = link?.link
        }

 
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func linkTextViewSetting(){
        linkTextView.circle()
        linkTextView.delegate = self
    }
    


}

extension MakeLinkViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewSetup()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textViewSetup()
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //개행시 키보드 내리기
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewSetup(){
        if linkTextView.text == "링크 입력" {
            linkTextView.text = ""
            linkTextView.textColor = .gray
        }else if(linkTextView.text == ""){
            linkTextView.text = "링크 입력"
            linkTextView.textColor = .gray
        }
    }
}
