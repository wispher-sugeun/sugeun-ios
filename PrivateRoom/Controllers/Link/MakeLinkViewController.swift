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
    
    var string = ""
    
    @IBAction func dismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        if(linkTextView.text != ""){
            //post link cell
            self.alertViewController(title: "작성 완료", message: "링크가 생성되었습니다", completion: {(response) in
                if response == "OK" {
                    self.dismiss(animated: true, completion: nil)
                }
                                            })
        }else {
            self.alertViewController(title: "생성 실패", message: "링크를 입력해주세요", completion: { (response) in
                }
            )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        linkTextViewSetting()
        if(string != ""){
            linkTextView.text = string
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
