//
//  MainViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/05/10.
//

import UIKit

class MainViewController: UIViewController {
    private var mainVM: MainViewModel!
    
    @IBOutlet weak var searchTextfield: UITextField!
    @IBOutlet weak var folderCollectionView: UICollectionView!
    
    @IBAction func profile(_ sender: Any) {
        performSegue(withIdentifier: "profile", sender: self)
    }
    @IBAction func BackButton(_ sender: Any) {
        performSegue(withIdentifier: "back", sender: self)
    }
    //floating button
    let floatingButton = UIButton(frame: CGRect(x: 250, y: 700, width: 150, height: 150))
    
    private var alertController = UIAlertController()
    private var tblView = UITableView()

    var folders = [Folder]()
    var filteredFolder = [Folder]()
    var sorting = ["이름 순", "생성 순", "최신 순"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        folders.append(Folder(folderName: "CodingTest", isLike: true, Content: [FolderIn(FolderType: "T", content: "hi this is fairy story"), FolderIn(FolderType: "I", content: UIImage(named: "temp") ?? 0), FolderIn(FolderType: "L", content: "www.naver.com")]))
        
        folders.append(Folder(folderName: "Swift", isLike: false, Content: [FolderIn(FolderType: "L", content: "hi this is fairy story"), FolderIn(FolderType: "N", content: UIImage(named: "temp") ?? 0), FolderIn(FolderType: "L", content: "www.naver.com")]))
        
        filteredFolder = folders
        
        collectionViewSetting(collectionView: folderCollectionView)
        
        floatingButtonSetting(button: floatingButton)
        textFieldSetting(textfield: searchTextfield)
        view.addSubview(floatingButton)
        
    }
    
    func floatingButtonSetting(button: UIButton){
        floatingButton.setImage(UIImage(named: "plus"), for: .normal)
        floatingButton.addTarget(self, action: #selector(makeFolder), for: .touchUpInside)
        
    }
    
    @objc func makeFolder(){
        let makeFolderView = self.storyboard?.instantiateViewController(identifier: "makeFolderAlertView") as! makeFolderAlertView
        makeFolderView.modalPresentationStyle = .overCurrentContext
        self.present(makeFolderView, animated: true, completion: nil)
    }
    
    func textFieldSetting(textfield: UITextField){
        textfield.delegate = self
    }
    
    
    func collectionViewSetting(collectionView: UICollectionView){
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(FolderCollectionViewCell.nib(), forCellWithReuseIdentifier: FolderCollectionViewCell.identifier)
        collectionView.allowsSelection = true
        collectionView.isUserInteractionEnabled = true
        
    }

}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FolderCollectionViewCellDelegate {
    
    func didTapMoreButton(cell: FolderCollectionViewCell) {
        print("more button")
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredFolder.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCollectionViewCell.identifier, for: indexPath) as! FolderCollectionViewCell
        //custom cell connected
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.cellDelegate = self
        cell.configure()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width  = (view.frame.width-20)/3
                    return CGSize(width: width, height: width)
    }
    
    //위 아래 라인 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 50
    }
    
    //옆 라인 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.2
    }
    
    //todo - make with navigation
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let VC = self.storyboard?.instantiateViewController(identifier: "folderIn") else { return }
        VC.modalPresentationStyle = .fullScreen
        self.present(VC, animated: true, completion: nil)
        
        
    }
    
    
    
    
    //for cell info and sort
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath)
            
            let folderCount = UILabel()
            folderCount.text = "\(folders.count)개의 폴더"
            folderCount.textColor = UIColor.darkGray
            headerView.addSubview(folderCount)
            folderCount.frame = CGRect(x: 10, y: 10, width: 100, height: 30)
            
            let sortingButton = UIButton()
            let sortingButtonTextAttributes: [NSAttributedString.Key: Any] = [.backgroundColor: UIColor.green, NSAttributedString.Key.kern: 10]
            let sortingButtonText = NSMutableAttributedString(string: "생성 순", attributes: sortingButtonTextAttributes)
            sortingButton.setTitle(sortingButtonText.string, for: .normal)
            sortingButton.setTitleColor(UIColor.gray, for: .normal)
            headerView.addSubview(sortingButton)
            sortingButton.frame = CGRect(x: headerView.frame.maxX - 100, y: 10, width: 100, height: 30)
            
            sortingButton.addTarget(self, action: #selector(didTapSortingButton), for: .touchUpInside)
            
            return headerView
        default: assert(false, "nothing")
            
        }
        
    }
    
    
    @objc func didTapSortingButton(){
        print("did Tap sorting button")
        setupCitySelectionAlert()
    }
    
    private func setupCitySelectionAlert() {
        
        let alertVC = UIViewController.init()
        let rect = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 300.0)
        alertVC.preferredContentSize = rect.size
        
        
        tblView = UITableView(frame: rect)
        tblView.delegate = self
        tblView.dataSource = self
        tblView.register(UITableViewCell.self, forCellReuseIdentifier: "sortingCell")
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 70))
        let headerLabel = UILabel(frame: CGRect(x: 20, y: 10, width: 300, height: 50))

  
        
        let nsHeaderTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.bold),
                                      NSAttributedString.Key.foregroundColor: UIColor.black]
        
        let nsHeaderText = NSAttributedString(string: "정렬하기", attributes: nsHeaderTextAttributes)
        headerLabel.attributedText = nsHeaderText
        headerView.addSubview(headerLabel)
        
        tblView.tableHeaderView = headerView
        tblView.tableFooterView = UIView(frame: .zero)
        tblView.separatorStyle = .none
        tblView.isScrollEnabled = false
        alertVC.view.addSubview(tblView)
        alertVC.view.bringSubviewToFront(tblView)
        alertVC.view.isUserInteractionEnabled = true
        

        tblView.isUserInteractionEnabled = true
        tblView.allowsSelection = true
        
        self.alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.setValue(alertVC, forKey: "contentViewController")
        
        self.present(alertController, animated: true) { [self] in
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            alertController.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
        

    }
    
    @objc func dismissAlertController()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sorting.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sortingCell")!
        
        let nsHeaderTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.light),
                                      NSAttributedString.Key.foregroundColor: UIColor.black]
        
        let nsSortingText = NSAttributedString(string: sorting[indexPath.row], attributes: nsHeaderTextAttributes)
        
        cell.textLabel?.attributedText = nsSortingText
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(50)
    }
    
    //sorting 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            
        }else if(indexPath.row == 1){
            
        }else if(indexPath.row == 2){
            
        }
    }
    
    
}

extension MainViewController: UITextFieldDelegate, UIGestureRecognizerDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let text = textField.text else {return}
        print("text \(text)")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = textField.text! + string
        if searchText.count >= 2{
            filteredFolder = folders.filter({ (result) -> Bool in
                result.folderName.range(of: searchText, options: .caseInsensitive) != nil
            })
        }else {
            filteredFolder = folders
        }
       
        folderCollectionView.reloadData()
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        self.filteredFolder.removeAll()
        for str in folders {
            filteredFolder.append(str)
        }
        folderCollectionView.reloadData()
        return false
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.count != 0 {
            self.filteredFolder.removeAll()
            for str in folders {
                let name = str.folderName.lowercased()
                let range = name.range(of: textField.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil {
                    self.filteredFolder.append(str)
                }
                
            }
        }
        folderCollectionView.reloadData()
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

class makeFolderAlertView: UIViewController, UIGestureRecognizerDelegate {
    
    @IBAction func makeFolderButton(_ sender: Any) {
        guard let folderIn = self.storyboard?.instantiateViewController(identifier: "folderIn") else { return }
        folderIn.modalPresentationStyle = .fullScreen
        self.present(folderIn, animated: true, completion: nil)

    }
    
    
    @IBAction func dismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
   }
    
    
}

