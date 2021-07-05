//
//  FolderInViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/05/18.
//

import UIKit

//todo - how to seperate the cell 
enum CellType: String, CaseIterable {
    case textCell = "T"
    case imageCell = "I"
    case urlCell = "U"
    case notiCell = "N"
}

class FolderInViewController: UIViewController {

    @IBOutlet weak var FoderCollectionView: UICollectionView!
    
    @IBAction func backButton(_ sender: Any) {
        
        let VC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "VC") as ViewController
        VC.modalPresentationStyle = .fullScreen
        self.present(VC, animated: true, completion: nil)
    }
    
    var folder = [Folder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FoderCollectionView.delegate = self
        FoderCollectionView.dataSource = self
        
        folder.append(Folder(folderName: "CodingTest", isLike: true, Content: [FolderIn(FolderType: "T", content: "hi this is fairy story"), FolderIn(FolderType: "I", content: UIImage(named: "temp") ?? 0), FolderIn(FolderType: "L", content: "www.naver.com")]))
    }
    
    
    

}

extension FolderInViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        folder[0].Content.count // 3
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(TextCell.self, forCellWithReuseIdentifier: "textCell")
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "imageCell")
        collectionView.register(LinkCell.self, forCellWithReuseIdentifier: "linkCell")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! UICollectionViewCell
        
        let type = folder[0].Content[indexPath.row].FolderType
        switch type {
        case "T":
            let textcell = collectionView.dequeueReusableCell(withReuseIdentifier: "textCell", for: indexPath) as! TextCell
            textcell.backgroundColor = .blue
            return textcell
        case "I":
            let imagecell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
            imagecell.backgroundColor = .brown
            return imagecell
        case "L":
            let linkcell = collectionView.dequeueReusableCell(withReuseIdentifier: "linkCell", for: indexPath) as! LinkCell
            linkcell.backgroundColor = .cyan
            return linkcell
        default:
            print("here")
        }
       
        return cell
    }
    
    
    
    
}

class TextCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: CGRect.init())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame
        return layoutAttributes
    }
}

class ImageCell: UICollectionViewCell {
    
}

class LinkCell: UICollectionViewCell {
    
}
