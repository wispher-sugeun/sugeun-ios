//
//  MakeFolder.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/13.
//

import Foundation
import UIKit


protocol MakeFolderdelegate: AnyObject {
    func dissMiss()
    func done()
    func tapImageView()
    func folderType()
}

//@IBDesignable
class MakeFolder: UIView {
    
    
    @IBAction func dismissButton(_ sender: Any) {
        delegate?.dissMiss()
    }
    
 
    @IBOutlet weak var folderNameTextField: UITextField!

    @IBOutlet var folderImage: UIImageView!

    @IBOutlet weak var folderTypeButton: UIButton!

    @IBAction func doneButton(_ sender: Any) {
        delegate?.done()
    }

    
    var delegate: MakeFolderdelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
        UISetting()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
        UISetting()
    }
    
    func UISetting(){
        folderImage.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
        folderImage.addGestureRecognizer(tapGestureRecognizer)
        folderImage.contentMode = .scaleToFill
        
        folderTypeButton.addTarget(self, action: #selector(didTapFolderType), for: .touchUpInside)

    }
    
    @objc func didTapImageView(){
        delegate?.tapImageView()
       
    }
    
    @objc func didTapFolderType(){
        delegate?.folderType()
    }


    
    private func loadView() {
        let view = Bundle.main.loadNibNamed("MakeFolder",owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        
    }

    
}