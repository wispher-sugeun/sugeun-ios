//
//  FolderCollectionViewCell.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/05/15.
//

import UIKit

protocol FolderCollectionViewCellDelegate: AnyObject {
    
    func didTapMoreButton(cell: FolderCollectionViewCell)
//    func editFolderName(cell: FolderCollectionViewCell)
}

class FolderCollectionViewCell: UICollectionViewCell {

    static var identifier = "FolderCollectionViewCell"
    @IBOutlet weak var folderImage: UIImageView!
    
    @IBOutlet weak var folderName: UILabel!
    
    @IBOutlet weak var moreButton: UIButton!
    
    @IBAction func folderEditButton(_ sender: Any) {
        cellDelegate?.didTapMoreButton(cell: self)
    }
    
    var indexPath: IndexPath = []
    
    var cellDelegate: FolderCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }
    
    static func nib() -> UINib {
           return UINib(nibName: "FolderCollectionViewCell", bundle: nil)
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(folder: Folder){
        folderImage.image = image(folder.folderImage!, withSize: CGSize(width: contentView.frame.width/2, height: 80))
        folderName.text = folder.folderName
        
        
    }
    
    
    func image( _ image:UIImage, withSize newSize:CGSize) -> UIImage {

        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0,y: 0,width: newSize.width,height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(.automatic)
    }

}
