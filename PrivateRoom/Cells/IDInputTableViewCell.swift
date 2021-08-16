//
//  IDInputTableViewCell.swift
//  GDONG
//
//  Created by JoSoJeong on 2021/07/04.
//

import UIKit
protocol IDInputTableViewCellDelegate {
    func changID(cell: IDInputTableViewCell)
}
class IDInputTableViewCell: UITableViewCell {
    

    @IBOutlet weak var label: UILabel!

    @IBOutlet weak var textfield: UITextField! {
        didSet {
            guard let userNickName = UserDefaults.standard.string(forKey: UserDefaultKey.userNickName) else { return }
            textfield.text = userNickName
        }
    }
    
    static var identifier = "IDInputTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    @IBAction func IDChangeButton(_ sender: Any) {
        delegate?.changID(cell: self)
        //이 cell을 위임하고 있는 메소드를 찾아 구현된 부분을 수행
    }
    var delegate: IDInputTableViewCellDelegate?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    static func nib() -> UINib {
           return UINib(nibName: "IDInputTableViewCell", bundle: nil)
    }
    
}
