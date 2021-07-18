//
//  NotiViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/05/10.
//

import UIKit
import PhotosUI

class NotiViewController: UIViewController {


        @IBOutlet weak var floatingButton: UIButton!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            floatingButtonSetting(floatingButton)
            
        }
        
        func floatingButtonSetting(_: UIButton){
            floatingButton.addTarget(self, action: #selector(makeFolder), for: .touchUpInside)
        }
        
        @objc func makeFolder(){
            let makeNotiFolderView = self.storyboard?.instantiateViewController(identifier: "MakeNotiFolderViewController") as! MakeNotiFolderViewController
            makeNotiFolderView.modalPresentationStyle = .overCurrentContext
            self.present(makeNotiFolderView, animated: true, completion: nil)
        }
        
}

class MakeNotiFolderViewController: UIViewController, MakeNotiFolderViewdelegate {
    func dissMiss() {
        print("vc dismiss")
        self.dismiss(animated: true, completion: nil)
    }
    
    func done() {
        if(validate()){
            print(makeNotiFolderView.nameTextField.text!)
 
            print(makeNotiFolderView.datePicker.date)
            let intArray = alarmIntArray()
            print(intArray)
            

            self.dismiss(animated: true, completion: nil)
            print("생성 완료")
        }
    }
    
    func alarmIntArray() -> [Int] {
        var intArray = [Int]()
        if(makeNotiFolderView.weekDayButton.isSelected){
            intArray.append(7)
        }
        if(makeNotiFolderView.threeDayButton.isSelected){
            intArray.append(3)
        }
        if(makeNotiFolderView.oneDayButton.isSelected){
            intArray.append(1)
        }
        return intArray
    }
    
    func tapImageView() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: [.images])
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func validate() -> Bool{
        if makeNotiFolderView.nameTextField.text != "" {
            return true
        }
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    
    @IBOutlet weak var makeNotiFolderView: MakeNotiFolderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeNotiFolderView.delegate = self
        print("view did load")
    }
    
    
}

extension MakeNotiFolderViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [self] (image, error) in
                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        self.makeNotiFolderView
                        .imageView.image = image
                    }
                }
        }

        } else { // TODO: Handle empty results or item providernot being able load UIImage
            print("can't load image")

        }
    }
}
