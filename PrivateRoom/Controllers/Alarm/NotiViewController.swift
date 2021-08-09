//
//  NotiViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/05/10.
//

import UIKit
import DropDown
import PhotosUI

class NotiViewController: UIViewController, UIGestureRecognizerDelegate{
    

    var timeOut = [Timeout]()
    var filteredtimeOut = [Timeout]()
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    @IBOutlet weak var floatingButton: UIButton!
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var tblView = UITableView()
    
    var selectedCellIndexPath = IndexPath()
    var sorting = ["이름 순", "생성 순", "최신 순", "유효기간 순"]
    var sortingText = "이름 순"
    private var alertController = UIAlertController()
    
    
    let more_dropDown: DropDown = {
        let dropDown = DropDown()
        dropDown.width = 100
        dropDown.dataSource = ["알림 수정", "사용 완료"]
        return dropDown
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var imageArray = [UIImage]()
        imageArray.append(UIImage(named: "alarm1")!)
        imageArray.append(UIImage(named: "alarm2")!)
        imageArray.append(UIImage(named: "alarm1")!)
    
        
        timeOut.append(Timeout(userId: 1, timeoutId: 1, title: "스타벅스 자허블", timeoutImage: imageArray[0], deadLine: "2021-08-07", selectedList: [1,3], isValid: true))
        timeOut.append(Timeout(userId: 2, timeoutId: 2, title: "이디야 아이스티", timeoutImage: imageArray[1], deadLine: "2021-07-30", selectedList: [1,3,7], isValid: false))
        timeOut.append(Timeout(userId: 3, timeoutId: 3, title: "투썸 아이스박스", timeoutImage: imageArray[2], deadLine: "2021-09-10", selectedList: [1, 7], isValid: true))
        filteredtimeOut = timeOut
        
        floatingButtonSetting(floatingButton)
        collectionViewSetting(collectionView: collectionView)
        textFieldSetting(textfield: searchTextField)
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        flowSetting()
        notUsedSorting()
        collectionView.reloadData()
    }
    
    func flowSetting(){
        collectionView.collectionViewLayout = collectionViewLayout
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
 
        collectionViewLayout.itemSize = CGSize(width: screenWidth / 2, height: screenWidth / 2)
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.minimumLineSpacing = 0
        
    }
    
    func floatingButtonSetting(_: UIButton){
        floatingButton.circle()
        floatingButton.addTarget(self, action: #selector(makeFolder), for: .touchUpInside)
    }
    
    func textFieldSetting(textfield: UITextField){
        textfield.delegate = self
        textfield.circle()
    }
    
    func collectionViewSetting(collectionView: UICollectionView){
        
        //longGesture for delete timeout cell
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delegate = self
        longPressedGesture.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(longPressedGesture)
        
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(TimeOutCollectionViewCell.nib(), forCellWithReuseIdentifier: TimeOutCollectionViewCell.identifier)
        collectionView.allowsSelection = true
        collectionView.isUserInteractionEnabled = true
        
        if let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    @objc func makeFolder(){
        let makeNotiFolderView = self.storyboard?.instantiateViewController(identifier: "MakeNotiFolderViewController") as! MakeNotiFolderViewController
        makeNotiFolderView.modalPresentationStyle = .overCurrentContext
        self.present(makeNotiFolderView, animated: true, completion: nil)
    }
    
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        if (gestureRecognizer.state != .began) {
                return
            }

            let p = gestureRecognizer.location(in: collectionView)

            if let indexPath = collectionView?.indexPathForItem(at: p) {
               // if(self.timeOut[indexPath.row].isValid == false){ // isValid false인 경우에만 반응
                    self.alertWithNoViewController(title: "알림 삭제", message: "알림을 삭제 하시겠습니까?", completion: { (response) in
                        if (response == "OK") {
                            self.timeOut.remove(at: indexPath.row)
                            self.filteredtimeOut = self.timeOut
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                            self.alertViewController(title: "삭제 완료", message: "알림이 삭제 되었습니다.", completion: {(response) in })
                    }
                        
                    })
                }
            
            
           // }

    }
 
        
}

extension NotiViewController: UICollectionViewDelegate, UICollectionViewDataSource, TimeOutCollectionViewCellDelegate, UICollectionViewDelegateFlowLayout {
    
    func moreButton(cell: TimeOutCollectionViewCell) {
        more_dropDown.anchorView = cell.moreButton
        more_dropDown.show()
        selectedCellIndexPath = cell.indexPath!
        print(selectedCellIndexPath)
        more_dropDown.backgroundColor = UIColor.white
        more_dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("선택한 아이템 : \(item)")
            print("인덱스 : \(index)")
            
            if(index == 0){ // 수정 view로 이동
                    //TO DO -> update folder Name
                let makeNotiFolderView = self.storyboard?.instantiateViewController(identifier: "MakeNotiFolderViewController") as! MakeNotiFolderViewController
                makeNotiFolderView.editMode = true
                let editTimeoutCell = (cell.indexPath?[1])!
                makeNotiFolderView.timeOut = timeOut[editTimeoutCell]
                makeNotiFolderView.modalPresentationStyle = .overCurrentContext
                self.present(makeNotiFolderView, animated: true, completion: nil)

            }else if(index == 1){ // 사용 완료
                if(cell.inValidView.isHidden == true){
                    self.alertWithNoViewController(title: "사용 완료 하시겠습니까?", message: "한번 사용 완료시 다시 알림 등록을 하셔야 합니다", completion: { (response) in
                        if (response == "OK") {
                            cell.inValidView.isHidden = false
                            self.alertViewController(title: "사용 완료", message: "쿠폰 사용 완료 되었습니다.", completion: {(response) in
                                //TO DO 사용 완료 처리
//                                DispatchQueue.main.async {
//                                    (at: cell.)
//                                }
                                
                            })
                        }
                        
                    })
                    
                }else {
                    self.alertViewController(title: "실패", message: "이미 사용 완료된 알림입니다", completion: { (response) in
                        
                    })
                }
               
            }
        }
        more_dropDown.clearSelection()
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredtimeOut.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeOutCollectionViewCell.identifier, for: indexPath) as? TimeOutCollectionViewCell
        cell?.delegate = self
        cell?.configure(model: filteredtimeOut[indexPath.row])
        cell?.backgroundColor = .red
        cell?.configureHeight(with: 160)
        cell?.indexPath = indexPath
        return cell!
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
            let width = collectionView.bounds.width
            let height = collectionView.bounds.height
//        print("width : \(collectionView.bounds.width / 2.5)")
//            print("height : \(collectionView.bounds.height / 2)")
        return CGSize(width: (width / 2) - 140, height: height)
    }
    
    //위 아래 라인 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 50
    }
    
    //옆 라인 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
           return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
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
            folderCount.text = "\(filteredtimeOut.count)개의 알림"
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

    
    func notUsedSorting(){
        timeOut = timeOut.sorted(by: { $0.isValid == false && $1.isValid == true})
        filteredtimeOut = timeOut
    }
    
    @objc func didTapSortingButton(){
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

extension NotiViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let text = textField.text else {return}
        print("text \(text)")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = textField.text! + string
        if searchText.count >= 2{
            filteredtimeOut = timeOut.filter({ (result) -> Bool in
                result.title.range(of: searchText, options: .caseInsensitive) != nil
            })
        }else {
            filteredtimeOut = timeOut
        }
       
        collectionView.reloadData()
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        self.filteredtimeOut.removeAll()
        for str in timeOut {
            filteredtimeOut.append(str)
        }
        collectionView.reloadData()
        return false
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.count != 0 {
            self.filteredtimeOut.removeAll()
            for str in timeOut {
                let name = str.title.lowercased()
                let range = name.range(of: textField.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil {
                    self.filteredtimeOut.append(str)
                }
                
            }
        }
        collectionView.reloadData()
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

extension NotiViewController: UITableViewDelegate, UITableViewDataSource {
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
            sortingAlpanumeric()
        }else if(indexPath.row == 1){
            sortingOldest()
        }else if(indexPath.row == 2){
            sortingLatest()
        }else if(indexPath.row == 3){
            sortingValidity()
        }
        sortingText = sorting[indexPath.row]
        self.dismissAlertController()
        collectionView.reloadData() // for 글자 업데이트
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    //sorting
    func sortingAlpanumeric(){
        timeOut = timeOut.sorted {$0.title.localizedStandardCompare($1.title) == .orderedAscending}
        filteredtimeOut = timeOut
    }
    
    func sortingOldest(){
        timeOut = timeOut.sorted { $0.timeoutId < $1.timeoutId }
        filteredtimeOut = timeOut

    }
    
    func sortingLatest(){
        timeOut = timeOut.sorted { $0.timeoutId > $1.timeoutId }
        filteredtimeOut = timeOut

    }
    
    func sortingValidity(){
        timeOut = timeOut.sorted { DateUtil.toSecond($0.deadLine) < DateUtil.toSecond($1.deadLine)}
        filteredtimeOut = timeOut
    }
    
    
}

class MakeNotiFolderViewController: UIViewController, MakeNotiFolderViewdelegate {
    
    var editMode: Bool = false
    var timeOut: Timeout?
    
    func dissMiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func done() {
        if(validate()){
            print(makeNotiFolderView.nameTextField.text!)
 
            print(makeNotiFolderView.datePicker.date)
            let intArray = alarmIntArray()
            print(intArray)
            

            self.dismiss(animated: true, completion: nil)
            print("생성 완료")
        }
    }
    
    func alarmIntArray() -> [Int] {
        var intArray = [Int]()
        if(makeNotiFolderView.weekDayButton.isSelected){
            intArray.append(7)
        }
        if(makeNotiFolderView.threeDayButton.isSelected){
            intArray.append(3)
        }
        if(makeNotiFolderView.oneDayButton.isSelected){
            intArray.append(1)
        }
        return intArray
    }
    
    func tapImageView() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: [.images])
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func validate() -> Bool{
        if makeNotiFolderView.nameTextField.text != "" {
            return true
        }
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    
    @IBOutlet weak var makeNotiFolderView: MakeNotiFolderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeNotiFolderView.delegate = self
        if(editMode){
            print("eidt timeout is \(timeOut!)")
            self.makeNotiFolderView.configure(cell: timeOut!)
        }
    }
    
    
}

extension MakeNotiFolderViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [self] (image, error) in
                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        self.makeNotiFolderView
                        .imageView.image = image
                    }
                }
        }

        } else { // TODO: Handle empty results or item providernot being able load UIImage
            print("can't load image")

        }
    }
}
