//
//  LinkViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/05/10.
//

import UIKit
import DropDown
import PhotosUI
import NVActivityIndicatorView

class LinkViewController: UIViewController, FolderCollectionViewCellDelegate {

    
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    private var mainViewModels = [FolderViewModel]()

    let indicator = NVActivityIndicatorView(frame: CGRect(x: 162, y: 100, width: 50, height: 50),
                                            type: .circleStrokeSpin,
                                            color: .black,
                                            padding: 0)
    
    var link = [GetByFolderResponse]()
    var filteredLink = [FolderViewModel]()
    
    var configuration = PHPickerConfiguration()
    
    func didTapMoreButton(cell: FolderCollectionViewCell) {
        more_dropDown.anchorView = cell.moreButton
        more_dropDown.show()
        selectedCellIndexPath = cell.indexPath
        print(selectedCellIndexPath)
        more_dropDown.backgroundColor = UIColor.white
        more_dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("선택한 아이템 : \(item)")
            print("인덱스 : \(index)")
            let folderId = filteredLink[cell.indexPath.row].folderId
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
    
    @IBOutlet weak var searchTextField: UITextField!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var floatingButton: UIButton!
    
    private var alertController = UIAlertController()
    private var tblView = UITableView()
    
    
    var sorting = ["이름 순", "생성 순", "최신 순"]
    var sortingText = "이름 순"
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
    
    let refreshControl = UIRefreshControl()
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchData()
    }
    
    func fetchData(){
        indicator.startAnimating()
        FolderService.shared.getLinkFolder(completion: { (response) in
            self.link = response
            self.mainViewModels = self.link.map ({ return FolderViewModel(allFolder: GetFolderResponse(folderId: $0.folderId, folderName: $0.folderName, userId: $0.userId, imageData: $0.imageData ?? Data(), type: "LINK"))})
            self.filteredLink = self.mainViewModels
            self.collectionView.reloadData()
        }, errorHandler: {(errorMessage) in
            if(errorMessage == 403){
                self.alertViewController(title: "로그인 실패", message: "로그인 화면으로 이동합니다.", completion: { (response) in
                    if(response == "OK"){
                        UserDefaults.standard.setValue("0", forKey: UserDefaultKey.isNewUser)
                        UserLoginServices.shared.autoLogin()
                    }
                })
            }
        })
        indicator.stopAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        indicator.frame = CGRect(x: screenWidth/2, y: screenHeight/2, width: 50, height: 50)
        view.addSubview(indicator)
        textFieldSetting(textField: searchTextField)
        collectionViewSetting()
        floatingButtonSetting(button: floatingButton)

        NotificationCenter.default.addObserver(self, selector: #selector(self.folderImageChangedInLink(_:)), name: .folderImageChangedInLink, object: nil)
        flowSetting()
        refreshing()
    }
    
    func refreshing(){
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        refreshControl.beginRefreshing()
        collectionView.addSubview(refreshControl)
        
    }
    
    @objc func refresh(_ sender: AnyObject) {
        fetchData()
        refreshControl.endRefreshing()
    }
    
    func flowSetting(){
        collectionView.collectionViewLayout = collectionViewLayout
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 10)
 
        collectionViewLayout.itemSize = CGSize(width: screenWidth / 2, height: screenWidth / 2)
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.minimumLineSpacing = 0
        
    }

    
    func textFieldSetting(textField: UITextField){
        textField.delegate = self
        textField.circle()
    }
    
    func collectionViewSetting(){
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(FolderCollectionViewCell.nib(), forCellWithReuseIdentifier: FolderCollectionViewCell.identifier)
        collectionView.allowsSelection = true
        collectionView.isUserInteractionEnabled = true
    }
    
    
    func floatingButtonSetting(button: UIButton){
        // TO DO make circle
        floatingButton.addTarget(self, action: #selector(makeFolder), for: .touchUpInside)
        floatingButton.circle()
    }
    
    //폴더 이미지 변경
    @objc func folderImageChangedInLink(_ notification: NSNotification){
        if let dict = notification.userInfo as NSDictionary? {
            if let folderImage = dict["image"] as? UIImage {
                let folderId = filteredLink[selectedCellIndexPath[1]].folderId
                print("folderId \(folderId)")
                FolderService.shared.changeFolderImage(folderId: folderId, changeImage: folderImage.jpeg(.lowest)!, completion: { (response) in
                    if(response == true){
                        self.fetchData()
                        self.alertViewController(title: "이미지 변경", message: "이미지가 변경되었습니다", completion: { (response) in})
                    }
                }, errorHandler: { (error) in })
            }
        }
    }
    
    func folderDelete(cell: FolderCollectionViewCell){
        
        let index = cell.indexPath.row
        print("folderID : \(index)")
        FolderService.shared.deleteFolder(folderId: filteredLink[index].folderId, errorHandler: { (error) in})
        filteredLink.remove(at: index)
        self.alertViewController(title: "삭제 완료", message: "폴더를 삭제하였습니다", completion: { (response) in
            if(response == "OK"){
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
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

    
    @objc func makeFolder(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let makeFolderView = storyBoard.instantiateViewController(identifier: "makeFolderAlertView") as! makeFolderAlertView
        makeFolderAlertView.type_dropDown.dataSource = ["링크"]
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(makeFolderView, animated: true)
    }
    

}

extension LinkViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredLink.count
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

        let folderViewModel = filteredLink[indexPath.row]
        cell.folderViewModel = folderViewModel
        //cell.configure(folder: filteredFolder[indexPath.row])
        cell.indexPath = indexPath
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let width  = (view.frame.width-20)/3
//        print("linkVC width \(width)")
//        return CGSize(width: width, height: width)
//    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if let flowLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.invalidateLayout()
        }
    }
    
    //위 아래 라인 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
//    //옆 라인 간격
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0.2
//    }
    
    //todo - make with navigation
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let linkVC = self.storyboard?.instantiateViewController(identifier: "linkFolderIn") as? LinkInViewController else { return }
        let folderId = filteredLink[indexPath.row].folderId
        DispatchQueue.global().async {
            FolderService.shared.viewFolder(folderId: folderId, completion: { (response) in
                Thread.sleep(forTimeInterval: 2)
                linkVC.folderId = folderId
                linkVC.total = response
                linkVC.folderName = self.filteredLink[indexPath.row].folderName
                linkVC.getData()
            }, errorHandler: { (error) in })
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(linkVC, animated: true)
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
            folderCount.text = "\(link.count)개의 폴더"
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

extension LinkViewController: UITableViewDelegate, UITableViewDataSource {
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
        if(indexPath.row == 0){
            sortingAlpanumeric()
        }else if(indexPath.row == 1){
            sortingOldest()
        }else if(indexPath.row == 2){
            sortingOldest()
        }
        sortingText = sorting[indexPath.row]
        self.dismissAlertController()

        collectionView.reloadData() // for 글자 업데이트
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    
    //sorting
    func sortingAlpanumeric(){
        mainViewModels = mainViewModels.sorted {$0.folderName.localizedStandardCompare($1.folderName) == .orderedAscending}
        filteredLink = mainViewModels
        
        collectionView.reloadData()
        
       
    }
    
    func sortingOldest(){
        mainViewModels = mainViewModels.sorted { $0.folderId < $1.folderId }
        filteredLink = mainViewModels

        collectionView.reloadData()

    }
    
    func sortingLatest(){
        mainViewModels = mainViewModels.sorted { $0.folderId > $1.folderId }
        filteredLink = mainViewModels

        collectionView.reloadData()
    }
    
}


extension LinkViewController: UITextFieldDelegate {
   
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let text = textField.text else {return}
        print("text \(text)")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = textField.text! + string
        if searchText.count >= 2{
            filteredLink = mainViewModels.filter({ (result) -> Bool in
                result.folderName.range(of: searchText, options: .caseInsensitive) != nil
            })
        }else {
            filteredLink = mainViewModels
        }
       
        collectionView.reloadData()
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        self.filteredLink.removeAll()
        for i in mainViewModels {
            filteredLink.append(i)
        }
        collectionView.reloadData()
        return false
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.count != 0 {
            self.filteredLink.removeAll()
            for i in mainViewModels {
                let name = i.folderName.lowercased()
                let range = name.range(of: textField.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil {
                    self.filteredLink.append(i)
                }
                
            }
        }
        
        collectionView.reloadData()
        textField.resignFirstResponder()
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

extension LinkViewController: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let image = image as? UIImage {
                    NotificationCenter.default.post(name: .folderImageChangedInLink, object: nil, userInfo: ["image" : image])


                }
        }
            
        } else { // TODO: Handle empty results or item providernot being able load UIImage
            print("can't load image")
            
        }

    }
    
    
}

