
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
