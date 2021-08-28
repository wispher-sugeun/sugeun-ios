//
//  MakeLinkViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/27.
//

import UIKit

class MakeLinkViewController: UIViewController {

    @IBOutlet weak var linkMainView: UIView!
    
    @IBOutlet var linkTextView: UITextView!
    
    @IBOutlet weak var linkTitleTextField: UITextField!
    var link: LinkResDTO?
    var editMode : Bool = false
    
    var folderId: Int = 0
    @IBAction func dismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        let userId = UserDefaults.standard.integer(forKey: UserDefaultKey.userID)
        
        if(validateing()){
            if(editMode == true){ //수정에서 넘어온 뷰
                let updateLink = UpdateLinkRequest(userId: userId, linkId: link!.linkId, folderId: folderId, title: linkTitleTextField.text!, link: linkTextView.text, bookmark: (link?.bookmark)!)
                LinkService.shared.updateLink(folderId: folderId, linkId: link!.linkId, link: updateLink)
                self.alertViewController(title: "수정 완료", message: "링크가 수정되었습니다", completion: {(response) in
                    if response == "OK" {
                        self.dismiss(animated: true, completion: nil)
                    }
                })
                
            }else { // 생성뷰
                if(createValidating()){
                    let linkRequest = CreateLinkRequest(userId: userId, folderId: folderId, title: linkTitleTextField.text!, link: linkTextView.text!, bookmark: false)
                    print(linkRequest)
                    LinkService.shared.createLink(folderId: folderId, linkRequest: linkRequest)
                    self.alertViewController(title: "작성 완료", message: "링크가 생성되었습니다", completion: {(response) in
                        if response == "OK" {
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                    
                } else {
                    self.alertViewController(title: "생성 실패", message: "빈칸을 채워주세요", completion: { (response) in
                        }
                    )
                }
            }
        }
    }
    
    func validateing() -> Bool {
        if(folderId == 0){
            return false
        }
        return true
    }
    
    func createValidating() -> Bool {
        if(linkTitleTextField.text == "" && linkTextView.text == "") {
            return false
        }
        if(folderId == 0){
            return false
        }
        return true
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
            linkTextView.textColor = .white
        }else if(linkTextView.text == ""){
            linkTextView.text = "링크 입력"
            linkTextView.textColor = .gray
        }
    }
}
