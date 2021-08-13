//
//  PageViewController.swift
//  PrivateRoom
//
//  Created by JoSoJeong on 2021/08/03.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var completeHandler : ((Int)->())?
    
    var currentIndex : Int {
            guard let vc = viewControllers?.first else { return 0 }
            return ViewControllers.firstIndex(of: vc) ?? 0
        }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            completeHandler?(currentIndex)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = ViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = index - 1
        if(previousIndex < 0){
            return nil
        }
        return ViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = ViewControllers.firstIndex(of: viewController) else {return nil}
                    
          let nextIndex = index + 1
                
          if nextIndex == ViewControllers.count { return nil}
                
          return ViewControllers[nextIndex]
                    
              
          
    }
    
    func setViewcontrollersFromIndex(index : Int){
          if index < 0 && index >= ViewControllers.count {return }
        self.setViewControllers([ViewControllers[index]], direction: .forward, animated: true, completion: nil)
        completeHandler?(currentIndex)
    }
    
    
    private var ViewControllers: Array<UIViewController> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubView()
        self.dataSource = self
        self.delegate = self
        
        if let firstvc = ViewControllers.first {
            self.setViewControllers([firstvc], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func setupSubView(){
            let mainVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "main") as MainViewController
            let textVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "text") as TextViewController
            let linkVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "link") as LinkViewController
            let notiVC = UIStoryboard.init(name: "Timeout", bundle: nil).instantiateViewController(identifier: "noti") as NotiViewController
            let calendarVC = UIStoryboard.init(name: "Calendar", bundle: nil).instantiateViewController(identifier: "calendar") as CalendarViewController
    
        ViewControllers.append(mainVC)
        ViewControllers.append(textVC)
        ViewControllers.append(linkVC)
        ViewControllers.append(notiVC)
        ViewControllers.append(calendarVC)
    }
    
    
}
