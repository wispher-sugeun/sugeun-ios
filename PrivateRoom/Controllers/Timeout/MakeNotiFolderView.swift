//
//  MakeNotiFolderView.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/18.
//

import Foundation
import UIKit


protocol MakeNotiFolderViewdelegate: AnyObject {
    func dissMiss()
    func done()
    func tapImageView()
}



class MakeNotiFolderView: UIView {
    
    
    @IBAction func disMissButton(_ sender: Any) {
        print("dismiss")
        delegate?.dissMiss()
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    @IBOutlet weak var weekDayButton: UIButton!
    
    @IBAction func weekDayButton(_ sender: UIButton) {
        if(sender.isSelected){
            sender.isSelected = false
        }else {
            sender.isSelected = true
        }
    }
    
    @IBOutlet weak var threeDayButton: UIButton!
    
    @IBAction func threeDayButton(_ sender: UIButton) {
        if(sender.isSelected){
            sender.isSelected = false
        }else {
            sender.isSelected = true
        }
    }
    
    
    @IBOutlet weak var oneDayButton: UIButton!
    
    @IBAction func oneDayButton(_ sender: UIButton) {
        if(sender.isSelected){
            sender.isSelected = false
        }else {
            sender.isSelected = true
        }
        
    }
    var delegate: MakeNotiFolderViewdelegate?
    
    @IBAction func doneButton(_ sender: Any) {
        delegate?.done()
    }
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
    
    private func loadView() {
        let view = Bundle.main.loadNibNamed("MakeNotiFolderView",owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
        
    }
    
        func UISetting(){
            imageView.isUserInteractionEnabled = true
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapImageView))
            imageView.addGestureRecognizer(tapGestureRecognizer)
            imageView.contentMode = .scaleToFill
            
            
            nameTextField.borderStyle = .none
            let border = CALayer()
            border.frame = CGRect(x: 0, y: nameTextField.frame.size.height - 1, width: nameTextField.frame.width/2, height: 1)
            
            border.backgroundColor = UIColor.white.cgColor
            nameTextField.layer.addSublayer((border))
            nameTextField.textColor = UIColor.white
    
        }
        
        @objc func didTapImageView(){
            print("did tap")
            delegate?.tapImageView()
           
        }
    
    func configure(cell: GetTimeoutResponse){
        nameTextField.text = cell.title
        if(cell.imageData != nil){
            imageView.image = UIImage(data: cell.imageData!)
        }
        
        let parseDate = DateUtil.parseDateTime(cell.deadline)
        datePicker.date = parseDate
        for i in cell.selected {
            if(i == 7){
                weekDayButton.isSelected = true
            }
            if(i == 3){
                threeDayButton.isSelected = true
            }
            if(i == 1){
                oneDayButton.isSelected = true
            }
        }
    }
}
