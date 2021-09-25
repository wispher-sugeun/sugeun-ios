//
//  NotiViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/05/10.
//

import UIKit
import DropDown
import PhotosUI
import NVActivityIndicatorView

enum MakeTimeoutError: Error {
    case noTimeoutTitle
    case noTimeoutImage
    case TimeoutTitleName
}

class NotiViewController: UIViewController, UIGestureRecognizerDelegate{

    var defaultImage = UIImage(systemName: "questionmark.square")
    var timeOut = [GetTimeoutResponse?]()
    var filteredtimeOut = [GetTimeoutResponse?]()
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout! {
        didSet {
            collectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    let indicator = NVActivityIndicatorView(frame: CGRect(x: 162, y: 100, width: 50, height: 50),
                                            type: .circleStrokeSpin,
                                            color: #colorLiteral(red: 0.5568627451, green: 0.6392156863, blue: 0.8, alpha: 1),
                                            padding: 0)
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        fetchData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        indicator.frame = CGRect(x: screenWidth/2, y: screenHeight/2, width: 50, height: 50)
        indicator.center = self.view.center
        view.addSubview(indicator)
        floatingButtonSetting(floatingButton)
        collectionViewSetting(collectionView: collectionView)
        textFieldSetting(textfield: searchTextField)
        //flowSetting()
        notUsedSorting()
        collectionView.reloadData()
        refreshing()
    }
    
    func fetchData(){
        indicator.startAnimating()
        TimeoutService.shared.getTimeout(completion: { (response) in
            self.timeOut = response
            self.filteredtimeOut = self.timeOut
            self.collectionView.reloadData()
            let notiManager = LocalNotificationManager()
            notiManager.listScheduledNotifications()
        })
        indicator.stopAnimating()
    }
    
    func refreshing(){
        print("here")
        //refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        refreshControl.beginRefreshing()
        collectionView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        print("refresh")
        fetchData()
        refreshControl.endRefreshing()
    }
    
//    func flowSetting(){
//        collectionView.collectionViewLayout = collectionViewLayout
//        collectionViewLayout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
//
//        collectionViewLayout.itemSize = CGSize(width: screenWidth / 2, height: screenWidth / 2)
//        collectionViewLayout.minimumInteritemSpacing = 0
//        collectionViewLayout.minimumLineSpacing = 0
//
//    }
    
    func floatingButtonSetting(_: UIButton){
        floatingButton.circle()
        floatingButton.addTarget(self, action: #selector(makeFolder), for: .touchUpInside)
    }
    
    func textFieldSetting(textfield: UITextField){
        textfield.delegate = self
        textfield.circle()
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        textfield.leftViewMode = .always
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
        
//        collectionView.collectionViewLayout = CollectionViewLeftAlignFlowLayout()
//        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//                    flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//            flowLayout.minimumInteritemSpacing = 0
//            flowLayout.minimumLineSpacing = 0
//            flowLayout.sectionHeadersPinToVisibleBounds = true
//
//            flowLayout.headerReferenceSize = CGSize(width: 0, height: 50)
//            flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
//                  }
    }
    
    @objc func makeFolder(){
        let makeNotiFolderView = self.storyboard?.instantiateViewController(identifier: "MakeNotiFolderViewController") as! MakeNotiFolderViewController
        self.navigationController?.pushViewController(makeNotiFolderView, animated: true)
//        makeNotiFolderView.modalPresentationStyle = .overCurrentContext
//        self.present(makeNotiFolderView, animated: true, completion: nil)
    }
    
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        if (gestureRecognizer.state != .began) {
                return
            }

            let p = gestureRecognizer.location(in: collectionView)

            if let indexPath = collectionView?.indexPathForItem(at: p) {
               // if(self.timeOut[indexPath.row].isValid == false){ // isValid false인 경우에만 반응
                self.alertWithNoViewController(title: "알림 삭제", message: "알림을 삭제 하시겠습니까?", completion: { [self] (response) in
                        if (response == "OK") {
                            let deleteItem = filteredtimeOut[indexPath.row]
                            TimeoutService.shared.deleteTimeout(timeoutId: deleteItem!.timeoutId)
                            timeOut.remove(at: indexPath.row)
                            filteredtimeOut = timeOut
                            DispatchQueue.main.async {
                                collectionView.reloadData()
                            }
                            self.alertViewController(title: "삭제 완료", message: "알림이 삭제 되었습니다.", completion: {(response) in
                                
                                //TODO - delete noti
                                let notiManager = LocalNotificationManager()
                                let notiidentifier = "t_\(deleteItem!.timeoutId)_"
                                let selectedArray: [Int] = deleteItem!.selected
                                notiManager.deleteSchedule(notificationId: notiidentifier + "0")
                                for i in selectedArray {
                                    notiManager.deleteSchedule(notificationId: notiidentifier +
                                       "\(i)")
                                }
                            })
                           
                    }
                        
                    })
                }

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
                self.navigationController?.pushViewController(makeNotiFolderView, animated: true)
//                makeNotiFolderView.modalPresentationStyle = .overCurrentContext
//                self.present(makeNotiFolderView, animated: true, completion: nil)

            }else if(index == 1){ // 사용 완료
                if(cell.inValidView.isHidden == true){
                    self.alertWithNoViewController(title: "사용 완료 하시겠습니까?", message: "한번 사용 완료시 다시 알림 등록을 하셔야 합니다", completion: { (response) in
                        if (response == "OK") {
                            cell.inValidView.isHidden = false
                            self.alertViewController(title: "사용 완료", message: "쿠폰 사용 완료 되었습니다.", completion: {(response) in
                                let timeoutId = filteredtimeOut[cell.indexPath!.row]!.timeoutId
                                TimeoutService.shared.useTiemout(timeoutId: timeoutId)
                                
                                
                                //TO DO delete that identifier
                                let notiManager = LocalNotificationManager()
                                let notiidentifier = "t_\(filteredtimeOut[cell.indexPath!.row]!.timeoutId)_"
                                let selectedArray: [Int] = filteredtimeOut[cell.indexPath!.row]!.selected
                                notiManager.deleteSchedule(notificationId: notiidentifier + "0")
                                for i in selectedArray {
                                    notiManager.deleteSchedule(notificationId: notiidentifier +
                                       "\(i)")
                                }

                                
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
        cell?.configure(model: filteredtimeOut[indexPath.row]!)
        cell?.configureHeight(with: 160)
        cell?.indexPath = indexPath
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = filteredtimeOut[indexPath.row]
        let viewNoti =  self.storyboard?.instantiateViewController(identifier: "ViewNoti") as! ViewNotiController
        viewNoti.titleString = cell!.title
        viewNoti.imageData = cell?.imageData
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.pushViewController(viewNoti, animated: true)

    }
    

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//            let width = collectionView.bounds.width
//            let height = collectionView.bounds.height
////        print("width : \(collectionView.bounds.width / 2.5)")
////            print("height : \(collectionView.bounds.height / 2)")
//        return CGSize(width: (width / 2) - 140, height: height)
//    }
    
    //위 아래 라인 간격
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 50
//    }
//
//    //옆 라인 간격
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 1
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//           return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//        }
    
    //for cell info and sort
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath)
            print("headerView \(headerView)")
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
        timeOut = timeOut.sorted(by: { $0?.isValid == false && $1?.isValid == true})
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

extension NotiViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let text = textField.text else {return}
        print("text \(text)")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = textField.text! + string
        if searchText.count >= 2{
            filteredtimeOut = timeOut.filter({ (result) -> Bool in
                result!.title.range(of: searchText, options: .caseInsensitive) != nil
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
                let name = str?.title.lowercased()
                let range = name!.range(of: textField.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil {
                    self.filteredtimeOut.append(str)
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
        //collectionView.collectionViewLayout.invalidateLayout()
    }
    
    //sorting
    func sortingAlpanumeric(){
        timeOut = timeOut.sorted {$0!.title.localizedStandardCompare($1!.title) == .orderedAscending}
        filteredtimeOut = timeOut
    }
    
    func sortingOldest(){
        timeOut = timeOut.sorted { $0!.timeoutId < $1!.timeoutId }
        filteredtimeOut = timeOut

    }
    
    func sortingLatest(){
        timeOut = timeOut.sorted { $0!.timeoutId > $1!.timeoutId }
        filteredtimeOut = timeOut

    }
    
    func sortingValidity(){
        timeOut = timeOut.sorted { DateUtil.toSecond($0!.deadline) < DateUtil.toSecond($1!.deadline)}
        filteredtimeOut = timeOut
    }
    
    
}

class MakeNotiFolderViewController: UIViewController, MakeNotiFolderViewdelegate {
    var defaultImage = UIImage(systemName: "questionmark.square")
    var editMode: Bool = false
    var timeOut: GetTimeoutResponse?
    
    func dissMiss() {
        self.navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
    }
    
    func done() {
        do {
            
        try validate()
 
            print(makeNotiFolderView.nameTextField.text!)
 
            print(makeNotiFolderView.datePicker.date)
            let intArray = alarmIntArray()
            print(intArray)
            let date = DateUtil.serverSendDateTimeFormat(makeNotiFolderView.datePicker.date)
            
            let userId = UserDefaults.standard.integer(forKey: UserDefaultKey.userID)
            
            if(editMode == true){ // 알림 수정에서 넘어온 데이터
              
                let updateTimeout = UpdateTimeoutRequest(timeoutId: timeOut!.timeoutId, userId: userId, title: makeNotiFolderView.nameTextField.text!, deadline: date, isValid: true, selected: intArray)
                print("updateTimeout \(updateTimeout)")
                print("timeoutID \(timeOut!.timeoutId)")
                TimeoutService.shared.updateTimeoutInfo(timeoutId: timeOut!.timeoutId, timeoutRequest: updateTimeout)
                TimeoutService.shared.updateTimeoutImage(timeoutId: timeOut!.timeoutId, imageFile: (makeNotiFolderView.imageView.image?.jpeg(.lowest))!)
                            
                //TO DO delete that identifier t_id_0
                ////delete first - t_id_0
                let notiManager = LocalNotificationManager()
                let notiidentifier = "t_\(timeOut!.timeoutId)_"
                let selectedArray: [Int] = timeOut!.selected
                notiManager.deleteSchedule(notificationId: notiidentifier + "0")
                for i in selectedArray {
                    notiManager.deleteSchedule(notificationId: notiidentifier +
                       "\(i)")
                }
                
                ////set renew
                
                let dateComponents = DateComponents(year: makeNotiFolderView.datePicker.date.year, month: makeNotiFolderView.datePicker.date.month, day: makeNotiFolderView.datePicker.date.day, hour: 12, minute: 0, second: 0)
                notiManager.notifications = [ Notifications(id: notiidentifier + "0", title: makeNotiFolderView.nameTextField.text!, datetime: dateComponents)]
                print("create date : \(dateComponents)")
                
                for i in intArray {
                    let dateComponents =  DateComponents(year: makeNotiFolderView.datePicker.date.year, month: makeNotiFolderView.datePicker.date.month, day: makeNotiFolderView.datePicker.date.day - i, hour: 12, minute: 0, second: 0)
                    notiManager.notifications.append(Notifications(id: notiidentifier + "\(i)", title: makeNotiFolderView.nameTextField.text!, datetime: dateComponents))
                }
                notiManager.timeout()
                
                self.alertViewController(title: "수정 완료", message: "알림이 수정되었습니다", completion: { (response) in
                    if(response == "OK"){
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                })
                
            }else {
                let createTimoutRequest = CreateTimeoutRequest(userId: userId, title: makeNotiFolderView.nameTextField.text!, deadline: date, isValid: true, selected: intArray, imageFile: (makeNotiFolderView.imageView.image?.jpeg(.lowest))!)
                
                TimeoutService.shared.createTimeout(createTimoutRequest: createTimoutRequest, completion: { (response) in
                    //TO DO create noti
                    let notiManager = LocalNotificationManager()
                    let dateComponents = DateComponents(year: self.makeNotiFolderView.datePicker.date.year, month: self.makeNotiFolderView.datePicker.date.month, day: self.makeNotiFolderView.datePicker.date.day, hour: 12, minute: 0, second: 0)
                    let notiidentifier = "t_\(response)_"
                    notiManager.notifications = [ Notifications(id: notiidentifier + "0", title: self.makeNotiFolderView.nameTextField.text!, datetime: dateComponents)]
                    print("create date : \(dateComponents)")
                    
                    //선택한 날짜에 대해 알림
                    for i in intArray {
                        let dateComponents =  DateComponents(year: self.makeNotiFolderView.datePicker.date.year, month: self.makeNotiFolderView.datePicker.date.month, day: self.makeNotiFolderView.datePicker.date.day - i, hour: 12, minute: 0, second: 0)
                        notiManager.notifications.append(Notifications(id: notiidentifier + "\(i)", title: self.makeNotiFolderView.nameTextField.text!, datetime: dateComponents))
                    }
                    notiManager.timeout()
                })
                self.alertViewController(title: "생성 완료", message: "알림이 생성되었습니다", completion: { (response) in
                    if(response == "OK"){
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            }
           
            
            
        }catch {
            var errorMessage: String = ""
            switch error as! MakeTimeoutError {
            case .TimeoutTitleName:
                errorMessage = "15글자 이내로 이름을 지어주세요"
            case .noTimeoutImage:
                errorMessage = "이미지를 선택해주세요"
            case .noTimeoutTitle:
                errorMessage = "폴더 이름을 입력해주세요"
            }
            
            self.alertViewController(title: "생성 실패", message: errorMessage, completion: { (response) in
                
            })
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
    
    func validate() throws {
        guard (makeNotiFolderView.nameTextField.text!.count < 15) else {
            throw MakeTimeoutError.TimeoutTitleName
        }
        
        guard (makeNotiFolderView.nameTextField.text != "") else {
            throw MakeTimeoutError.noTimeoutTitle
        }
        
        if (makeNotiFolderView.imageView.image == defaultImage){
            throw MakeTimeoutError.noTimeoutImage
        }
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
