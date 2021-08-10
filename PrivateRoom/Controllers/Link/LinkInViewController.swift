//
//  LinkInViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/26.
//

import UIKit
import DropDown
import PhotosUI

class LinkInViewController: UIViewController, FolderCollectionViewCellDelegate, UIGestureRecognizerDelegate {
    func didTapMoreButton(cell: FolderCollectionViewCell) {
        more_dropDown.anchorView = cell.moreButton
        more_dropDown.show()
        selectedCellIndexPath = cell.indexPath
        print(selectedCellIndexPath)
        more_dropDown.backgroundColor = UIColor.white
        more_dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("선택한 아이템 : \(item)")
            print("인덱스 : \(index)")
            
            if(index == 0){ // 이름 변경
                editFolderName(completionHandler: {(response) in
                    //TO DO -> update folder Name
                    cell.folderName.text = response
                })
            }else if(index == 1){ // 이미지 변경
                presentPicker()
            }else{ //폴더 삭제
                self.alertWithNoViewController(title: "폴더 삭제", message: "폴더를 삭제하시겠습니까?", completion: {
                    (response) in
                    if(response == "OK"){
                        folderDelete()
                    }
                }
                )
                
            }
        }
        more_dropDown.clearSelection()
    }

  


    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    let cellSpacingHeight: CGFloat = 10

    

    @IBOutlet weak var FrameCollectionView: UICollectionView!
    
    @IBOutlet var folderCollectionView: UICollectionView!
    
    @IBOutlet weak var footerView: UIView!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var stackView: UIStackView!
    

    @IBOutlet weak var writeButton: UIButton!
    
    @IBOutlet weak var folderButton: UIButton!
    @IBOutlet weak var floatingButton: UIButton!
    
    @IBAction func floatingAction(_ sender: Any) {
    }
    
    @IBOutlet weak var searchTextField: UITextField!
    
    private var tblView = UITableView()
    
    private var alertController = UIAlertController()
    var sorting = ["이름 순", "생성 순", "최신 순"]
    var sortingText = "이름 순"
    lazy var buttons: [UIButton] = [self.folderButton, self.writeButton]
    
    var selectedCellIndexPath = IndexPath()
    
    var isShowFloating: Bool = false
    
    
    let linkCell_dropDown: DropDown = {
        let dropDown = DropDown()
        dropDown.width = 100
        dropDown.dataSource = ["링크 수정","링크 삭제"]
        return dropDown
    }()
    
    let more_dropDown: DropDown = {
        let dropDown = DropDown()
        dropDown.width = 100
        dropDown.dataSource = ["이름 변경", "이미지 변경", "폴더 삭제"]
        return dropDown
    }()
    
    private var folderNameTextField: UITextField = {
        var textfield = UITextField()
        return textfield
    }()
    
    var configuration = PHPickerConfiguration()
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func editButton(_ sender: Any) {
        print("edit button")
    }
    var linkCell = [Link]()
    var filteredLinkCell = [Link]()
    
    var linkFolder = [Folder]()
    var filteredLinkFolder = [Folder]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dummy()
        buttonSetting()
        textFieldSetting(textField: searchTextField)
        tapGestureSetting()
        
        collectionViewSetting()
        setupLongGestureRecognizerOnCollection()
       

        NotificationCenter.default.addObserver(self, selector: #selector(self.folderImageChanged(_:)), name: .folderImageChanged, object: nil)

    }
    
    func dummy(){
        linkCell.append(Link(userId: 0, folderId: 0, linkId: 0, link: "https://naver.com", title: "자주 가는 곳", bookmark: true, date: "2021-05-21"))
        linkCell.append(Link(userId: 1, folderId: 1, linkId: 1, link: "https://google.com",title: "자주 가는 곳", bookmark: true, date: "2021-05-22"))
        linkCell.append(Link(userId: 2, folderId: 2, linkId: 2, link: "https://jouureee.tistory.com",title: "자주 가는 곳", bookmark: true, date: "2021-05-23"))
        
        filteredLinkCell = linkCell
        
        linkFolder.append(Folder(folderId: 0, folderName: "test name", folderImage: UIImage(systemName: "heart.fill"), isLike: true))
        linkFolder.append(Folder(folderId: 1, folderName: "test name", folderImage: UIImage(systemName: "heart.fill"), isLike: true))
        linkFolder.append(Folder(folderId: 2, folderName: "test name", folderImage: UIImage(systemName: "heart.fill"), isLike: true))

        linkFolder.append(Folder(folderId: 3, folderName: "test name", folderImage: UIImage(systemName: "heart.fill"), isLike: true))
        linkFolder.append(Folder(folderId: 4, folderName: "test name", folderImage: UIImage(systemName: "heart.fill"), isLike: true))
        linkFolder.append(Folder(folderId: 5, folderName: "test name", folderImage: UIImage(systemName: "heart.fill"), isLike: true))
        
        filteredLinkFolder = linkFolder
        
    }
    
    func tapGestureSetting(){
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyTapMethod))

        singleTapGestureRecognizer.numberOfTapsRequired = 1

        singleTapGestureRecognizer.isEnabled = true

        singleTapGestureRecognizer.cancelsTouchesInView = false

        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
    }
    
  
    func collectionViewSetting(){
        FrameCollectionView.delegate = self
        FrameCollectionView.dataSource = self
        
        self.FrameCollectionView.translatesAutoresizingMaskIntoConstraints  = false
        FrameCollectionView.register(LinkCollectionViewCell.nib(), forCellWithReuseIdentifier: LinkCollectionViewCell.identifier)
       
    }
 
    
    @objc func didTapSortingButton(){
        setupCitySelectionAlert()
    }
    
    private func setupCitySelectionAlert() {
        
        let alertVC = UIViewController.init()
        let rect = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 250.0)
        alertVC.preferredContentSize = rect.size
        
        
        tblView = UITableView(frame: rect)
        tblView.delegate = self
        tblView.dataSource = self
        tblView.register(UITableViewCell.self, forCellReuseIdentifier: "sortingCell")
 
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 70))
        let headerLabel = UILabel(frame: CGRect(x: 20, y: 10, width: 300, height: 50))
        //뷰에 있는 ui label들 지우고 다시 그리기
        let allLabels = headerView.get(all: UILabel.self)
          for sub in allLabels {
            sub.removeFromSuperview()
         }
  
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        isShowFloating = false
        hideButton()
    }
    
    
    func buttonSetting(){
        // initial button circle setting
        buttons.forEach({ button
            in
            button.circle()
        })
        floatingButton.circle()
        writeButton.addTarget(self, action: #selector(didTapWriteButton), for: .touchUpInside)
    }
    
    @objc func MyTapMethod(){
        self.view.endEditing(true)
        if(isShowFloating){
            isShowFloating = false
            hideButton()
        }
    }
    
    @objc func didTapWriteButton(){
        let wirteVc = self.storyboard?.instantiateViewController(identifier: "makeLinkCell") as! MakeLinkViewController
        wirteVc.modalPresentationStyle = .fullScreen
        self.present(wirteVc, animated: true, completion: nil)

    }
    
    func textFieldSetting(textField: UITextField){
        textField.delegate = self
        textField.circle()
    }
    
    
    @IBAction func floatingButtonAction(_ sender: UIButton) {
            sender.circle()
            if isShowFloating {
                hideButton()
            } else {
               showButton()
            }

            isShowFloating = !isShowFloating
    }
    
    func hideButton(){
        buttons.reversed().forEach { button in
            UIView.animate(withDuration: 0.3) {
                button.isHidden = true
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func showButton(){
        buttons.forEach { [weak self] button in
            button.isHidden = false
            button.alpha = 0

            UIView.animate(withDuration: 0.3) {
                button.alpha = 1
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    func editFolderName(completionHandler: @escaping ((String) -> Void)){
        let alertVC = UIAlertController(title: "폴더 이름 수정", message: nil, preferredStyle: .alert)
       
        alertVC.addTextField(configurationHandler: { (textField) -> Void in
            self.folderNameTextField = textField
            self.folderNameTextField.placeholder = "새로 수정할 아이디를 입력해주세요"
        })
        let label = UILabel(frame:CGRect(x: 0, y: 40, width: 270, height:18))
        
        let editAction = UIAlertAction(title: "수정", style: .default, handler: { [self] (action) -> Void in
            guard let userInput = self.folderNameTextField.text else {
                return
            }
            label.isHidden = true
            
            label.textColor = .red
            label.font = label.font.withSize(12)
            label.textAlignment = .center
            label.text = ""
            alertVC.view.addSubview(label)
            
            if userInput == ""{
                label.text = "이름을 입력해주세요"
                label.isHidden = false
                self.present(alertVC, animated: true, completion: nil)

            }else {
                completionHandler(userInput)
            }
            
            
           
        })
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertVC.addAction(editAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
        
        
    }
    
    func presentPicker(){
        configuration.filter = .any(of: [.images])
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    

        
    func folderDelete(){
        filteredLinkFolder.remove(at: selectedCellIndexPath[1])
        self.alertViewController(title: "삭제 완료", message: "폴더를 삭제하였습니다", completion: { (response) in
            if(response == "OK"){
                DispatchQueue.main.async {
                    self.folderCollectionView.reloadData()
                }
            }
        })
       
    }

    
    func image( _ image:UIImage, withSize newSize:CGSize) -> UIImage {

        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0,y: 0,width: newSize.width,height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(.automatic)
    }
    
    
    @objc func folderImageChanged(_ notification: NSNotification){
        //text ~~
        print(notification.userInfo ?? "")
        print("folderImageChanged")
        if let dict = notification.userInfo as NSDictionary? {
            if let folderImage = dict["image"] as? UIImage{
                filteredLinkFolder[selectedCellIndexPath[1]].folderImage = image( UIImage(systemName: "heart.fill")!, withSize: CGSize(width: 100, height: 80))
                    
                DispatchQueue.main.async {
                    self.folderCollectionView.reloadData()
                }
                
                // do something with your image
            }
        }
    }
    
    private func setupLongGestureRecognizerOnCollection() {
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delegate = self
        longPressedGesture.delaysTouchesBegan = true
        FrameCollectionView.addGestureRecognizer(longPressedGesture)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer){
        if (gestureRecognizer.state != .began) {
                return
            }

            let p = gestureRecognizer.location(in: FrameCollectionView)

            if let indexPath = FrameCollectionView.indexPathForItem(at: p) {
                print("Long press at item: \(indexPath.row)")
            }
    }

}

extension LinkInViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sorting.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let defaultCell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if(tableView == tblView){
            let cell = tblView.dequeueReusableCell(withIdentifier: "sortingCell")!
            
            let nsHeaderTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.light),
                                          NSAttributedString.Key.foregroundColor: UIColor.black]
            
            let nsSortingText = NSAttributedString(string: sorting[indexPath.row], attributes: nsHeaderTextAttributes)
            
            cell.textLabel?.attributedText = nsSortingText
            return cell
        }

        return defaultCell!
        
    }
    

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(50)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //sorting
        if(tableView == tblView){
            if(indexPath.row == 0){
                sortingAlpanumeric()
            }else if(indexPath.row == 1){
                sortingOldest()
            }else if(indexPath.row == 2){
                sortingOldest()
            }
            sortingText = sorting[indexPath.row]
            self.dismissAlertController()
            FrameCollectionView.reloadData() // for 글자 업데이트
            FrameCollectionView.collectionViewLayout.invalidateLayout()
        }
       
    }
    
    //sorting
    func sortingAlpanumeric(){
        linkCell = linkCell.sorted {$0.link.localizedStandardCompare($1.link) == .orderedAscending}
        filteredLinkCell = linkCell
        
        linkFolder = linkFolder.sorted {$0.folderName.localizedStandardCompare($1.folderName) == .orderedAscending}
        filteredLinkFolder = linkFolder
        FrameCollectionView.reloadData()
        //folderCollectionView.reloadData()
       
    }
    
    func sortingOldest(){
        linkCell = linkCell.sorted { $0.linkId < $1.linkId }
        filteredLinkCell = linkCell
        
        linkFolder = linkFolder.sorted { $0.folderId < $1.folderId }
        filteredLinkFolder = linkFolder
        
        FrameCollectionView.reloadData()
        //folderCollectionView.reloadData()
    }
    
    func sortingLatest(){
        linkCell = linkCell.sorted { $0.linkId > $1.linkId }
        filteredLinkCell = linkCell
        
        linkFolder = linkFolder.sorted { $0.folderId > $1.folderId }
        filteredLinkFolder = linkFolder
        
        FrameCollectionView.reloadData()
        //folderCollectionView.reloadData()
    }
}


extension LinkInViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LinkCollectionViewCellDelegate {
    func clipAction(cell: LinkCollectionViewCell) {
        print("click clip")
        let copyString = cell.linkLabel.text
        
        UIPasteboard.general.string = copyString
        self.showToast(message: "클립 보드에 복사되었습니다.")
    }
    func moreButton(cell: LinkCollectionViewCell) {
        
        print("more button")
        linkCell_dropDown.anchorView = cell.moreButton
        linkCell_dropDown.show()
        selectedCellIndexPath = cell.indexPath!

        linkCell_dropDown.backgroundColor = UIColor.white
        linkCell_dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("선택한 아이템 : \(item)")
            print("인덱스 : \(index)")
            
            if(index == 0){ // 수정 view로 이동
                let wirteVc = self.storyboard?.instantiateViewController(identifier: "makeLinkCell") as! MakeLinkViewController
               
                
                guard let currentLink = cell.linkLabel.text else {
                    print("no currentLink exits")
                    return
                }
                
                wirteVc.string = currentLink
                wirteVc.modalPresentationStyle = .fullScreen
                self.present(wirteVc, animated: true, completion: nil)
                
            }else if(index == 1) { // 알림 삭제
                self.alertWithNoViewController(title: "링크 삭제", message: "링크를 삭제 하시겠습니까?", completion: { (response) in
                    if (response == "OK") {
                        //링크 삭제
                        DispatchQueue.main.async {
                            linkCell.remove(at: (cell.indexPath?[1])!)
                            filteredLinkCell = linkCell
                            print("링크 셀 수 : \(linkCell.count)")
                            FrameCollectionView.reloadData()
                            
                        }
                        self.alertViewController(title: "삭제 완료", message: "알림이 삭제 되었습니다.", completion: {(response) in
                           
                           
                        })
                }
                    
                })
                    
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == FrameCollectionView) {
            return filteredLinkCell.count
        }
        return filteredLinkFolder.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == FrameCollectionView){
            print("cell for item")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LinkCollectionViewCell.identifier, for: indexPath) as! LinkCollectionViewCell
            let urlString: String = filteredLinkCell[indexPath.row].link
            let url = URL(string: urlString)
            cell.fetchURLPreview(url: url!)
            cell.linkLabel.text = urlString
            if(filteredLinkCell[indexPath.row].bookmark) {
                cell.bookMark.isSelected = true
                cell.bookMarkToggle( cell.bookMark)
            }
            
//            func configure(model: Link){
//                print("func configure called" )
//                if(model.bookmark) {
//                    bookMark.isSelected = true
//                    bookMarkToggle(bookMark)
//                }
//
//                let urlString = model.link
//                let url = URL(string: urlString)!
//                fetchURLPreview(url: url)
//                linkLabel.text = urlString
//
//
//            }
//
//            cell.configure(model: filteredLinkCell[indexPath.row])
            cell.delegate = self
            cell.configureHeight(with: 200)
            cell.indexPath = indexPath
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCollectionViewCell.identifier, for: indexPath) as! FolderCollectionViewCell
        //custom cell connected
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.cellDelegate = self
        cell.configure(folder: filteredLinkFolder[indexPath.row])
        cell.indexPath = indexPath
        
       
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView == folderCollectionView) {
            let frameSize = collectionView.frame.size
            let size = (frameSize.width - 64.0) / 2.0
            // 27 px on both side, and within, there is 10 px gap.
            return CGSize(width: size, height: size)
//            let width  = (view.frame.width-20)/3
//            print("folderCollectionView width \(width)")
//            return CGSize(width: width, height: width)
            
        }else if(collectionView == FrameCollectionView){
            let width = FrameCollectionView.bounds.width
            let height = FrameCollectionView.bounds.height
            print("width : \(FrameCollectionView.bounds.width / 2)")
            print("height : \(FrameCollectionView.bounds.height / 2)")
            return CGSize(width: (width / 2) - 100, height: height)
        }
        
        return CGSize(width: 0, height: 0)
         
       
    }

    //위 아래 라인 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    //옆 라인 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if(collectionView == folderCollectionView){
            return UIEdgeInsets(top: 27, left: 0, bottom: 27, right: 0)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    }
    
    //todo - make with navigation
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let VC = self.storyboard?.instantiateViewController(identifier: "folderIn") else { return }
//        VC.modalPresentationStyle = .fullScreen
//        self.present(VC, animated: true, completion: nil)
//    }
    
    //for cell info and sort
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath)
            let allLabels = headerView.get(all: UILabel.self)
              for sub in allLabels {
                sub.removeFromSuperview()
             }
            let sortingButton = UIButton()
            let sortingButtonTextAttributes: [NSAttributedString.Key: Any] = [.backgroundColor: UIColor.green, NSAttributedString.Key.kern: 10]
            let sortingButtonText = NSMutableAttributedString(string: "\(sortingText)", attributes: sortingButtonTextAttributes)
            sortingButton.setTitle(sortingButtonText.string, for: .normal)
            sortingButton.setTitleColor(UIColor.gray, for: .normal)
            headerView.addSubview(sortingButton)
            sortingButton.frame = CGRect(x: headerView.frame.maxX - 100, y: 10, width: 100, height: 30)
            
            sortingButton.addTarget(self, action: #selector(didTapSortingButton), for: .touchUpInside)
            
            return headerView
            
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerView", for: indexPath)
            
            footerView.backgroundColor = .white
            let layout = UICollectionViewFlowLayout()
//            footerView.translatesAutoresizingMaskIntoConstraints = false
//
//            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            //footerView 내에 collectionview 생성
            folderCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: footerView.frame.width, height: footerView.frame.height), collectionViewLayout: layout)
            folderCollectionView.register(FolderCollectionViewCell.nib(), forCellWithReuseIdentifier: FolderCollectionViewCell.identifier)
            print("footerview height")
            print(footerView.frame.height)
            folderCollectionView.delegate = self
            folderCollectionView.dataSource = self
            //self.folderCollectionView.translatesAutoresizingMaskIntoConstraints = false

           
            print("UICollectionView.elementKindSectionFooter 1")
            let width: CGFloat = folderCollectionView.bounds.width
            let height: CGFloat = folderCollectionView.bounds.height
            print("width is \(width)")
            print("height is \(height)")
            footerView.addSubview(folderCollectionView)
            
            return footerView
        default: assert(false, "nothing")
            
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        print("UICollectionView.elementKindSectionFooter 2")
        let width: CGFloat = view.bounds.width
        let height: CGFloat = view.bounds.height
     
        return CGSize(width: width, height: 100)

        
    }

    
    
  
}

extension LinkInViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField.text != nil else {return}
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = textField.text! + string
        if searchText.count >= 2{
            filteredLinkFolder = linkFolder.filter({ (result) -> Bool in
                result.folderName.range(of: searchText, options: .caseInsensitive) != nil
            })
            
            filteredLinkCell = linkCell.filter({ (result) -> Bool in
                result.link.range(of: searchText, options: .caseInsensitive) != nil
            })
        }else {
            filteredLinkFolder = linkFolder
            filteredLinkCell = linkCell
        }
        
        FrameCollectionView.reloadData()
//        collectionView.reloadData()
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        self.filteredLinkFolder.removeAll()
        self.filteredLinkCell.removeAll()
        
        for str in linkCell {
            filteredLinkCell.append(str)
        }
        for str in linkFolder {
            filteredLinkFolder.append(str)
        }
        
        FrameCollectionView.reloadData()
//        collectionView.reloadData()
        return false
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text?.count != 0 {
            self.filteredLinkFolder.removeAll()
            self.filteredLinkCell.removeAll()
            
            for str in linkFolder {
                let name = str.folderName.lowercased()
                let range = name.range(of: textField.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil {
                    self.filteredLinkFolder.append(str)
                }
                
            }
            
            for str in linkCell {
                let name = str.link.lowercased()
                let range = name.range(of: textField.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil {
                    self.filteredLinkCell.append(str)
                }
                
            }
        }
        
        FrameCollectionView.reloadData()
        textField.resignFirstResponder()
        return true
    }
}

extension LinkInViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let image = image as? UIImage {
                    NotificationCenter.default.post(name: .folderImageChanged, object: nil, userInfo: ["image" : image])


                }
        }
            
        } else { // TODO: Handle empty results or item providernot being able load UIImage
            print("can't load image")
            
        }

    }
    
    
}

    
    
