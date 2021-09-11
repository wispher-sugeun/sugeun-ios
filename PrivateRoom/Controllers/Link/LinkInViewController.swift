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
            let folderId = filteredLinkFolder[cell.indexPath.row].folderId
            if(index == 0){ // 이름 변경
                editFolderName(folderId: folderId, completionHandler: {(response) in
                    cell.folderName.text = response
                    self.alertViewController(title: "이름 변경 완료", message: "폴더 이름이 수정되었습니다", completion: { (response) in})
                })
            }else if(index == 1){ // 이미지 변경
                presentPicker()
            }else{ //폴더 삭제
                self.alertWithNoViewController(title: "폴더 삭제", message: "폴더를 삭제하시겠습니까?", completion: {
                    (response) in
                    if(response == "OK"){
                        folderDelete(cell: cell)
                    }
                }
                )
                
            }
        }
        more_dropDown.clearSelection()
    }
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!

    
    var folderName: String = ""
    
    let refreshControl = UIRefreshControl()
    let cellSpacingHeight: CGFloat = 10
    
    @IBOutlet weak var FrameCollectionView: UICollectionView!
    
    @IBOutlet weak var folderCollectionView: UICollectionView!
    
    @IBOutlet weak var linkCellHeight: NSLayoutConstraint!
    @IBOutlet weak var footerViewheight: NSLayoutConstraint!

    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    
    var oneFolderHeight = 170
    var oneLinkCellHeight = 200
    
    
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
    
    @IBOutlet weak var navItem: UINavigationItem!
    
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
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editButton(_ sender: Any) {
        print("edit button")
    }
    
    var total: DetailFolderResponse? //folderid로 조회된 친구들
    var linkCell = [LinkResDTO]()
    var filteredLinkCell = [LinkResDTO]()
    
    var linkFolder = [GetByFolderResponse]()
    var filteredLinkFolder = [FolderViewModel]()
    var mainViewModel = [FolderViewModel]()
    
    var folderId: Int = 0
    
    var emptyView: UIView {
        let emptyView = UIView(frame: self.view.bounds)
        //emptyView.backgroundColor = .red
        let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width:view.bounds.size.width, height: linkCellHeight.constant))
        noDataLabel.text = "폴더 안에 데이터가 아직 존재하지 않습니다"
        noDataLabel.textColor = UIColor.systemGray2
        noDataLabel.textAlignment = .center
        emptyView.addSubview(noDataLabel)
        return emptyView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isShowFloating = false
        
        getData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        buttonSetting()
        textFieldSetting(textField: searchTextField)
        tapGestureSetting()
        
        collectionViewSetting()
        setupLongGestureRecognizerOnCollection()

        hideButton()
        refreshing()


    }
    
    func getData(){
        if((((total?.folderResDTOList!) != nil))) {
            //data load
            print("here folderResDTOList")
            linkFolder = total.map {$0.folderResDTOList}!!
            self.mainViewModel = self.linkFolder.map{ return FolderViewModel(allFolder: GetFolderResponse(folderId: $0.folderId, folderName: $0.folderName, userId: $0.userId, imageData: $0.imageData ?? Data(), type: "LINK"))}
            self.filteredLinkFolder = self.mainViewModel
 
            self.folderCollectionView.reloadData()
            
            //데이터 0 이상시 뷰 그리기
            if(total?.folderResDTOList?.count != 0 ){
                print("here folderCollectionView no Hidden")
                folderCollectionView.isHidden = false
                /// cell + 70(margin)
                if((total?.folderResDTOList!.count)! <= 2){
                    footerViewheight.constant = CGFloat(oneLinkCellHeight + 50 + 20)
                }else{
                    let count = ((total?.folderResDTOList!.count)! / 2) + 1
                    footerViewheight.constant = CGFloat((oneLinkCellHeight * count) + 50 + 20)
                    
                }
                
                self.folderCollectionView.reloadData()
            }else{
                print("here folderCollectionView isHidden")
                folderCollectionView.isHidden = true
            }
        }
        
        
        if((((total?.linkResDTOList!) != nil))) {
            linkCell = total.map { $0.linkResDTOList }!!
            print("here linkResDTOList")
            FrameCollectionView.isHidden = false
            filteredLinkCell = linkCell
            self.FrameCollectionView.reloadData()
            
            
            //데이터 0 이상시 뷰 그리기
            if(total?.linkResDTOList?.count != 0){
                FrameCollectionView.isHidden = false
                //cell 높이 다시 그리기
                
                if((total?.linkResDTOList!.count)! <= 2){
                    /// cell + 100(margin) + headerView height -> 한줄
                    linkCellHeight.constant = CGFloat(oneLinkCellHeight + 100 + 70)
                }else{
                    let count = ((total?.linkResDTOList!.count)! / 2) + 1
                    linkCellHeight.constant = CGFloat((oneLinkCellHeight * count) + 100 + 70 + 40) ////<- top margin
                }
                
                self.FrameCollectionView.reloadData()
                
                
            }else{
                print("here FrameCollectionView hidden")
                //FrameCollectionView.isHidden = true
                
                if(FrameCollectionView.isHidden == false && folderCollectionView.isHidden == true){
                    print("here")
                    linkCellHeight.constant = self.view.frame.height - 200
                    FrameCollectionView.addSubview(emptyView)
                }else {
                    emptyView.removeFromSuperview()
                }
            }
            
            
        }
        
        navItem.title = folderName
        print("title : \(String(describing: navItem.title))")
    }
    
    func fetchData(folderId: Int){
        FolderService.shared.viewFolder(folderId: folderId, completion: { (response) in
            self.total = response
            self.getData()
//            self.linkCell = response.linkResDTOList!
//            self.mainViewModel = self.linkFolder.map{ return FolderViewModel(allFolder: GetFolderResponse(folderId: $0.folderId, folderName: $0.folderName, userId: $0.userId, imageData: $0.imageData ?? Data(), type: "LINK"))}
//            self.filteredLinkFolder = self.mainViewModel
//            self.filteredLinkCell = self.linkCell
//
//            DispatchQueue.main.async {
//                FrameCollectionView.reloadData()
//            }
        }, errorHandler: { (response) in})
    }
    
    func refreshing(){
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        refreshControl.beginRefreshing()
        folderCollectionView.addSubview(refreshControl)
        FrameCollectionView.addSubview(refreshControl)
        
    }
    
    @objc func refresh(_ sender: AnyObject) {
        fetchData(folderId: folderId)
        refreshControl.endRefreshing()
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
        
        FrameCollectionView.collectionViewLayout = CollectionViewLeftAlignFlowLayout()
        if let flowLayout = FrameCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                    flowLayout.itemSize = CGSize(width: screenWidth / 2, height: screenWidth / 2)
                    flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
                    flowLayout.minimumInteritemSpacing = 0
                    flowLayout.minimumLineSpacing = 0
                  }

        folderCollectionView.dataSource = self
        folderCollectionView.delegate = self
        
        folderCollectionView.collectionViewLayout = CollectionViewLeftAlignFlowLayout()
        if let flowLayout = folderCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                    flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 10)
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
                  }
        
      
        
        FrameCollectionView.register(LinkCollectionViewCell.nib(), forCellWithReuseIdentifier: LinkCollectionViewCell.identifier)
        folderCollectionView.register(FolderCollectionViewCell.nib(), forCellWithReuseIdentifier: FolderCollectionViewCell.identifier)
        
       
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
    
  
    
    
    func buttonSetting(){
        // initial button circle setting
        buttons.forEach({ button
            in
            button.circle()
        })
        floatingButton.circle()
        writeButton.addTarget(self, action: #selector(didTapWriteButton), for: .touchUpInside)
        folderButton.addTarget(self, action: #selector(didTapMakeFolder), for: .touchUpInside)
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
        wirteVc.folderId = folderId
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(wirteVc, animated: true)
//        wirteVc.modalPresentationStyle = .fullScreen
//        self.present(wirteVc, animated: true, completion: nil)

    }
    
    @objc func didTapMakeFolder(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let makeFolderView = storyBoard.instantiateViewController(identifier: "makeFolderAlertView") as! makeFolderAlertView
        makeFolderAlertView.type_dropDown.dataSource = ["링크"]
        makeFolderView.parentFolderId = folderId
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(makeFolderView, animated: true)
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
    
    func editFolderName(folderId: Int, completionHandler: @escaping ((String) -> Void)){
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
                FolderService.shared.changeFolderName(folderId: folderId, changeName: userInput, errorHandler: { (error) in})
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
    

        
    func folderDelete(cell: FolderCollectionViewCell){
        
        let index = cell.indexPath.row
        print("folderID : \(index)")
        FolderService.shared.deleteFolder(folderId: filteredLinkFolder[index].folderId, errorHandler: { (error) in})
        filteredLinkFolder.remove(at: index)
        self.alertViewController(title: "삭제 완료", message: "폴더를 삭제하였습니다", completion: { (response) in
            if(response == "OK"){
                DispatchQueue.main.async {
                    self.folderCollectionView.reloadData()
                }
            }
        })

       
    }

    
//    @objc func folderImageChanged(_ notification: NSNotification){
//        //text ~~
//        print(notification.userInfo ?? "")
//        print("folderImageChanged")
//        if let dict = notification.userInfo as NSDictionary? {
//            if let folderImage = dict["image"] as? UIImage{
////                filteredLinkFolder[selectedCellIndexPath[1]].folderImage = image( UIImage(systemName: "heart.fill")!, withSize: CGSize(width: 100, height: 80))
//
//                DispatchQueue.main.async {
//                    self.folderCollectionView.reloadData()
//                }
//
//                // do something with your image
//            }
//        }
//    }
    
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
        
        mainViewModel = mainViewModel.sorted {$0.folderName.localizedStandardCompare($1.folderName) == .orderedAscending}
        filteredLinkFolder = mainViewModel
        FrameCollectionView.reloadData()
        //folderCollectionView.reloadData()
       
    }
    
    func sortingOldest(){
        linkCell = linkCell.sorted { $0.linkId < $1.linkId }
        filteredLinkCell = linkCell
        
        mainViewModel = mainViewModel.sorted { $0.folderId < $1.folderId }
        filteredLinkFolder = mainViewModel
        
        FrameCollectionView.reloadData()
        //folderCollectionView.reloadData()
    }
    
    func sortingLatest(){
        linkCell = linkCell.sorted { $0.linkId > $1.linkId }
        filteredLinkCell = linkCell
        
        mainViewModel = mainViewModel.sorted { $0.folderId > $1.folderId }
        filteredLinkFolder = mainViewModel
        
        FrameCollectionView.reloadData()
        //folderCollectionView.reloadData()
    }
}


extension LinkInViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LinkCollectionViewCellDelegate {
   
    func bookmark(cell: LinkCollectionViewCell) {
        LinkService.shared.linkBookMark(linkId: linkCell[cell.indexPath!.row].linkId)
    }
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
                wirteVc.folderId = folderId
                wirteVc.editMode = true
                wirteVc.link = linkCell[cell.indexPath!.row]
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.pushViewController(wirteVc, animated: true)
                
//                wirteVc.modalPresentationStyle = .fullScreen
//                self.present(wirteVc, animated: true, completion: nil)
                
            }else if(index == 1) { // 링크 삭제
                self.alertWithNoViewController(title: "링크 삭제", message: "링크를 삭제 하시겠습니까?", completion: { (response) in
                    if (response == "OK") {
                        //링크 삭제
                        DispatchQueue.main.async {
                            linkCell.remove(at: (cell.indexPath?[1])!)
                            filteredLinkCell = linkCell
                            print("링크 셀 수 : \(linkCell.count)")
                            FrameCollectionView.reloadData()
                            
                        }
                        
                        LinkService.shared.deleteLink(folderId: folderId, linkId: linkCell[cell.indexPath!.row].linkId)
                        alertViewController(title: "삭제 완료", message: "알림이 삭제 되었습니다.", completion: {(response) in })
                }
                    
                })
                    
            }
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == FrameCollectionView) {
            return filteredLinkCell.count
        }
        print("filtered folder \(filteredLinkFolder.count)")
        return filteredLinkFolder.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == FrameCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LinkCollectionViewCell.identifier, for: indexPath) as! LinkCollectionViewCell
            var urlString: String = filteredLinkCell[indexPath.row].link
            //공백 있을 시 공백 제거
            urlString = urlString.replacingOccurrences(of: " ", with: "")

            let url = URL(string: urlString)
            cell.title.text = filteredLinkCell[indexPath.row].title
            cell.fetchURLPreview(url: url!)
            cell.linkLabel.text = urlString
            if(filteredLinkCell[indexPath.row].bookmark) {
                cell.bookMark.isSelected = true
                cell.bookMarkToggle( cell.bookMark)
            }
            
            cell.delegate = self
            cell.configureHeight(with: oneLinkCellHeight)
            cell.indexPath = indexPath
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCollectionViewCell.identifier, for: indexPath) as! FolderCollectionViewCell
        //cell 크기 고정
        cell.viewLayout(width: view.fs_width/2 - 30, height: CGFloat(oneFolderHeight))
        cell.cellDelegate = self
        cell.view.layer.borderColor = UIColor.darkGray.cgColor
        cell.view.layer.masksToBounds = true
        cell.view.layer.cornerRadius = 5
        cell.view.layer.borderWidth = 1
        cell.view.layer.shadowOpacity = 1.0

        let folderViewModel = filteredLinkFolder[indexPath.row]
        cell.folderViewModel = folderViewModel
        //cell.configure(folder: filteredFolder[indexPath.row])
        cell.indexPath = indexPath
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == folderCollectionView){ // folderCell
            //push to same view controller
            let index = filteredLinkFolder[indexPath.row]
            guard let linkedIn = self.storyboard?.instantiateViewController(identifier: "linkFolderIn") as? LinkInViewController else { return }
            DispatchQueue.global().async {
                FolderService.shared.viewFolder(folderId: index.folderId, completion: { (response) in
                    Thread.sleep(forTimeInterval: 2)
                    linkedIn.folderId = index.folderId
                    linkedIn.total = response
                    //print("total isss \(response)")
                    linkedIn.getData()
                }, errorHandler: { (error) in })
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(linkedIn, animated: true)
                }
                
            }
 
            
        }
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if(collectionView == folderCollectionView) {
//            let frameSize = collectionView.frame.size
//            let size = (frameSize.width - 64.0) / 2.0
//            // 27 px on both side, and within, there is 10 px gap.
//            return CGSize(width: size, height: size)
//
//        }else if(collectionView == FrameCollectionView){
//            let width = FrameCollectionView.bounds.width
//            let height = FrameCollectionView.bounds.height
//            print("width : \(FrameCollectionView.bounds.width / 2)")
//            print("height : \(FrameCollectionView.bounds.height / 2)")
//            return CGSize(width: (width / 2) - 5, height: height)
//        }
//
//        return CGSize(width: 0, height: 0)
//
//
//    }
//
//    //위 아래 라인 간격
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//    }
    
//    //옆 라인 간격
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if(collectionView == folderCollectionView){
            return UIEdgeInsets(top: 27, left: 0, bottom: 27, right: 0)
        }
        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 10)

    }
    
    
    //for cell info and sort
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            print("header view loaded")
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
            
//        case UICollectionView.elementKindSectionFooter:
//            print("footerView view loaded")
//            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerView", for: indexPath)
//            //if(!filteredLinkFolder.isEmpty) { //linkFolder가 빈 배열이 아닐때만 collection view 넣기
//                footerView.backgroundColor = .white
//                let layout = UICollectionViewFlowLayout()
//
//                print("UICollectionView.elementKindSectionFooter 1")
//                folderCollectionView = UICollectionView(frame: footerView.bounds, collectionViewLayout: layout)
//                folderCollectionView.register(FolderCollectionViewCell.nib(), forCellWithReuseIdentifier: FolderCollectionViewCell.identifier)
//                print("footerview height")
//                print(footerView.frame.height)
//                folderCollectionView.delegate = self
//                folderCollectionView.dataSource = self
//                folderCollectionView.prefetchDataSource = self
//
//                let width: CGFloat = folderCollectionView.bounds.width
//                let height: CGFloat = folderCollectionView.bounds.height
//                print("width is \(width)")
//                print("height is \(height)")
//                footerView.addSubview(folderCollectionView)
//
//                return footerView
            
           
        default: assert(false, "nothing")
            
        }
        
        
    return UICollectionReusableView()
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        print("UICollectionView.elementKindSectionFooter 2")
//        let width: CGFloat = view.bounds.width
//        let height: CGFloat = view.bounds.height
//
////        if(filteredLinkFolder.isEmpty){
////            print("here")
////            return CGSize(width: width, height: 0)
////        }else {
////            folderCollectionView.reloadData()
////        }
//
//        return CGSize(width: width, height: 100)
//
//
//
//    }

    
    
  
}

extension LinkInViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField.text != nil else {return}
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = textField.text! + string
        if searchText.count >= 2{
            filteredLinkFolder = mainViewModel.filter({ (result) -> Bool in
                result.folderName.range(of: searchText, options: .caseInsensitive) != nil
            })
            
            filteredLinkCell = linkCell.filter({ (result) -> Bool in
                result.link.range(of: searchText, options: .caseInsensitive) != nil
            })
        }else {
            filteredLinkFolder = mainViewModel
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
        for str in mainViewModel {
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
            
            for str in mainViewModel {
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
                    let index = self.selectedCellIndexPath[1]
                    let folderId = self.filteredLinkFolder[index].folderId
                    
                    FolderService.shared.changeFolderImage(folderId: folderId, changeImage: image.jpeg(.lowest)!, completion: { (response) in
                                        if(response == true){
                                            self.filteredLinkFolder[index].imageData = image.jpeg(.lowest)!
                                            DispatchQueue.main.async {
                                                self.folderCollectionView.reloadItems(at: [self.selectedCellIndexPath])
                                            }
                                            self.alertViewController(title: "이미지 변경", message: "이미지가 변경되었습니다", completion: { (response) in})
                                        }
                                    }, errorHandler: { (error) in})
                                }
                            }
            
        } else { // TODO: Handle empty results or item providernot being able load UIImage
            print("can't load image")
            
        }

    }
    
    
}

    
    
