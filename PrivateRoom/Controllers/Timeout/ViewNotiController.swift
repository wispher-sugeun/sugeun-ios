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
    
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImageView()
    }
    
    func loadImageView(){
        imageView.image = tempImageName
        title = titleString
        if(imageData != nil){
            imageView.image = UIImage(data: imageData!)
        }
    }
    

}
