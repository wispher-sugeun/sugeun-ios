//
//  TextBookViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/14.
//

import UIKit

class TextBookViewController: UIViewController {

    var bookmark = [PhraseResDTO]()
    
    @IBOutlet weak var textTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UserProfileService.shared.getMyBookMark(completion: { (textResponse) in
            self.bookmark = textResponse.phraseResDTOList!
            self.textTableView.reloadData()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableviewSetting()
    }
    
    func tableviewSetting(){
        textTableView.delegate = self
        textTableView.dataSource = self
        textTableView.register(TextBookMarkTableViewCell.nib(), forCellReuseIdentifier: TextBookMarkTableViewCell.identifier)
        textTableView.separatorInset.left = 0
        textTableView.translatesAutoresizingMaskIntoConstraints = false
        textTableView.rowHeight = UITableView.automaticDimension
        textTableView.estimatedRowHeight = 44
    }
    

}

extension TextBookViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmark.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextBookMarkTableViewCell.identifier) as! TextBookMarkTableViewCell
        cell.configure(model: bookmark[indexPath.row])
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    
    
}
