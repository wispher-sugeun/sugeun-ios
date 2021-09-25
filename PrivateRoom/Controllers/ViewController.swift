//
//  ViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/05/09.
//

//import UIKit
//import Tabman
//import Pageboy
//
//class ViewController: TabmanViewController {
//    private var viewControllers: Array<UIViewController> = []
//
//    @IBOutlet weak var barContainer: UIView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupSubView()
//        barLayout()
//    }
//
//    func setupSubView(){
//        let mainVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "main") as MainViewController
//        let textVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "text") as TextViewController
//        let linkVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "link") as LinkViewController
//        let notiVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "noti") as NotiViewController
//        let calendarVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "calendar") as CalendarViewController
//
//        viewControllers.append(mainVC)
//        viewControllers.append(textVC)
//        viewControllers.append(linkVC)
//        viewControllers.append(notiVC)
//        viewControllers.append(calendarVC)
//    }
//
//    func barLayout(){
//        self.dataSource = self
//        let bar = TMBar.ButtonBar()
//        settingTabBar(ctBar: bar)
//        addBar(bar, dataSource: self, at: .custom(view: barContainer, layout: { (bar) in
//            bar.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                bar.topAnchor.constraint(equalTo: self.barContainer.topAnchor),
//                bar.leadingAnchor.constraint(equalTo: self.barContainer.leadingAnchor),
//                bar.trailingAnchor.constraint(equalTo: self.barContainer.trailingAnchor),
//                bar.bottomAnchor.constraint(equalTo: self.barContainer.bottomAnchor)
//                ])
//            }))
//    }
//
//    func settingTabBar(ctBar: TMBar.ButtonBar){
//        ctBar.layout.transitionStyle = .snap //customize
//        ctBar.layout.contentMode = .fit
//        ctBar.backgroundView.style = .blur(style: .extraLight)
//        ctBar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
//        ctBar.layout.interButtonSpacing = 20
//        ctBar.buttons.customize({ (button) in
//            button.tintColor = .black
//            button.selectedTintColor = #colorLiteral(red: 0.2786179185, green: 0.341037035, blue: 0.5691607594, alpha: 1)
//            button.font = UIFont.systemFont(ofSize: 16)
//            button.selectedFont = UIFont.systemFont(ofSize: 16, weight: .medium)
//        })
//
//        //인디케이터
//        ctBar.indicator.weight = .custom(value: 2)
//        ctBar.indicator.tintColor = #colorLiteral(red: 0.2786179185, green: 0.341037035, blue: 0.5691607594, alpha: 1)
//    }
//
//
//}
//
//extension ViewController: PageboyViewControllerDataSource, TMBarDataSource {
//    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
//        return viewControllers.count
//    }
//
//    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
//        return viewControllers[index]
//    }
//
//    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
//        return nil
//    }
//
//    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
//        let item = TMBarItem(title: "")
//        switch index {
//        case 0:
//            item.title = "보관함"
//            break
//        case 1:
//            item.title = "텍스트"
//            break
//        case 2:
//            item.title = "링크"
//            break
//        case 3:
//            item.title = "선물"
//            break
//        case 4:
//            item.title = "캘린더"
//            break
//        default:
//            break
//        }
//        return item
//    }
//
//
//}
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var allVC: UIButton!
    @IBOutlet weak var textVC: UIButton!
    @IBOutlet weak var linkVC: UIButton!
    @IBOutlet weak var giftVC: UIButton!
    @IBOutlet weak var calendarVC: UIButton!
    @IBOutlet weak var profileVC: UIButton!
    
   
    var btnLists : [UIButton] = []
        
        var currentIndex : Int = 0 {
            didSet{
                changeBtnColor()
            }
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setBtnList()
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        
        func setBtnList(){
            allVC.tintColor = .orange
            btnLists.append(allVC)
            btnLists.append(textVC)
            btnLists.append(linkVC)
            btnLists.append(giftVC)
            btnLists.append(calendarVC)
            btnLists.append(profileVC)
            
        }
        
        func changeBtnColor(){
            
            for (index, element) in btnLists.enumerated(){
                
                if index == currentIndex {
                    element.setTitleColor(#colorLiteral(red: 0.5568627451, green: 0.6392156863, blue: 0.8, alpha: 1), for: .normal)
                }
                else{
                    element.setTitleColor(#colorLiteral(red: 0.09519775957, green: 0.1197544411, blue: 0.2188102901, alpha: 1), for: .normal)
                }
                
            }
            
        }
        
        
        var pageViewController : PageViewController!
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           
            if segue.identifier == "pageViewController" {
                
                guard let vc = segue.destination as? PageViewController else {
                    print("return")
                    return}
                pageViewController = vc
                
                pageViewController.completeHandler = { (result) in
                    self.currentIndex = result
                }
                
            }
            
        }
        
    
        @IBAction func allVC(_ sender: Any) {
            pageViewController.setViewcontrollersFromIndex(index: 0)
        }
    
        @IBAction func textVC(_ sender: Any) {
            pageViewController.setViewcontrollersFromIndex(index: 1)
        }
    
        @IBAction func linkVC(_ sender: Any) {
            pageViewController.setViewcontrollersFromIndex(index: 2)
        }
    
        @IBAction func giftVC(_ sender: Any) {
            pageViewController.setViewcontrollersFromIndex(index: 3)
        }

        @IBAction func calendarVC(_ sender: Any) {
            pageViewController.setViewcontrollersFromIndex(index: 4)
        }

        @IBAction func profileVC(_ sender: Any) {
            let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(identifier: "profile") as? ProfileViewController
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.pushViewController(profileVC!, animated: true)
           
        }
    

   
    
}
