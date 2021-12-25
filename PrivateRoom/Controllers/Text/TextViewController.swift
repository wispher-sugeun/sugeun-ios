//
//  TextViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/05/10.
//

import UIKit
import DropDown
import PhotosUI
import NVActivityIndicatorView
import Combine

class TextViewController: UIViewController, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    let refreshControl = UIRefreshControl()
    
    let indicator = NVActivityIndicatorView(frame: CGRect(x: 162, y: 100, width: 50, height: 50),
                                            type: .circleStrokeSpin,
                                            color: #colorLiteral(red: 0.5568627451, green: 0.6392156863, blue: 0.8, alpha: 1),
                                            padding: 0)
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let image = image as? UIImage {
                    NotificationCenter.default.post(name: .folderImageChangedInPhrase, object: nil, userInfo: ["image" : image])


                }
        }
            
        } else { // TODO: Handle empty results or item providernot being able load UIImage
            print("can't load image")
            
        }
    }
    

    
    var configuration = PHPickerConfiguration()
    
    @IBOutlet weak var floatingButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var mainViewModel = [FolderViewModel]()
    var textFolder = [GetByFolderResponse]()
    var filteredTextFolder = [FolderViewModel]()
    var sortingText = "이름 순"
    var sorting = ["이름 순", "생성 순", "최신 순"]
    
    var selectedCellIndexPath = IndexPath()
    
    
    private var alertController = UIAlertController()
    private var tblView = UITableView()
    
    private var folderNameTextField: UITextField = {
        var textfield = UITextField()
        return textfield
    }()
    
    let more_dropDown: DropDown = {
        let dropDown = DropDown()
        dropDown.width = 100
        dropDown.dataSource = ["이름 변경", "이미지 변경", "폴더 삭제"] //TODO : how dataSource 2 make red?
        return dropDown
    }()
    
    let subject = PassthroughSubject<String, Never>()
    var bag = Set<AnyCancellable>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.folderImageChangedInPhrase(_:)), name: .folderImageChangedInPhrase, object: nil)
    }
    
    func fetchData(){
        indicator.startAnimating()
        FolderService.shared.getPhraseFolder(completion: { (response) in
            self.textFolder = response
            self.mainViewModel = self.textFolder.map( { FolderViewModel(allFolder: GetFolderResponse(folderId: $0.folderId, folderName: $0.folderName, userId: $0.userId, imageData: $0.imageData ?? Data(), type: "PHRASE"))})
            self.filteredTextFolder = self.mainViewModel
            self.collectionView.reloadData()
        }, errorHandler: { (error) in})
        indicator.stopAnimating()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        indicator.frame = CGRect(x: screenWidth / 2, y: screenHeight / 2, width: 50, height: 50)
        indicator.center = self.view.center
        view.addSubview(indicator)
        buttonSetting(button: floatingButton)
        textFieldSetting(textField: searchTextField)
        collectionViewSetting()
        
        flowSetting()
        refreshing()
        
        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        dismissKeyboardGesture.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(dismissKeyboardGesture)
      
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    func refreshing(){
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        refreshControl.beginRefreshing()
        collectionView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        print("refresh")
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
    
    func presentPicker(){
        configuration.filter = .any(of: [.images])
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    
    
    //폴더 이미지 변경
    @objc func folderImageChangedInPhrase(_ notification: NSNotification){
        //text ~~
        print(notification.userInfo ?? "")
        
        if let dict = notification.userInfo as NSDictionary? {
            if let folderImage = dict["image"] as? UIImage {
                let folderId = filteredTextFolder[selectedCellIndexPath[1]].folderId
                FolderService.shared.changeFolderImage(folderId: folderId, changeImage: folderImage.jpeg(.lowest)!, completion: { (response) in
                    if(response == true){
                        self.fetchData()
                        self.alertViewController(title: "이미지 변경", message: "이미지가 변경되었습니다", completion: { (response) in})
                    }
                }, errorHandler: { (error) in})
            }
        }
        
    }
    
    func folderDelete(cell: FolderCollectionViewCell){
        
        let index = cell.indexPath.row
        print("folderID : \(index)")
        FolderService.shared.deleteFolder(folderId: filteredTextFolder[index].folderId, errorHandler: { (error) in})
        filteredTextFolder.remove(at: index)
        self.alertViewController(title: "삭제 완료", message: "폴더를 삭제하였습니다", completion: { (response) in
            if(response == "OK"){
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        })
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
    
    func buttonSetting(button: UIButton){
        button.circle()
        button.addTarget(self, action: #selector(didTapFloatingButton), for: .touchUpInside)
    }
    
    @objc func didTapFloatingButton(){
        let makeFolderView = self.storyboard?.instantiateViewController(identifier: "makeFolderAlertView") as! makeFolderAlertView
        
        
        makeFolderAlertView.type_dropDown.dataSource = ["텍스트"]
        
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.pushViewController(makeFolderView, animated: true)
//        makeFolderView.modalPresentationStyle = .overCurrentContext
//        self.present(makeFolderView, animated: true, completion: nil)
    }
    
    func textFieldSetting(textField: UITextField){
        textField.delegate = self
        textField.circle()
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0));
        textField.leftViewMode = .always
        
    }
    
    func collectionViewSetting(){
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(FolderCollectionViewCell.nib(), forCellWithReuseIdentifier: FolderCollectionViewCell.identifier)
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
        
      
            if UIDevice.current.userInterfaceIdiom == .pad { //디바이스 타입이 iPad일때
                if let popoverController = alertController.popoverPresentationController {
              
                    popoverController.sourceView = self.view
                    popoverController.sourceRect = CGRect(x: 0.0, y: view.frame.height, width: view.frame.width, height: 250.0)
                    popoverController.permittedArrowDirections = []
                    self.present(alertController, animated: true) { [self] in
                            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
                        alertController.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
                    }
                    
                }
            
            } else {
            self.present(alertController, animated: true) { [self] in
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            alertController.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
            }
        }
        
    }

    
    @objc func dismissAlertController()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    


}

extension TextViewController: UITableViewDelegate, UITableViewDataSource {
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
            sortingLatest()
        }
        
        sortingText = sorting[indexPath.row]
        self.dismissAlertController()
        collectionView.reloadData() // for 글자 업데이트
        collectionView.collectionViewLayout.invalidateLayout()
        
    }
    
    
    //sorting
    func sortingAlpanumeric(){
        mainViewModel = mainViewModel.sorted {$0.folderName.localizedStandardCompare($1.folderName) == .orderedAscending}
        filteredTextFolder = mainViewModel
        collectionView.reloadData()
    }
    
    func sortingOldest(){
        mainViewModel = mainViewModel.sorted { $0.folderId < $1.folderId }
        filteredTextFolder = mainViewModel
        collectionView.reloadData()
    }
    
    func sortingLatest(){
        mainViewModel = mainViewModel.sorted { $0.folderId > $1.folderId }
        filteredTextFolder = mainViewModel
        collectionView.reloadData()
    }
    
    
}


extension TextViewController: UITextFieldDelegate, UIGestureRecognizerDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let text = textField.text else {return}
        print("text \(text)")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let subscribe = subject.sink(receiveValue: { value in
            if(value.count >= 1){
                self.filteredTextFolder = self.mainViewModel.filter({ (result) -> Bool in
                    result.folderName.range(of: value, options: .caseInsensitive) != nil
                })
            }else {
                self.filteredTextFolder = self.mainViewModel
            }
            self.collectionView.reloadData()
        })

        guard let text = textField.text as NSString? else {return false}
        let searchText = text.replacingCharacters(in: range, with: string)

        subject.send(searchText)
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        self.filteredTextFolder.removeAll()
        for str in mainViewModel {
            filteredTextFolder.append(str)
        }
        collectionView.reloadData()
        return false
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.count != 0 {
            self.filteredTextFolder.removeAll()
            for str in mainViewModel {
                let name = str.folderName.lowercased()
                let range = name.range(of: textField.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil {
                    self.filteredTextFolder.append(str)
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

extension TextViewController: UICollectionViewDataSource, UICollectionViewDelegate, FolderCollectionViewCellDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTextFolder.count
    }

    
    func didTapMoreButton(cell: FolderCollectionViewCell) {
        more_dropDown.anchorView = cell.moreButton
        more_dropDown.show()
        selectedCellIndexPath = cell.indexPath
        more_dropDown.backgroundColor = UIColor.white
        more_dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("선택한 아이템 : \(item)")
            print("인덱스 : \(index)")
            let folderId = filteredTextFolder[cell.indexPath.row].folderId
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCollectionViewCell.identifier, for: indexPath) as! FolderCollectionViewCell
        
            //cell 크기 고정
            cell.viewLayout(width: view.fs_width/2 - 30, height: view.fs_width/2 - 30)
            cell.cellDelegate = self
            cell.view.layer.borderColor = UIColor.darkGray.cgColor
            cell.view.layer.masksToBounds = true
            cell.view.layer.cornerRadius = 5
            cell.view.layer.borderWidth = 1
            cell.view.layer.shadowOpacity = 1.0

            let folderViewModel = filteredTextFolder[indexPath.row]
            cell.folderViewModel = folderViewModel
            //cell.configure(folder: filteredFolder[indexPath.row])
            cell.indexPath = indexPath
            return cell
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width  = (view.frame.width-20)/3
//                    return CGSize(width: width, height: width)
//    }
    
    //위 아래 라인 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if let flowLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.invalidateLayout()
        }
    }
    
    
    //옆 라인 간격
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0.2
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
            let folderCount = UILabel()
            folderCount.text = "\(textFolder.count)개의 폴더"
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
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let textInVC = self.storyboard?.instantiateViewController(identifier: "textIn") as? TextInViewController else { return }
        let folderId = filteredTextFolder[indexPath.row].folderId
        DispatchQueue.global().async {
            FolderService.shared.viewFolder(folderId: folderId, completion: { (response) in
                textInVC.total = response
                textInVC.folderName = self.filteredTextFolder[indexPath.row].folderName
                textInVC.folderId = folderId
                print("folder name \(textInVC.folderName)")
                
                textInVC.getData()
            }, errorHandler: { (error) in})
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(textInVC, animated: true)
            }
        }
        
        
    }

}

