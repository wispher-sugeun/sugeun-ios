//
//  WriteViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/21.
//

import UIKit

class WriteViewController: UIViewController {

    var folderId: Int = 0
    var phraseId: Int = 0
    
    @IBOutlet weak var FrameView: UIView!
    
    @IBOutlet weak var textView: UITextView!
    
    var editText:String = ""
    var editMode: Bool = false
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func doneButton(_ sender: Any) {
        let userId = UserDefaults.standard.integer(forKey: UserDefaultKey.userID)
        
        if(validate()){
            //try validation
            if(editMode){ // 글 수정에서 넘어온 글
                self.alertViewController(title: "수정 완료", message: "글 수정을 완료하였습니다", completion: {(response) in
                    if response == "OK" {
                        PhraseService.shared.updatePhrase(folderId: self.folderId, phraseId: self.phraseId, text: self.textView.text!)
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            } else {
                self.alertViewController(title: "작성 완료", message: "글 작성을 완료하였습니다", completion: {(response) in
                    if response == "OK" {
                        //test
                        
                       let dateString =  DateUtil.serverSendDateFormat(Date())
                        
                        let createPhrase = CreatePhraseRequest(userId: userId, folderId: self.folderId, text: self.textView.text!, bookmark: false, textDate: dateString)
                        PhraseService.shared.createPhrase(folderId: self.folderId, createRequest: createPhrase)
                        self.navigationController?.popViewController(animated: true)
                    }
                                                })
            }
           
            
        }else{
            self.alertViewController(title: "글 작성 실패", message: "글을 작성해주세요", completion: {(response) in })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(editMode){
            title = "글 수정"
            textView.text = editText
        }
        UISetting()
        textViewSetting()

     
    }
    
    func validate() -> Bool {
        if textView.text != "" {
            return true
        }
        
        if(folderId == 0 || phraseId == 0) {
            return false
        }
        
        return false
        
    }
    
    func textViewSetting(){
        textView.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func UISetting(){
        FrameView.layer.borderColor = UIColor.black.cgColor
        FrameView.layer.borderWidth = 2
    }
    



}

extension WriteViewController: UITextViewDelegate {
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
        if textView.text == "글쓰기" {
            textView.text = ""
            textView.textColor = .black
        }else if(textView.text == ""){
            if(editMode == true){ //edit mode 에서 왔을 때
                textView.text = ""
                textView.textColor = .black
            }else {
                textView.text = "글쓰기"
                textView.textColor = .gray
            }
            
        }
    }
}
