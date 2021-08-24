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
        textTableView.delegate = self
        textTableView.dataSource = self
        textTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
    }
    

}

extension TextBookViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(bookmark.count)
        return bookmark.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
     
        cell?.textLabel?.text = bookmark[indexPath.row].text
        cell?.accessoryType = .disclosureIndicator
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(150)
    }
    
    
}
