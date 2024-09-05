//
//  MenuViewController.swift
//  Kebuke
//
//  Created by Adam Chen on 2024/8/28.
//

import UIKit
import Kingfisher

class MenuViewController: UIViewController {

    @IBOutlet weak var frontPageImageView: UIImageView!
    @IBOutlet weak var frontPageControl: UIPageControl!
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var menuCollectionView: UICollectionView!
    @IBOutlet weak var cartButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var userName = ""
    var carts = [CartInfo]()
    var drinkList = [Drink]()
    var categoryIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //使用者名稱
        userNameLabel.text = "Hi!\n\(userName)"
        
        //輪播
        let timerProgress = UIPageControlTimerProgress(preferredDuration: 2)
        frontPageControl.progress = timerProgress
        timerProgress.resetsToInitialPageAfterEnd = true
        timerProgress.resumeTimer()
        
        //SegmentedControl字體顏色
        categorySegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        
        //獲取飲品資料
        fetchData()
        
    }
    
    @IBAction func frontPageControlValueChanged(_ sender: UIPageControl) {
        frontPageImageView.image = UIImage(named: "frontPage0\(sender.currentPage)")
    }
    
    @IBAction func categorySelected(_ sender: Any) {
        categoryIndex = categorySegmentedControl.selectedSegmentIndex
        fetchData()
    }
    
    @IBAction func unwindToMenuViewController(_ unwindSegue: UIStoryboardSegue) {
        if let source = unwindSegue.source as? OrderViewController,
           let cart = source.cart{
            carts.insert(cart, at: 0)
            showBadge(count: carts.count)
        }
        
    }
    
    
    @IBSegueAction func showCartPage(_ coder: NSCoder) -> CartViewController? {
        guard carts.count > 0 else {return nil}
        let cartViewController =  CartViewController(coder: coder)
        cartViewController?.delegate = self
        cartViewController?.carts = carts
        cartViewController?.userName = userName
        return cartViewController
    }
    
    
    @IBSegueAction func showOrderPage(_ coder: NSCoder) -> OrderViewController? {
        guard let item = menuCollectionView.indexPathsForSelectedItems?[0].item else {return nil}
        let controller =  OrderViewController(coder: coder)
        controller?.drinkData = drinkList[item]
        return controller
    }
    
    func fetchData() {
        let urlStr = "https://raw.githubusercontent.com/ggisfun/KebukeJson/main/kebuke_menu.json"
        if let url = URL(string: urlStr) {
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
            URLSession.shared.dataTask(with: request) { data, response , error in
                if let data,
                   let response = response as? HTTPURLResponse,
                   response.statusCode == 200,
                   error == nil{
                    let decoder = JSONDecoder()
                    do {
                        let drinkMenu = try decoder.decode([DrinkMenu].self, from: data)
                        self.drinkList = drinkMenu[self.categoryIndex].drinks
                        DispatchQueue.main.async {
                            self.menuCollectionView.reloadData()
                        }
                                                                        
                    } catch {
                        print(error)
                    }
                } else {
                    print(error ?? "Data Error")
                }
            }.resume()
        }
    }
    
    lazy var badgeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.cornerRadius = label.bounds.size.height / 2
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.textColor = .white
        label.font = label.font.withSize(12)
        label.backgroundColor = .systemRed
        return label
    }()
    
    func showBadge(count: Int) {
        badgeLabel.text = "\(count)"
        cartButton.addSubview(badgeLabel)
        let constraints = [
            badgeLabel.leftAnchor.constraint(equalTo: cartButton.centerXAnchor, constant: 6),
            badgeLabel.topAnchor.constraint(equalTo: cartButton.topAnchor, constant: -2),
            badgeLabel.widthAnchor.constraint(equalToConstant: 16),
            badgeLabel.heightAnchor.constraint(equalToConstant: 16)
        ]
        NSLayoutConstraint.activate(constraints)
    }

}


extension MenuViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        drinkList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(MenuCollectionViewCell.self)", for: indexPath) as! MenuCollectionViewCell
        
        //清空圖片避免出現舊圖片
        cell.hotImageView.image = nil
        
        let item = drinkList[indexPath.item]
        cell.drinkImgaeView.clipsToBounds = true
        cell.drinkImgaeView.layer.cornerRadius = 10
        cell.drinkImgaeView.kf.setImage(with: item.info.imgUrl)
        cell.drinkNameLabel.text = item.name
        cell.drinkPriceLabel.text = "$\(item.info.m)"
        if item.info.hot {
            cell.hotImageView.image = UIImage(named: "hot")
        }
        
        return cell
    }
    
    
}

extension MenuViewController: CartViewControllerDelegate {
    func cartViewController(_ controller: CartViewController, didUpdateCart cart: [CartInfo]) {
        carts = cart
        if carts.count > 0 {
            showBadge(count: carts.count)
        }else{
            badgeLabel.removeFromSuperview()
        }
    }
}
