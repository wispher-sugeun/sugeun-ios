//
//  TextViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/05/10.
//

import UIKit

class TextViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var ButtonStackView: UIStackView!
    @IBOutlet weak var floatingButton: UIButton!
    
    @IBOutlet weak var folderButton: UIButton!
    
    @IBOutlet weak var writeButton: UIButton!
    
    lazy var buttons: [UIButton] = [self.folderButton, self.writeButton]
    
    var isShowFloating: Bool = false
    
//    lazy var floatingDimView: UIView = {
//        let view = UIView(frame: self.view.frame)
//        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
//        view.alpha = 0
//        view.isHidden = true
//
//        self.view.insertSubview(view, belowSubview: self.ButtonStackView)
//
//        return view
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonSetting()
        textFieldSetting(textField: searchTextField)
       
        
      
    }
    
    func buttonSetting(){
        // initial button circle setting
        buttons.forEach({ button
            in
            button.circle()
        })
        floatingButton.circle()
        writeButton.addTarget(self, action: #selector(didTapWriteButton), for: .touchUpInside)
    }
    
    @objc func didTapWriteButton(){
        let wirteVc = self.storyboard?.instantiateViewController(identifier: "writeText") as! WriteViewController
        wirteVc.modalPresentationStyle = .fullScreen
        self.present(wirteVc, animated: true, completion: nil)

    }
    
    func textFieldSetting(textField: UITextField){
        //textField.delegate = self
        textField.circle()
    }
    
    @IBAction func floatingButtonAction(_ sender: UIButton) {
            sender.circle()
            if isShowFloating {
                print("hide Button")
                buttons.reversed().forEach { button in
                    UIView.animate(withDuration: 0.3) {
                        button.isHidden = true
                        self.view.layoutIfNeeded()
                    }
                }

//                UIView.animate(withDuration: 0.5, animations: {
//                    self.floatingDimView.alpha = 0
//                }) { (_) in
//                    self.floatingDimView.isHidden = true
//                }
            } else {
                print("show Button")
//                self.floatingDimView.isHidden = false
//
//                UIView.animate(withDuration: 0.5) {
//                    self.floatingDimView.alpha = 1
//                }

                buttons.forEach { [weak self] button in
                    button.isHidden = false
                    button.alpha = 0

                    UIView.animate(withDuration: 0.3) {
                        button.alpha = 1
                        self?.view.layoutIfNeeded()
                    }
                }
            }

            isShowFloating = !isShowFloating

//            let image = isShowFloating ? UIImage(named: "Hide") : UIImage(named: "Show")
//            let roatation = isShowFloating ? CGAffineTransform(rotationAngle: .pi - (.pi / 4)) : CGAffineTransform.identity
//
//            UIView.animate(withDuration: 0.3) {
//                sender.setImage(image, for: .normal)
//                sender.transform = roatation
//            }
    }


}
