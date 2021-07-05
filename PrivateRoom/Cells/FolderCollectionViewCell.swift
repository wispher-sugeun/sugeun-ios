//
//  FolderCollectionViewCell.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/05/15.
//

import UIKit

protocol FolderCollectionViewCellDelegate: AnyObject {
    
    func didTapMoreButton(cell: FolderCollectionViewCell)
}

class FolderCollectionViewCell: UICollectionViewCell {

    static var identifier = "FolderCollectionViewCell"
    @IBOutlet weak var folderImage: UIImageView!
    
    @IBOutlet weak var folderName: UILabel!
    
    @IBAction func folderEditButton(_ sender: Any) {
        cellDelegate?.didTapMoreButton(cell: self)
    }
    

  
    @IBAction func heartButton(_ sender: UIButton) {
        print("here")
        sender.scalesLargeContentImage = true
        sender.isSelected = sender.isSelected ? false : true
       
        sender.isSelected ?  sender.setImage(UIImage(systemName: "heart.fill"), for: .normal) :   sender.setImage(UIImage(systemName: "heart"), for: .normal)
    }
    
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
    
    func configure(){
        folderImage.image = image(UIImage(named: "temp")!, withSize: CGSize(width: contentView.frame.width/2, height: 80))
        
        folderName.text = "temp 폴더 이름"
        
        
    }
    
    
    func image( _ image:UIImage, withSize newSize:CGSize) -> UIImage {

        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0,y: 0,width: newSize.width,height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(.automatic)
    }

}
