//
//  TextViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/05/10.
//

import UIKit
import DropDown
import PhotosUI


class TextViewController: UIViewController, PHPickerViewControllerDelegate {
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
    

    
    var configuration = PHPickerConfiguration()
    @IBOutlet weak var floatingButton: UIButton!
    
    @IBOutlet weak var searchTextField: UITextField!

    @IBOutlet weak var collectionView: UICollectionView!
    
    var textFolder = [Folder]()
    var filteredTextFolder = [Folder]()
    
    var textCell = [Phrase]()
    var filteredTextCell = [Phrase]()
    var sorting = ["가나다 순", "생성 순", "최신 순"]
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonSetting(button: floatingButton)
        textFieldSetting(textField: searchTextField)
        collectionViewSetting()
        dummyFolder()
       
        
      
    }
    
    func presentPicker(){
        configuration.filter = .any(of: [.images])
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    
    @objc func folderImageChanged(_ notification: NSNotification){
        //text ~~
        print(notification.userInfo ?? "")
        print("folderImageChanged")
        if let dict = notification.userInfo as NSDictionary? {
            if let folderImage = dict["image"] as? UIImage{
                filteredTextFolder[selectedCellIndexPath[1]].folderImage = image( UIImage(systemName: "heart.fill")!, withSize: CGSize(width: 100, height: 80))
                    
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
                // do something with your image
            }
        }
        
    }
    
    func folderDelete(){
        filteredTextFolder.remove(at: selectedCellIndexPath[1])
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func image( _ image:UIImage, withSize newSize:CGSize) -> UIImage {

        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0,y: 0,width: newSize.width,height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(.automatic)
    }
    
    
    func editFolderName(completionHandler: @escaping ((String) -> Void)){
        let alertVC = UIAlertController(title: "폴더 이름 수정", message: nil, preferredStyle: .alert)
       
        alertVC.addTextField(configurationHandler: { (textField) -> Void in
            self.folderNameTextField = textField
            self.folderNameTextField.placeholder = "새로 수정할 아이디를 입력해주세요"
        })
        let label = UILabel(frame:CGRect(x: 0, y: 40, width: 270, height:18))
        
        let editAction = UIAlertAction(title: "EDIT", style: .default, handler: { [self] (action) -> Void in
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
        
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        alertVC.addAction(editAction)
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
        
        
    }
    
    func dummyFolder(){
        textFolder.append(Folder(folderName: "텍스트 폴더1", folderImage: UIImage(systemName: "heart.fill"), isLike: true))
        textFolder.append(Folder(folderName: "텍스트 폴더2", folderImage: UIImage(systemName: "heart.fill"), isLike: true))
        textFolder.append(Folder(folderName: "텍스트 폴더3", folderImage: UIImage(systemName: "heart.fill"), isLike: true))
        
        filteredTextFolder = textFolder
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.folderImageChanged(_:)), name: .folderImageChanged, object: nil)
    }
    
    func buttonSetting(button: UIButton){
        button.addTarget(self, action: #selector(didTapFloatingButton), for: .touchUpInside)
    }
    
    @objc func didTapFloatingButton(){
        let makeFolderView = self.storyboard?.instantiateViewController(identifier: "makeFolderAlertView") as! makeFolderAlertView
        makeFolderView.modalPresentationStyle = .overCurrentContext
        
        makeFolderView.type_dropDown.dataSource = ["텍스트"]
        self.present(makeFolderView, animated: true, completion: nil)
    }
    
    func textFieldSetting(textField: UITextField){
        textField.delegate = self
        textField.circle()
        
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
            
        }else if(indexPath.row == 1){
            
        }else if(indexPath.row == 2){
            
        }
    }
    
    
}


extension TextViewController: UITextFieldDelegate, UIGestureRecognizerDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let text = textField.text else {return}
        print("text \(text)")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = textField.text! + string
        if searchText.count >= 2{
            filteredTextFolder = textFolder.filter({ (result) -> Bool in
                result.folderName.range(of: searchText, options: .caseInsensitive) != nil
            })
        }else {
            filteredTextFolder = textFolder
        }
       
        collectionView.reloadData()
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        self.filteredTextFolder.removeAll()
        for str in textFolder {
            filteredTextFolder.append(str)
        }
        collectionView.reloadData()
        return false
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.count != 0 {
            self.filteredTextFolder.removeAll()
            for str in textFolder {
                let name = str.folderName.lowercased()
                let range = name.range(of: textField.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil {
                    self.filteredTextFolder.append(str)
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

extension TextViewController: UICollectionViewDataSource, UICollectionViewDelegate, FolderCollectionViewCellDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTextFolder.count
    }

    
    func didTapMoreButton(cell: FolderCollectionViewCell) {
        print("more button")
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
                folderDelete()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FolderCollectionViewCell.identifier, for: indexPath) as! FolderCollectionViewCell
        cell.cellDelegate = self
        cell.configure(folder: filteredTextFolder[indexPath.row])
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
    
    
    //for cell info and sort
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        print("here")
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerView", for: indexPath)
            
            let folderCount = UILabel()
            folderCount.text = "\(textFolder.count)개의 폴더"
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let VC = self.storyboard?.instantiateViewController(identifier: "textIn") else { return }
        VC.modalTransitionStyle = .coverVertical
        VC.modalPresentationStyle = .fullScreen
        self.present(VC, animated: true, completion: nil)
    }

}

