//
//  ViewNotiController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/11.
//

import UIKit

class ViewNotiController: UIViewController {


    @IBOutlet weak var imageView: UIImageView!
    
    var tempImageName: UIImage?
    var imageData: Data?
    var titleString: String = ""
    
    @objc func didTapBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImageView()
        let image = UIImage(systemName: "chevron.backward")
        let leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(didTapBack))
        leftBarButtonItem.tintColor = #colorLiteral(red: 0.1647058824, green: 0.2, blue: 0.3411764706, alpha: 1)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    func loadImageView(){
        imageView.image = tempImageName
        title = titleString
        if(imageData != nil){
            imageView.image = UIImage(data: imageData!)
        }
    }
    

}
