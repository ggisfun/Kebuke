//
//  LoginViewController.swift
//  Kebuke
//
//  Created by Adam Chen on 2024/9/4.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    @IBAction func login(_ sender: Any) {
        if userNameTextField.text?.isEmpty == true{
            let alert = UIAlertController(title: "請先輸入名稱喔！😀", message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "確定", style: .default))
            present(alert, animated: true)
        }else{
            performSegue(withIdentifier: "showMenu", sender: nil)
        }
    }
    
    
    @IBSegueAction func showMenu(_ coder: NSCoder) -> UITabBarController? {
        let controller = UITabBarController(coder: coder)
        let menuController = controller?.viewControllers?.first as! MenuViewController
        if let userName = userNameTextField.text{
            menuController.userName = userName
        }
        return controller
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
