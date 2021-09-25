//
//  makeFolderAlertView.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/09/05.
//

import UIKit
import DropDown
import PhotosUI
import NVActivityIndicatorView

enum MakeFolderError: Error {
    case folderNameCount
    case folderImage
    case folderName
    case folderType
}

class makeFolderAlertView: UIViewController, UIGestureRecognizerDelegate, MakeFolderdelegate {
    var parentFolderId: Int = 0
    
    var defaultImage = UIImage(systemName: "questionmark.square")
    
    let indicator = NVActivityIndicatorView(frame: CGRect(x: 162, y: 100, width: 50, height: 50),
                                            type: .circleStrokeSpin,
                                            color: #colorLiteral(red: 0.5568627451, green: 0.6392156863, blue: 0.8, alpha: 1),
                                            padding: 0)
    
    func dissMiss() {
        self.navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
    }
    
    func done() {
        do {
            try checkingNameValidating()
            try validate()
            //to do server mk folder post
            let userId = UserDefaults.standard.integer(forKey: UserDefaultKey.userID)
            //create folder
            var type: String = ""
            
            if(folderView.folderTypeButton.currentTitle! == "텍스트"){
                type = "PHRASE"
            }else if(folderView.folderTypeButton.currentTitle! == "링크"){
                type = "LINK"
            }
            
            let folderInfo = CreateFolderRequest(folderName: folderView.folderNameTextField.text!, userId: userId, type: type, parentFolderId: parentFolderId, imageFile: (folderView.folderImage.image?.jpeg(.lowest))!)
            print("parentFolderID : \(folderInfo)")
            
            indicator.startAnimating()
            FolderService.shared.createFolder(folder: folderInfo, completion: { (response) in
                if(response == true){
                    self.alertViewController(title: "폴더 생성 완료", message: "폴더가 생성되었습니다.", completion: { response in
                        if(response == "OK"){
                            self.navigationController?.popViewController(animated: true)
                        }
                    } )
                }
            }, errorHandler: { (error) in})
            indicator.stopAnimating()            
            
        } catch {
            var errorMessage: String = ""
            switch error as! MakeFolderError {
            case .folderNameCount:
                errorMessage = "10글자 이내로 폴더 이름을 입력해주세요"
            case .folderImage:
                errorMessage = "이미지를 선택해주세요"
            case .folderName:
                errorMessage = "폴더 이름을 입력해주세요"
            case .folderType:
                errorMessage = "폴더 타입을 선택해주세요"
            }
            
            self.alertViewController(title: "생성 실패", message: errorMessage, completion: { (response) in
                
            })
        }
        
       
    }
    
    func checkingNameValidating() throws {
        guard (folderView.folderNameTextField.text!.count < 10) else {
            throw MakeFolderError.folderNameCount
        }
    }
    
    func validate() throws {
        
        guard (folderView.folderNameTextField.text!) != "" else {
            throw MakeFolderError.folderName
        }
        guard (folderView.folderImage.image != defaultImage) else {
            throw MakeFolderError.folderImage
        }
        
        guard folderView.folderTypeButton.currentTitle != "" else {
            throw MakeFolderError.folderType
        }
    }
    
    static let type_dropDown = DropDown()

    
    
    func folderType() {
        makeFolderAlertView.type_dropDown.anchorView = folderView.folderTypeButton
        makeFolderAlertView.type_dropDown.show()
    }
    
    
    func tapImageView(){
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: [.images])
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)

        
    }
    
    
    @IBOutlet var folderView: MakeFolder!
    
    func type_dropDownSetting(){
        //makeFolderAlertView.type_dropDown.dataSource = []
        makeFolderAlertView.type_dropDown.textColor = .white
        makeFolderAlertView.type_dropDown.backgroundColor = #colorLiteral(red: 0.2659958005, green: 0.3394620717, blue: 0.6190373302, alpha: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        folderView.delegate = self
        type_dropDownSetting()
        indicator.center = self.view.center
        view.addSubview(indicator)
        
        makeFolderAlertView.type_dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
//            print("선택한 아이템 : \(item)")
//            print("인덱스 : \(index)")
            folderView.folderTypeButton.setTitle("\(item)", for: .normal)
            folderView.folderTypeButton.setTitleColor(UIColor.black, for: .normal)
            folderView.folderTypeButton.layer.borderWidth = 1
            folderView.folderTypeButton.layer.borderColor = UIColor.black.cgColor
            folderView.folderTypeButton.backgroundColor = UIColor.clear
            folderView.folderTypeButton.setTitleColor(.white, for: .normal)
            makeFolderAlertView.type_dropDown.clearSelection()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    
}

extension makeFolderAlertView: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [self] (image, error) in
                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        self.folderView.folderImage.image = image
                    }
                }
        }
            
        } else { // TODO: Handle empty results or item providernot being able load UIImage
            print("can't load image")
            
        }

    }
}

