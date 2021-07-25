//
//  LinkViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/05/10.
//

import UIKit

class LinkViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var link = [Link]()
    var filderedLink = [Link]()
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldSetting(textField: searchTextField)
        collectionViewSetting()
        link.append(Link(userId: 1, folderId: 1, linkId: 1, link: "www.naver.com", bookmark: true, date: "2021-02-05"))
        link.append(Link(userId: 2, folderId: 2, linkId: 2, link: "www.google.com", bookmark: true, date: "2021-03-05"))
        link.append(Link(userId: 3, folderId: 3, linkId: 3, link: "www.daum.net", bookmark: false, date: "2021-03-05"))
        filderedLink = link
    }
    
    func textFieldSetting(textField: UITextField){
        //textField.delegate = self
        textField.circle()
    }
    
    func collectionViewSetting(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(LinkCollectionViewCell.nib(), forCellWithReuseIdentifier: LinkCollectionViewCell.identifier)
    }
    

}

extension LinkViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filderedLink.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LinkCollectionViewCell.identifier, for: indexPath)
        return cell
    }
    
    
}

extension LinkViewController: UITextFieldDelegate {
    
}
