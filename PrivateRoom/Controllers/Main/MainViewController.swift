//
//  MainViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/05/10.
//

import UIKit
import DropDown
import PhotosUI

class MainViewController: UIViewController, FolderCollectionViewCellDelegate {
    
    var sortingText = "이름 순"
    
    private var mainViewModels = [FolderViewModel]()
    var folders = [GetFolderResponse]()
    var filteredFolder = [FolderViewModel]()
    
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var collectionViewLayout: CollectionViewLeftAlignFlowLayout! {
        didSet {
            collectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var configuration = PHPickerConfiguration()
    
    func didTapMoreButton(cell: FolderCollectionViewCell) {
        print("more button")
        more_dropDown.anchorView = cell.moreButton
        more_dropDown.show()
        selectedCellIndexPath = cell.indexPath
        more_dropDown.backgroundColor = UIColor.white
        more_dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("선택한 아이템 : \(item)")
            print("인덱스 : \(index)")
            let folderId = filteredFolder[cell.indexPath.row].folderId
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
    
    
    func presentPicker(){
        configuration.filter = .any(of: [.images])
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
 
    
    @IBOutlet weak var searchTextfield: UITextField!
    @IBOutlet weak var folderCollectionView: UICollectionView!
    
    @IBOutlet weak var floatingButton: UIButton!
    
    @IBAction func profile(_ sender: Any) {
        performSegue(withIdentifier: "profile", sender: self)
    }
    @IBAction func BackButton(_ sender: Any) {
        performSegue(withIdentifier: "back", sender: self)
    }

    
    private var alertController = UIAlertController()
    private var tblView = UITableView()

    var sorting = ["이름 순", "생성 순", "최신 순"]
    var selectedCellIndexPath = IndexPath()
    
    let more_dropDown: DropDown = {
        let dropDown = DropDown()
        dropDown.width = 100
        dropDown.dataSource = ["이름 변경", "이미지 변경", "폴더 삭제"] //TODO : how dataSource 2 make red?
        return dropDown
    }()
    
    private var folderNameTextField: UITextField = {
        var textfield = UITextField()
        return textfield
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchData()
    }
    
    func fetchData(){
        FolderService.shared.getFolder(completion: { (response) in
            self.folders = response
            self.mainViewModels = self.folders.map({ return FolderViewModel(allFolder: $0)})
            self.filteredFolder = self.mainViewModels
            //print("get folders : \(self.filteredFolder)")
            self.folderCollectionView.reloadData()
        }, errorHandler: { (error) in})
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        collectionViewSetting(collectionView: folderCollectionView)
        
        floatingButtonSetting(button: floatingButton)
        textFieldSetting(textfield: searchTextfield)
        refreshing()
        
        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.folderImageChanged(_:)), name: .folderImageChanged, object: nil)
        
        flowSetting()
        
    }
    
    func refreshing(){
        //refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        folderCollectionView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    @objc func refresh(_ sender: AnyObject) {
        fetchData()
        refreshControl.endRefreshing()
    }
    
    func flowSetting(){
        folderCollectionView.collectionViewLayout = collectionViewLayout
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 10)
 
        collectionViewLayout.itemSize = CGSize(width: screenWidth / 2, height: screenWidth / 2)
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.minimumLineSpacing = 0
        
    }

//    //폴더 이미지 변경
//    @objc func folderImageChanged(_ notification: NSNotification){
//        //text ~~
//        print(notification.userInfo ?? "")
//        print("folderImageChanged")
//        if let dict = notification.userInfo as NSDictionary? {
//            if let folderImage = dict["image"] as? UIImage {
//                let folderId = filteredFolder[selectedCellIndexPath[1]].folderId
//                FolderService.shared.changeFolderImage(folderId: folderId, changeImage: folderImage.jpeg(.lowest)!, completion: { (response) in
//                    if(response == true){
//                        self.fetchData()
//                        self.alertViewController(title: "이미지 변경", message: "이미지가 변경되었습니다", completion: { (response) in})
//                    }
//                }, errorHandler: { (error) in})
//            }
//        }
//
//    }
    
    func folderDelete(cell: FolderCollectionViewCell){
        let index = cell.indexPath.row
        print("folderID : \(index)")
        FolderService.shared.deleteFolder(folderId: filteredFolder[index].folderId, errorHandler: { (error) in})
        filteredFolder.remove(at: index)
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
    
    //폴더 이름 변경
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

    
    func floatingButtonSetting(button: UIButton){
        // TO DO make circle
        floatingButton.addTarget(self, action: #selector(makeFolder), for: .touchUpInside)
        floatingButton.circle()
    }
    
    @objc func makeFolder(){
        let makeFolderView = self.storyboard?.instantiateViewController(identifier: "makeFolderAlertView") as! makeFolderAlertView
        makeFolderAlertView.type_dropDown.dataSource = ["텍스트", "링크"]
        self.navigationController?.pushViewController(makeFolderView, animated: true)
//        makeFolderView.modalPresentationStyle = .overCurrentContext
//        self.present(makeFolderView, animated: true, completion: nil)
    }
    
    func textFieldSetting(textfield: UITextField){
        textfield.delegate = self
        textfield.circle()
    }
    
    
    func collectionViewSetting(collectionView: UICollectionView){
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(FolderCollectionViewCell.nib(), forCellWithReuseIdentifier: FolderCollectionViewCell.identifier)
        collectionView.allowsSelection = true
        collectionView.isUserInteractionEnabled = true
        
    }

}

extension MainViewController: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [self] (image, error) in
                if let image = image as? UIImage {
                    let folderId = filteredFolder[selectedCellIndexPath[1]].folderId
                    FolderService.shared.changeFolderImage(folderId: folderId, changeImage: image.jpeg(.lowest)!, completion: { (response) in
                                        if(response == true){
                                            self.fetchData()
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

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredFolder.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCollectionViewCell.identifier, for: indexPath) as! FolderCollectionViewCell
    
        //cell 크기 고정
        cell.viewLayout(width: view.fs_width/2 - 30, height: 170)
        cell.cellDelegate = self
        cell.view.layer.borderColor = UIColor.darkGray.cgColor
        cell.view.layer.masksToBounds = true
        cell.view.layer.cornerRadius = 5
        cell.view.layer.borderWidth = 1
        cell.view.layer.shadowOpacity = 1.0

        let folderViewModel = filteredFolder[indexPath.row]
        cell.folderViewModel = folderViewModel
        //cell.configure(folder: filteredFolder[indexPath.row])
        cell.indexPath = indexPath
        return cell
    }
    
//    private func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        if indexPath.row == 0
//        {
//            return CGSize(width: screenWidth, height: screenWidth/3)
//        }
//        return CGSize(width: screenWidth/3, height: screenWidth/3);
//
//    }

    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        print("sizeForItemAt called \(indexPath)")
//        let cellRatio: CGFloat = 5/3
//            if (UIDevice.current.orientation.isLandscape) {
//                return collectionView.getCellSize(numberOFItemsRowAt: 5, cellRatio: cellRatio)
//            } else {
//                return collectionView.getCellSize(numberOFItemsRowAt: 2, cellRatio: cellRatio)
//            }
//    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if let flowLayout = self.folderCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.invalidateLayout()
        }
    }
    
    //위 아래 라인 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
//
//    //옆 라인 간격
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 1
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//
//        return UIEdgeInsets(top: 27, left: 0, bottom: 27, right: 0)
//

//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let folderType = folders[indexPath.row].type
        let folderId = folders[indexPath.row].folderId
        if(folderType == "PHRASE"){
            guard let textInVC = self.storyboard?.instantiateViewController(identifier: "textIn") as? TextInViewController else { return }
            FolderService.shared.viewFolder(folderId: folderId, completion: { (response) in
                textInVC.total = response
                textInVC.folderId = folderId
                self.navigationController?.pushViewController(textInVC, animated: true)
            }, errorHandler: { (error) in})
            
        }else if(folderType == "LINK"){
            let storyBoard = UIStoryboard(name: "Link", bundle: nil)
            guard let linkVC = storyBoard.instantiateViewController(identifier: "linkFolderIn") as? LinkInViewController else { return }
            DispatchQueue.global().async {
                FolderService.shared.viewFolder(folderId: folderId, completion: { (response) in
                    Thread.sleep(forTimeInterval: 2)
                    linkVC.folderId = folderId
                    linkVC.total = response
                    //print("total isss \(response)")
                    linkVC.getData()
                }, errorHandler: { (error) in })
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(linkVC, animated: true)
                }
                
            }
        }
       
    }
    
    
    
    
    //for cell info and sort
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath)
            
            //뷰에 있는 ui label들 지우고 다시 그리기
            let allLabels = headerView.get(all: UILabel.self)
              for sub in allLabels {
                sub.removeFromSuperview()
             }
            
            let folderCount = UILabel()
            folderCount.text = "\(filteredFolder.count)개의 폴더"
            folderCount.textColor = UIColor.darkGray
            headerView.addSubview(folderCount)
            folderCount.frame = CGRect(x: 10, y: 10, width: 100, height: 30)
            
          
            
            let sortingButton = UIButton()
            let sortingButtonTextAttributes: [NSAttributedString.Key: Any] = [.backgroundColor: UIColor.green, NSAttributedString.Key.kern: 10]
            let sortingButtonText = NSMutableAttributedString(string: "\(sortingText)", attributes: sortingButtonTextAttributes)
            sortingButton.setTitle(sortingButtonText.string, for: .normal)
            sortingButton.setTitleColor(UIColor.gray, for: .normal)
            headerView.addSubview(sortingButton)
            sortingButton.frame = CGRect(x: headerView.frame.maxX - 100, y: 10, width: 100, height: 30)
            sortingButton.addTarget(self, action: #selector(didTapSortingButton), for: .touchUpInside)
            
            return headerView
        default: assert(false, "nothing")
            
        }
        return UICollectionReusableView()
        
    }
    
    
    @objc func didTapSortingButton(){
        print("did Tap sorting button")
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
        return sorting.count
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
        if(indexPath.row == 0){ // 가나다순 -> 폴더 이름별
            sortingAlpanumeric()
        }else if(indexPath.row == 1){ // 생성순 -> 폴더 생성순 (만든지 오래된 순)
            sortingOldest()
        }else if(indexPath.row == 2){ // 최신순 -> 생성순 반대로
            sortingLatest()
        }
        sortingText = sorting[indexPath.row]
        self.dismissAlertController()
        folderCollectionView.reloadData() // for 글자 업데이트
        folderCollectionView.collectionViewLayout.invalidateLayout()
        
    }
    
    
    
 
    
    //sorting
    func sortingAlpanumeric(){
        mainViewModels = mainViewModels.sorted {$0.folderName.localizedStandardCompare($1.folderName) == .orderedAscending}
        filteredFolder = mainViewModels
        folderCollectionView.reloadData()
    }
    
    func sortingOldest(){
        mainViewModels = mainViewModels.sorted { $0.folderId < $1.folderId }
        filteredFolder = mainViewModels
        folderCollectionView.reloadData()
    }
    
    func sortingLatest(){
        mainViewModels = mainViewModels.sorted { $0.folderId > $1.folderId }
        filteredFolder = mainViewModels
        folderCollectionView.reloadData()
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
            filteredFolder = mainViewModels.filter({ (result) -> Bool in
                result.folderName.range(of: searchText, options: .caseInsensitive) != nil
            })
        }else {
            filteredFolder = mainViewModels
        }
       
        folderCollectionView.reloadData()
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        self.filteredFolder.removeAll()
        for i in mainViewModels {
            filteredFolder.append(i)
        }
        folderCollectionView.reloadData()
        return false
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.count != 0 {
            self.filteredFolder.removeAll()
            for i in mainViewModels {
                let name = i.folderName.lowercased()
                let range = name.range(of: textField.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil {
                    self.filteredFolder.append(i)
                }
                
            }
        }
        
        folderCollectionView.reloadData()
        textField.resignFirstResponder()
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        self.view.endEditing(true)
        return true
    }
}


class CollectionViewLeftAlignFlowLayout: UICollectionViewFlowLayout {
    let cellSpacing: CGFloat = 10
 
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        self.minimumLineSpacing = 10.0
        self.sectionInset = UIEdgeInsets(top: 12.0, left: 16.0, bottom: 0.0, right: 16.0)
        let attributes = super.layoutAttributesForElements(in: rect)
 
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + cellSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        return attributes
    }
}





