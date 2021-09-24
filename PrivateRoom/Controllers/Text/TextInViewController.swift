//
//  TextInViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/22.
//

import UIKit
import DropDown
import PhotosUI


class TextInViewController: UIViewController, FolderCollectionViewCellDelegate {
    
    var folderId: Int = 0;
    
    var folderName: String = ""
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var selectedCellIndexPath = IndexPath()
    
    let cellSpacingHeight: CGFloat = 20
    
    let refreshControl = UIRefreshControl()

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        tableViewHeight.constant = self.frameTableView.contentSize.height + 100
     
        frameTableView.reloadData()
        
        if(textFolder.isEmpty && textCell.isEmpty){ // data가 없을때 footerview 없애기
            print("data no")
            frameTableView.tableFooterView = nil
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width:frameTableView.bounds.size.width, height: frameTableView.bounds.size.height))
            noDataLabel.text          = "폴더 안에 데이터가 아직 존재하지 않습니다"
            noDataLabel.textColor     = UIColor.systemGray2
            noDataLabel.textAlignment = .center
            frameTableView.backgroundView  = noDataLabel
            frameTableView.separatorStyle  = .none
        }else {
            frameTableView.tableFooterView?.isHidden = false
            frameTableView.tableFooterView?.backgroundColor = .white
            frameTableView.tableFooterView?.frame.size.height = collectionView.contentSize.height + 80
        }
        
    }
    func didTapMoreButton(cell: FolderCollectionViewCell) {
        more_dropDown.anchorView = cell.moreButton
        more_dropDown.show()
        selectedCellIndexPath = cell.indexPath
        more_dropDown.backgroundColor = UIColor.white
        more_dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            
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

  
    var total: DetailFolderResponse? //folderid로 조회된 친구들
    
    var textCell = [PhraseResDTO]()
    var filteredTextCell = [PhraseResDTO]()
    
    var textFolder = [GetByFolderResponse]()
    var filteredTextFolder = [FolderViewModel]()
    var mainViewModel = [FolderViewModel]()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ButtonStackView: UIStackView!
    @IBOutlet weak var floatingButton: UIButton!
    
    @IBOutlet weak var folderButton: UIButton!
    
    @IBOutlet weak var writeButton: UIButton!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var frameTableView: UITableView!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var header: UIView!
    
    @IBOutlet weak var footer: UIView!
    
    private var tblView = UITableView()
    
    private var alertController = UIAlertController()
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

    
    var sorting = ["이름 순", "생성 순", "최신 순"]
    var sortingText = "이름 순"
    var buttons: [UIButton] = []
    
    
    var isShowFloating: Bool = false
    
    let textCell_dropDown: DropDown = {
        let dropDown = DropDown()
        dropDown.width = 100
        dropDown.dataSource = ["글 수정", "글 삭제"]
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
    //var cellHeight: CGFloat = 0.0
    
    override func viewWillAppear(_ animated: Bool) {
        isShowFloating = false
        hideButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navItem.title = folderName
        print(folderName)
        buttonSetting()
        textFieldSetting(textField: searchTextField)
        tapGestureSetting()
        tableviewSetting()
        collectionViewSetting()
        sortingButtonSetting()

        getData()
        refreshing()
 
    }
    
    func refreshing(){
        //refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        collectionView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    @objc func refresh(_ sender: AnyObject) {
        getData()
        refreshControl.endRefreshing()
    }
    
    func getData(){
        //total 값 folderdhk textCell에게 분기
        if((((total?.folderResDTOList!.isEmpty) != nil))) {
            textFolder = total.map { $0.folderResDTOList}!!
            self.mainViewModel = textFolder.map { return FolderViewModel(allFolder: GetFolderResponse(folderId: $0.folderId, folderName: $0.folderName, userId: $0.userId, imageData: $0.imageData ?? Data(), type: "PHRASE")) }
            self.filteredTextFolder = self.mainViewModel
            self.collectionView.reloadData()
        }
        
        if((((total?.phraseResDTOList!.isEmpty) != nil))) {
            textCell = total.map { $0.phraseResDTOList }!!
            filteredTextCell = textCell
            self.frameTableView.reloadData()
        }
    }
    
    func fetchData(folderId: Int){
        FolderService.shared.viewFolder(folderId: folderId, completion: { (response) in
            //print(response)
            self.textFolder = response.folderResDTOList!
            self.textCell = response.phraseResDTOList!
            self.mainViewModel = self.textFolder.map { return FolderViewModel(allFolder: GetFolderResponse(folderId: $0.folderId, folderName: $0.folderName, userId: $0.userId, imageData: $0.imageData ?? Data(), type: "PHRASE")) }
            self.filteredTextFolder = self.mainViewModel
            self.filteredTextCell = self.textCell
        }, errorHandler: { (response) in})
    }
    
    func tapGestureSetting(){
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyTapMethod))

        singleTapGestureRecognizer.numberOfTapsRequired = 1

        singleTapGestureRecognizer.isEnabled = true

        singleTapGestureRecognizer.cancelsTouchesInView = false

        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
    }
    
    func tableviewSetting(){
        frameTableView.delegate = self
        frameTableView.dataSource = self
        frameTableView.allowsSelection = false
        frameTableView.separatorStyle = .none
        frameTableView.backgroundColor = .white
        //처음에 없을 데이터를 위해 비활성화하기
        frameTableView.tableFooterView?.isHidden = true
        frameTableView.register(TextCellTableViewCell.nib(), forCellReuseIdentifier: TextCellTableViewCell.identifier)
        self.frameTableView.translatesAutoresizingMaskIntoConstraints = false
        frameTableView.backgroundView = UIView()
        self.frameTableView.estimatedRowHeight = 80
//        self.frameTableView.contentInset = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: -15)
        self.frameTableView.rowHeight = UITableView.automaticDimension


    }
    
    func collectionViewSetting(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = CollectionViewLeftAlignFlowLayout()
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                    flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
                  }
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(FolderCollectionViewCell.nib(), forCellWithReuseIdentifier: FolderCollectionViewCell.identifier)
    }
    
    func sortingButtonSetting(){
        let sortingButton = UIButton()
        let sortingButtonTextAttributes: [NSAttributedString.Key: Any] = [.backgroundColor: UIColor.green, NSAttributedString.Key.kern: 10]
        let allLabels = header.get(all: UIButton.self)
          for sub in allLabels {
            sub.removeFromSuperview()
         }
        let sortingButtonText = NSMutableAttributedString(string: "\(sortingText)", attributes: sortingButtonTextAttributes)
        sortingButton.setTitle(sortingButtonText.string, for: .normal)
        sortingButton.setTitleColor(UIColor.gray, for: .normal)
        header.addSubview(sortingButton)
        sortingButton.frame = CGRect(x: header.frame.maxX - 120, y: 10, width: 100, height: 30)
    
        
        sortingButton.addTarget(self, action: #selector(didTapSortingButton), for: .touchUpInside)
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
    
    
    
    func buttonSetting(){
        buttons = [folderButton, writeButton]
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
            hideButton()
            isShowFloating = false
        }
    }
    
    @objc func didTapWriteButton(){
        let writeVc = self.storyboard?.instantiateViewController(identifier: "writeText") as! WriteViewController
        //print("write folderId \(folderId)")
        writeVc.folderId = folderId // folderId 같이 전달
        self.navigationController?.pushViewController(writeVc, animated: true)
    }
    
    @objc func didTapMakeFolder(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let makeFolderView = storyBoard.instantiateViewController(identifier: "makeFolderAlertView") as! makeFolderAlertView
        makeFolderAlertView.type_dropDown.dataSource = ["텍스트"]
        //print("makefolder folderId \(folderId)")
        makeFolderView.parentFolderId = folderId
        self.navigationController?.pushViewController(makeFolderView, animated: true)
//        makeFolderView.modalPresentationStyle = .overCurrentContext
//        self.present(makeFolderView, animated: true, completion: nil)
    }
    
    func textFieldSetting(textField: UITextField){
        textField.delegate = self
        textField.circle()
    }
    
    
    @IBAction func floatingButtonAction(_ sender: UIButton) {
            sender.circle()
            if isShowFloating {
                //print("hide")
                hideButton()
            } else {
                //print("showButton")
               showButton()
            }
            isShowFloating = !isShowFloating
    }
    
    func hideButton(){
        buttons.reversed().forEach { button in
            UIView.animate(withDuration: 0.3) {
                button.isHidden = true
            }
        }
    }
    
    func showButton(){
        buttons.forEach { button in
            
            button.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.writeButton.isHidden = false
                self.folderButton.isHidden = false
                button.alpha = 1
                //print(button)
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
    
    
    func image( _ image:UIImage, withSize newSize:CGSize) -> UIImage {

        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0,y: 0,width: newSize.width,height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(.automatic)
    }
    
    
//    @objc func folderImageChanged(_ notification: NSNotification){
//        //text ~~
//        print(notification.userInfo ?? "")
//        print("folderImageChanged")
//        if let dict = notification.userInfo as NSDictionary? {
//            if let folderImage = dict["image"] as? UIImage{
////                filteredTextFolder[selectedCellIndexPath[1]].folderImage = image( UIImage(systemName: "heart.fill")!, withSize: CGSize(width: 100, height: 80))
//                    
//                DispatchQueue.main.async {
//                    self.collectionView.reloadData()
//                }
//                
//                // do something with your image
//            }
//        }
//        
//    }
    

    


}

extension TextInViewController: UITableViewDelegate, UITableViewDataSource, TextCellTableViewCellDelegate {
    
    func moreButton(cell: TextCellTableViewCell) {
        textCell_dropDown.anchorView = cell.moreButton
        textCell_dropDown.show()

        textCell_dropDown.backgroundColor = UIColor.white
        textCell_dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("선택한 아이템 : \(item)")
            print("인덱스 : \(index)")
            
            if(index == 0){ // 글 수정
                textCellEdit(cell: cell)
            }else if(index == 1){ // 글 삭제
                self.alertWithNoViewController(title: "글 삭제", message: "이 글을 삭제하시겠습니까?", completion: {
                    (response) in
                    if(response == "OK"){
                        textCellDelete(indexPath: cell.indexPath)
                    }
                })
            }
        }
        textCell_dropDown.clearSelection()
        
    }
    
    func bookMark(cell: TextCellTableViewCell) {
        let index = cell.indexPath.section
        print("bookMark 수정 \(index)")
        let phraseId = filteredTextCell[index].phraseId
        PhraseService.shared.phraseBookMark(phraseId: phraseId)
    }
    
    func textCellEdit(cell: TextCellTableViewCell){
        let editText = cell.labelText.text
        let writeVc = self.storyboard?.instantiateViewController(identifier: "writeText") as! WriteViewController
        writeVc.phraseId = filteredTextCell[cell.indexPath.section].phraseId
        writeVc.folderId = folderId
        writeVc.editText = editText!
        writeVc.editMode = true
        
        self.navigationController?.pushViewController(writeVc, animated: true)

    }
    
    func textCellDelete(indexPath: IndexPath){
        let phraseId = filteredTextCell[indexPath.row].phraseId
        textCell.remove(at: indexPath.section)
        print(indexPath.section)
        filteredTextCell = textCell
        self.alertViewController(title: "삭제 완료", message: "삭제 완료하였습니다.", completion: { (response) in
            if( response == "OK"){
                PhraseService.shared.deletePhrase(folderId: self.folderId, phraseId: phraseId)
                self.frameTableView.reloadData()
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(tableView == frameTableView){
            print("filteredTextCell.count \(filteredTextCell.count)")
            return filteredTextCell.count
        }else if(tableView == tblView){
            return sorting.count
        }
        return 1
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let defaultCell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if(tableView == tblView){
            let cell = tblView.dequeueReusableCell(withIdentifier: "sortingCell")!
            let nsHeaderTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.light),
                                          NSAttributedString.Key.foregroundColor: UIColor.black]
            
            let nsSortingText = NSAttributedString(string: sorting[indexPath.section], attributes: nsHeaderTextAttributes)
            
            cell.textLabel?.attributedText = nsSortingText
            return cell
        }
        
       
        if tableView == frameTableView {
            if(!filteredTextCell.isEmpty){
                let cell = tableView.dequeueReusableCell(withIdentifier: TextCellTableViewCell.identifier, for: indexPath) as! TextCellTableViewCell
                cell.configure(model: filteredTextCell[indexPath.section])
                cell.indexPath = indexPath
                print(cell.indexPath)
                cell.delegate = self
                return cell
            }
        }
        
        return defaultCell!
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(tableView == tblView){
            return CGFloat(50)
        }
        else if (tableView == tableView){
            return UITableView.automaticDimension
            
        }
        return 50
      
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //sorting
        if(tableView == tblView){
            if(indexPath.row == 0){
                sortingAlpanumeric()
            }else if(indexPath.row == 1){
                sortingOldest()
            }else if(indexPath.row == 2){
                sortingLatest()
            }
            sortingText = sorting[indexPath.row]
            sortingButtonSetting()
            self.dismissAlertController()
            frameTableView.reloadData() // for 글자 업데이트
            frameTableView.layoutIfNeeded()
        }else{
            tableView.deselectRow(at: indexPath, animated: false)
        }
       
    }
    
    
    //sorting
    func sortingAlpanumeric(){
        textCell = textCell.sorted {$0.text.localizedStandardCompare($1.text) == .orderedAscending}
        filteredTextCell = textCell
        
        mainViewModel = mainViewModel.sorted {$0.folderName.localizedStandardCompare($1.folderName) == .orderedAscending}
        filteredTextFolder = mainViewModel
        frameTableView.reloadData()
        collectionView.reloadData()
    }
    
    func sortingOldest(){
        textCell = textCell.sorted { $0.phraseId < $1.phraseId }
        filteredTextCell = textCell
        
        mainViewModel = mainViewModel.sorted { $0.folderId < $1.folderId }
        filteredTextFolder = mainViewModel
        
        frameTableView.reloadData()
        collectionView.reloadData()
    }
    
    func sortingLatest(){
        textCell = textCell.sorted { $0.phraseId > $1.phraseId }
        filteredTextCell = textCell
        
        mainViewModel = mainViewModel.sorted { $0.folderId > $1.folderId }
        filteredTextFolder = mainViewModel
        
        frameTableView.reloadData()
        collectionView.reloadData()
    }
    
}

extension TextInViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTextFolder.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCollectionViewCell.identifier, for: indexPath) as! FolderCollectionViewCell
        //cell 크기 고정
        cell.viewLayout(width: view.fs_width/2 - 30, height: CGFloat(170))
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
    
    //go to text in self
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let textInVC = self.storyboard?.instantiateViewController(identifier: "textIn") as? TextInViewController else { return }
        let folderId = filteredTextFolder[indexPath.row].folderId
        DispatchQueue.global().async {
            FolderService.shared.viewFolder(folderId: folderId, completion: { (response) in
                //print("response \(response)")
                textInVC.total = response
                textInVC.folderName = self.filteredTextFolder[indexPath.row].folderName
                textInVC.folderId = folderId
                self.hideButton()
                textInVC.getData()
            }, errorHandler: { (error) in})
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(textInVC, animated: true)
            }
        }
        
//  폴더 안 -> 폴더 안으로 연결 되지 못함
//        let index = filteredTextFolder[indexPath.row]
//
//        guard let textVC = self.storyboard?.instantiateViewController(identifier: "textIn") as? TextInViewController else { return }
//        FolderService.shared.viewFolder(folderId: index.folderId, completion: { (response) in
//            print("response \(response)")
//            textVC.total = response
//            textVC.folderId = index.folderId
//            textVC.fetchData(folderId: index.folderId)
//            self.hideButton()
//        }, errorHandler: { (error) in})
//        self.navigationController?.pushViewController(textVC, animated: true)
 
    }
    
    
}


extension TextInViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField.text != nil else {return}
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = textField.text! + string
        if searchText.count >= 2{
            filteredTextFolder = mainViewModel.filter({ (result) -> Bool in
                result.folderName.range(of: searchText, options: .caseInsensitive) != nil
            })
            
            filteredTextCell = textCell.filter({ (result) -> Bool in
                result.text.range(of: searchText, options: .caseInsensitive) != nil
            })
        }else {
            filteredTextFolder = mainViewModel
            filteredTextCell = textCell
        }
        
        frameTableView.reloadData()
        collectionView.reloadData()
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        self.filteredTextCell.removeAll()
        self.filteredTextFolder.removeAll()
        for str in textCell {
            filteredTextCell.append(str)
        }
        for str in mainViewModel {
            filteredTextFolder.append(str)
        }
        
        frameTableView.reloadData()
        collectionView.reloadData()
        return false
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.count != 0 {
            self.filteredTextFolder.removeAll()
            self.filteredTextCell.removeAll()
            
            for str in mainViewModel {
                let name = str.folderName.lowercased()
                let range = name.range(of: textField.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil {
                    self.filteredTextFolder.append(str)
                }
                
            }
            
            for str in textCell {
                let name = str.text.lowercased()
                let range = name.range(of: textField.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil {
                    self.filteredTextCell.append(str)
                }
                
            }
        }
        
        frameTableView.reloadData()
        collectionView.reloadData()
        textField.resignFirstResponder()
        return true
    }
}

extension TextInViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) {(image, error) in
                if let image = image as? UIImage {
//                    NotificationCenter.default.post(name: .folderImageChanged, object: nil, userInfo: ["image" : image])
                    let folderId = self.filteredTextFolder[self.selectedCellIndexPath[1]].folderId
                    FolderService.shared.changeFolderImage(folderId: folderId, changeImage: image.jpeg(.lowest)!, completion: { (response) in
                                        if(response == true){
                                            self.filteredTextFolder[self.selectedCellIndexPath[1]].imageData = image.jpeg(.lowest)!
                                            DispatchQueue.main.async {
                                                self.collectionView.reloadItems(at: [self.selectedCellIndexPath])
                                            }
                                            
                                            self.alertViewController(title: "이미지 변경", message: "이미지가 변경되었습니다", completion: { (response) in})
                                        }
                                    }, errorHandler: { (error) in})
                                }
                            }
        }
            else { // TODO: Handle empty results or item providernot being able load UIImage
               print("can't load image")

           }

    }
    
    
}
