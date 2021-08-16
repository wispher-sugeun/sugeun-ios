//
//  WriteViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/21.
//

import UIKit

class WriteViewController: UIViewController {

    @IBOutlet weak var FrameView: UIView!
    
    @IBOutlet weak var textView: UITextView!
    
    var editText:String = ""
    var editMode: Bool = false
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        
        if(validate() == true){
            //try validation
            //post and make textcell
            self.alertViewController(title: "작성 완료", message: "글 작성을 완료하였습니다", completion: {(response) in
                if response == "OK" {
                    //test
                    guard let userId = UserDefaults.standard.integer(forKey: UserDefaultKey.userID) as? Int else { return }
                   let dateString =  DateUtil.serverSendDateFormat(Date()) 
                    
                    let createPhrase = CreatePhraseRequest(userId: userId, folderId: 1, text: self.textView.text!, bookmark: false, textDate: dateString)
                    PhraseService.shared.createPhrase(folderId: 1, createRequest: createPhrase)
                    self.dismiss(animated: true, completion: nil)
                }
                                            })
            
            
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
