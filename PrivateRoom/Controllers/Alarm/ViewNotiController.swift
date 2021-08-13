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
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImageView()
    }
    
    func loadImageView(){
        imageView.image = tempImageName
    }
    

}
