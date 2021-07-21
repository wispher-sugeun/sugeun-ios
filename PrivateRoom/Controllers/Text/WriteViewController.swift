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
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        
        if(validate() == true){
            //try validation
            //post and make textcell
            self.alertViewController(title: "작성 완료", message: "글 작성을 완료하였습니다", completion: {(response) in
                if response == "OK" {
                    self.dismiss(animated: true, completion: nil)
                }
                                            })
            
            
        }else{
            self.alertWithNoViewController(title: "글 작성 실패", message: "글을 작성해주세요", completion: {(response) in
                                            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            textView.text = "글쓰기"
            textView.textColor = .gray
        }
    }
}
