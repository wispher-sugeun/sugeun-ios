//
//  LinkCollectionViewCell.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/21.
//

import UIKit
import LinkPresentation


protocol LinkCollectionViewCellDelegate {
    func moreButton(cell: LinkCollectionViewCell)
    func clipAction(cell: LinkCollectionViewCell)
    func bookmark(cell: LinkCollectionViewCell)
}


class LinkCollectionViewCell: UICollectionViewCell {
    
    var indexPath : IndexPath?
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var richView: UIView!
    

    @IBOutlet weak var linkLabel: UILabel!
    
    @IBOutlet weak var clipBoard: UIButton!
    
    @IBOutlet weak var title: UILabel!
    @IBAction func clipAction(_ sender: Any) {
        delegate?.clipAction(cell: self)
    }
    
    @IBOutlet weak var moreButton: UIButton!
    @IBAction func moreButton(_ sender: Any) {
        delegate?.moreButton(cell: self)
    }
    
    @IBOutlet weak var bookMark: UIButton!
    
    @IBAction func bookMark(_ sender: UIButton) {
        sender.scalesLargeContentImage = true
        sender.isSelected = sender.isSelected ? false : true
        bookMarkToggle(sender)
        delegate?.bookmark(cell: self)
        
    }
    
    private lazy var linkView = LPLinkView()
    
    
    
    private var metaData: LPLinkMetadata = LPLinkMetadata() {
        didSet {
            DispatchQueue.main.async {
                self.addRichLinkToView(view: self.richView, metadata: self.metaData)
            }
        }
    }
    
    
    static let identifier = "LinkCollectionViewCell"
    
    var delegate: LinkCollectionViewCellDelegate?
    
    func bookMarkToggle(_ sender: UIButton){
        sender.isSelected ?  sender.setBackgroundImage(UIImage(systemName: "bookmark.fill"), for: .normal) :   sender.setBackgroundImage(UIImage(systemName: "bookmark"), for: .normal)
    }
    
    func configureHeight(with height: Int){
        //width 고정
        mainView.translatesAutoresizingMaskIntoConstraints = false
        //print("link collection cell width size")
        print(UIScreen.main.bounds.size.width)
        mainView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width / 2 - 15).isActive = true
        richView.heightAnchor.constraint(equalToConstant: CGFloat(height)).isActive = true
    }
    
    func addRichLinkToView(view: UIView, metadata: LPLinkMetadata) {
          linkView = LPLinkView(metadata: metadata)
          view.addSubview(linkView)
          linkView.frame =  view.bounds
      }
    
    @available(iOS 13.0, *)
       func fetchPreviewManually(title: String, originalURL: URL, fileName: String, fileType: String) -> LPLinkMetadata? {
           let metaData = LPLinkMetadata()
           metaData.title  = title
           metaData.originalURL = originalURL
           let path = Bundle.main.path(forResource: fileName, ofType: fileType)
           metaData.imageProvider = NSItemProvider(contentsOf: URL(fileURLWithPath: path ?? ""))
       
           return metaData
       }
           
       @available(iOS 13.0, *)
       func fetchURLPreview(url: URL) {
            print("fetchURLPreview \(url)")
           let metadataProvider = LPMetadataProvider()
           metadataProvider.startFetchingMetadata(for: url) { (metadata, error) in
               guard let data = metadata, error == nil else {
                   return
               }
            self.metaData = data

           }
       }

    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "LinkCollectionViewCell", bundle: nil)
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

}
