//
//  ViewNotiController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/11.
//

import UIKit

class ViewNotiController: UIViewController {

    @IBAction func backButton(_ sender: Any) {
    }
    @IBOutlet weak var imageView: UIImageView!
    
    var tempImageName: UIImage?
    var imageData: Data?
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImageView()
    }
    
    func loadImageView(){
        imageView.image = tempImageName
        if(!imageData!.isEmpty){
            imageView.image = UIImage(data: imageData!)
        }
    }
    

}
