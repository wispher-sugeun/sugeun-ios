//
//  LinkBookViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/14.
//

import UIKit

class LinkBookViewController: UIViewController {

    @IBOutlet weak var linkTableView: UITableView!
    var linkBookmark = [LinkResDTO]()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UserProfileService.shared.getMyBookMark(completion: { (linkResponse) in
            self.linkBookmark = linkResponse.linkResDTOList!
            self.linkTableView.reloadData()
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        linkTableView.delegate = self
        linkTableView.dataSource = self
        linkTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
       
    }
    


}

extension LinkBookViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return linkBookmark.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = linkBookmark[indexPath.row].link
        cell?.accessoryType = .disclosureIndicator
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(150)
    }
    
    
}
