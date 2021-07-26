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
}


class LinkCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var richView: UIView!
    
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
        // Initialization code
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
    
    func configure(model: Link){
        let url = URL(string: "https://www.apple.com/airpods-pro/")!
        
        fetchURLPreview(url: url)
        
    }

}
