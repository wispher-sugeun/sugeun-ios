//
//  NotiViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/05/10.
//

import UIKit
import DropDown
import PhotosUI

class NotiViewController: UIViewController{
    

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
    var sorting = ["가나다 순", "생성 순", "최신 순"]
    
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
        timeOut.append(Timeout(userId: 2, timeoutId: 2, title: "이디야 아이스티", timeoutImage: imageArray[1], deadLine: "2021-07-30", selectedList: [1,3, 7], isValid: false))
        timeOut.append(Timeout(userId: 3, timeoutId: 3, title: "투썸 아이스박스", timeoutImage: imageArray[2], deadLine: "2021-09-10", selectedList: [1, 7], isValid: true))
        filteredtimeOut = timeOut
        floatingButtonSetting(floatingButton)
        collectionViewSetting(collectionView: collectionView)
        textFieldSetting(textfield: searchTextField)
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        flowSetting()
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
        
}

extension NotiViewController: UICollectionViewDelegate, UICollectionViewDataSource, TimeOutCollectionViewCellDelegate, UICollectionViewDelegateFlowLayout {
    
    func moreButton(cell: TimeOutCollectionViewCell) {
        print("more button click")
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
               
            }else if(index == 2) { // 알림 삭제
                self.alertWithNoViewController(title: "알림 삭제", message: "알림을 삭제 하시겠습니까?", completion: { (response) in
                    if (response == "OK") {
                        timeOut.remove(at: (cell.indexPath?[1])!)
                        self.alertViewController(title: "삭제 완료", message: "알림이 삭제 되었습니다.", completion: {(response) in
                            //TO DO 사용 완료 처리
                            DispatchQueue.main.async {
                                
                            }
                        })
                }
                    
                })
                    
            }
        }
        more_dropDown.clearSelection()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredtimeOut.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        notUsedSorting()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeOutCollectionViewCell.identifier, for: indexPath) as? TimeOutCollectionViewCell
        cell?.delegate = self
        cell?.configure(model: filteredtimeOut[indexPath.row])
        cell?.backgroundColor = .red
        cell?.configureHeight(with: 200)
        cell?.indexPath = indexPath
        return cell!
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
            let width = collectionView.bounds.width
            let height = collectionView.bounds.height
            print("width : \(collectionView.bounds.width / 2)")
            print("height : \(collectionView.bounds.height / 2)")
        return CGSize(width: (width / 2) - 100, height: height)
    }
    
    //위 아래 라인 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        print("위 아래 간격")
        return 50
    }
    
    //옆 라인 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        print("옆 라인 간격")
        return 10
    }
    
    //for cell info and sort
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath)
            
            let folderCount = UILabel()
            folderCount.text = "\(filteredtimeOut.count)개의 알림"
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
            
        }else if(indexPath.row == 1){
            
        }else if(indexPath.row == 2){
            
        }
    }
    
    
}

class MakeNotiFolderViewController: UIViewController, MakeNotiFolderViewdelegate {
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
        print("view did load")
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
