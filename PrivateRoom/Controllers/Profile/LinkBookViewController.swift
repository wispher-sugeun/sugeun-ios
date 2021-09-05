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
        tableviewSetting()
       
    }
    
    func tableviewSetting(){
        linkTableView.delegate = self
        linkTableView.dataSource = self
        linkTableView.register(LinkBookMarkTableViewCell.nib(), forCellReuseIdentifier: LinkBookMarkTableViewCell.identifier)
        linkTableView.rowHeight = UITableView.automaticDimension
        linkTableView.estimatedRowHeight = UITableView.automaticDimension
    }
    


}

extension LinkBookViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return linkBookmark.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LinkBookMarkTableViewCell.identifier) as! LinkBookMarkTableViewCell
        cell.configure(model: linkBookmark[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == linkTableView){
            return UITableView.automaticDimension
        }
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var link = linkBookmark[indexPath.row].link
        link = link.replacingOccurrences(of: " ", with: "")
        print(link)
        if let url = URL(string: link), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
