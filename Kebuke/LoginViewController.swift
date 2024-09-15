//
//  LoginViewController.swift
//  Kebuke
//
//  Created by Adam Chen on 2024/9/4.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var registerNameTextField: UITextField!
    @IBOutlet weak var registerEmailTextField: UITextField!
    @IBOutlet weak var registerPasswordTextField: UITextField!
    @IBOutlet weak var loginNameTextField: UITextField!
    @IBOutlet weak var loginPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerView.isHidden = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func showRegisterView(_ sender: Any) {
        registerView.isHidden = false
        loginView.isHidden = true
//        UIView.animate(withDuration: 0.1) {
//            
//        }
    }
    
    @IBAction func showLoginView(_ sender: Any) {
        registerView.isHidden = true
        loginView.isHidden = false
        
        registerNameTextField.text?.removeAll()
        registerEmailTextField.text?.removeAll()
        registerPasswordTextField.text?.removeAll()
        
        registerNameTextField.placeholder?.removeAll()
        registerEmailTextField.placeholder?.removeAll()
        registerPasswordTextField.placeholder?.removeAll()
    }
    
    
    @IBAction func register(_ sender: Any) {
        guard registerNameTextField.text!.isEmpty == false && registerEmailTextField.text!.isEmpty == false && registerPasswordTextField.text!.isEmpty == false else {
            if registerNameTextField.text!.isEmpty {
                registerNameTextField.attributedPlaceholder = NSAttributedString(string: "UserName", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
            }
            if registerEmailTextField.text!.isEmpty {
                registerEmailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
            }
            if registerPasswordTextField.text!.isEmpty {
                registerPasswordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
            }
            return
        }
        
        let userName = registerNameTextField.text!
        let email = registerEmailTextField.text!
        let password = registerPasswordTextField.text!
        
        let registerData = User(user:UserInfo(login: userName, email: email, password: password))
        let url = APIURL.register.url
        
        Task {
            do {
                let resultData = try await sendRequest(postData: registerData, postUrl: url)
                updateUI(resultData: resultData)
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func login(_ sender: Any) {
        guard loginNameTextField.text!.isEmpty == false && loginPasswordTextField.text!.isEmpty == false else {
            if loginNameTextField.text!.isEmpty {
                loginNameTextField.attributedPlaceholder = NSAttributedString(string: "UserName", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
            }
            if loginPasswordTextField.text!.isEmpty {
                loginPasswordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
            }
            return
        }
        
        let userName = loginNameTextField.text!
        let password = loginPasswordTextField.text!
        
        guard let token = UserDefaults.standard.string(forKey: userName) else {
            let alert = UIAlertController(title: "該使用者名稱尚未註冊", message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let loginData = User(user:UserInfo(login: userName, email: nil, password: password))
        let url = APIURL.login.url
        
        Task {
            do {
                let resultData = try await sendRequest(postData: loginData, postUrl: url, userToken: token)
                if resultData.errorCode == nil {
                    performSegue(withIdentifier: "showMenu", sender: nil)
                }else{
                    let alert = UIAlertController(title: resultData.message!, message: nil, preferredStyle: .alert)
                    alert.addAction(.init(title: "OK", style: .default))
                    present(alert, animated: true)
                }
                
            } catch {
                print(error)
            }
        }
        
    }
    
    func sendRequest(postData: User, postUrl: URL, userToken: String? = nil) async throws -> Result {
        var request = URLRequest(url: postUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token token=\"\(apiKey)\"", forHTTPHeaderField: "Authorization")
        
        if userToken != nil {
            request.setValue(userToken, forHTTPHeaderField: "User_Token")
        }
        
        let requestData = try? JSONEncoder().encode(postData)
        if let requestData {
            request.httpBody = requestData
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ErrorMessage.statusCodeError
        }
        
        guard let resultData = try? JSONDecoder().decode(Result.self, from: data) else {
            throw ErrorMessage.decodeDataError
        }
        
        return resultData
    }
    
    func updateUI(resultData: Result) {
        var title = ""
        if let token = resultData.userToken,
           let userName = resultData.login{
            UserDefaults.standard.set(token, forKey: userName)
            
            title = "註冊成功!"
            
            loginNameTextField.text = userName
            loginPasswordTextField.text = registerPasswordTextField.text
            
            registerView.isHidden = true
            loginView.isHidden = false
            
            registerNameTextField.text?.removeAll()
            registerEmailTextField.text?.removeAll()
            registerPasswordTextField.text?.removeAll()
        }else {
            title = resultData.message!
        }
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
    @IBSegueAction func showMenu(_ coder: NSCoder) -> UITabBarController? {
        let controller = UITabBarController(coder: coder)
        let menuController = controller?.viewControllers?.first as! MenuViewController
        if let userName = loginNameTextField.text{
            menuController.userName = userName
        }
        return controller
    }
    
}
