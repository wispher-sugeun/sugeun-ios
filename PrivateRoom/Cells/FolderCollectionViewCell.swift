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
    
    var folderViewModel: FolderViewModel! {
        didSet {
            self.folderImage.image = image(folderViewModel.image, withSize: CGSize(width: contentView.frame.width/2, height: 80))
            self.folderName.text = folderViewModel.name
        }
    }
    @IBOutlet weak var view: UIView!
    
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
    
    func viewLayout(width: CGFloat, height: CGFloat){
        view.translatesAutoresizingMaskIntoConstraints = false
        view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        view.widthAnchor.constraint(equalToConstant: width).isActive = true
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
