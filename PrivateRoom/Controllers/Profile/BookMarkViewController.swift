//
//  BookMarkViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/07/14.
//

import UIKit
import Tabman
import Pageboy

class BookMarkViewController: TabmanViewController {

    private var viewControllers: Array<UIViewController> = []

    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        print("view did load")
        super.viewDidLoad()
        setupSubView()
        barLayout()
    }
    
    func setupSubView(){
        let textBookmarkVC = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(identifier: "textBookMark") as TextBookViewController
        let lintBookmarkVC = UIStoryboard.init(name: "Profile", bundle: nil).instantiateViewController(identifier: "linkBookMark") as LinkBookViewController

        
        viewControllers.append(textBookmarkVC)
        viewControllers.append(lintBookmarkVC)

    }

    func barLayout(){
        self.dataSource = self
        let bar = TMBar.ButtonBar()
        settingTabBar(ctBar: bar)
        addBar(bar, dataSource: self, at: .top)
//        addBar(bar, dataSource: self, at: .custom(view: barContainer, layout: { (bar) in
//            bar.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                bar.topAnchor.constraint(equalTo: self.barContainer.topAnchor),
//                bar.leadingAnchor.constraint(equalTo: self.barContainer.leadingAnchor),
//                bar.trailingAnchor.constraint(equalTo: self.barContainer.trailingAnchor),
//                bar.bottomAnchor.constraint(equalTo: self.barContainer.bottomAnchor)
//                ])
//            }))
    }
    
    func settingTabBar(ctBar: TMBar.ButtonBar){
        ctBar.layout.transitionStyle = .snap //customize
        ctBar.layout.contentMode = .fit
        ctBar.backgroundView.style = .blur(style: .extraLight)
        ctBar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        ctBar.layout.interButtonSpacing = 20
        ctBar.buttons.customize({ (button) in
            button.tintColor = .black
            button.selectedTintColor = #colorLiteral(red: 0.2786179185, green: 0.341037035, blue: 0.5691607594, alpha: 1)
            button.font = UIFont.systemFont(ofSize: 16)
            button.selectedFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        })
        
        //인디케이터
        ctBar.indicator.weight = .custom(value: 2)
        ctBar.indicator.tintColor = #colorLiteral(red: 0.2786179185, green: 0.341037035, blue: 0.5691607594, alpha: 1)
    }


}

extension BookMarkViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        print(viewControllers.count)
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
    
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let item = TMBarItem(title: "")
        switch index {
        case 0:
            item.title = "텍스트"
            break
        case 1:
            item.title = "링크"
            break
        default:
            break
        }
        return item
    }
    
    
}


