//
//  CartViewController.swift
//  Kebuke
//
//  Created by Adam Chen on 2024/9/3.
//

import UIKit

class CartViewController: UIViewController {
    
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var orderConfirmButton: UIButton!
    @IBOutlet weak var emptyCartView: UIView!
    
    weak var delegate: CartViewControllerDelegate?
    
    
    var carts = [CartInfo]()
    var userName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emptyCartView.isHidden = true
        if carts.count == 0{
            orderConfirmButton.isHidden = true
        }
    }
    
    @IBAction func unwindToCartViewController(_ unwindSegue: UIStoryboardSegue) {
        if let source = unwindSegue.source as? OrderViewController,
           let cart = source.cart,
           let index = source.cartIndex{
            carts[index] = cart
            cartTableView.reloadData()
            delegate?.cartViewController(self, didUpdateCart: carts)
        }
    }
    
    @IBSegueAction func showOrderEdit(_ coder: NSCoder) -> OrderViewController? {
        guard let item = cartTableView.indexPathForSelectedRow?.row else {return nil}
        
        let drink = Drink(name: carts[item].drinkName, info: DrinkInfo(m: carts[item].sizeM, l: carts[item].sizeL, description: carts[item].description, sugar_info: nil, hot: carts[item].hot, notes: nil, imgUrl: carts[item].imgUrl))
        
        let controller =  OrderViewController(coder: coder)
        
        controller?.drinkData = drink
        controller?.cart = carts[item]
        controller?.showType = 1
        controller?.cartIndex = item
        
        return controller
    }
    
    @IBAction func quantityAdd(_ sender: UIButton) {
        let row = sender.tag
        let singlePrice = carts[row].price / carts[row].quantity
        let quantity = carts[row].quantity + 1
        carts[row].quantity = quantity
        carts[row].price = singlePrice * quantity
        
        cartTableView.reloadData()
        delegate?.cartViewController(self, didUpdateCart: carts)
    }
    
    @IBAction func quantityMinus(_ sender: UIButton) {
        let row = sender.tag        
        let singlePrice = carts[row].price / carts[row].quantity
        let quantity = carts[row].quantity - 1
        
        if quantity == 0 {
            carts.remove(at: row)
            orderConfirmButton.isHidden = true
        }else{
            carts[row].quantity = quantity
            carts[row].price = singlePrice * quantity
        }
        
        cartTableView.reloadData()
        delegate?.cartViewController(self, didUpdateCart: carts)
    }
    
    @IBAction func senderOrder(_ sender: Any) {
        //取得當前日期
        let dateFormatter = ISO8601DateFormatter()
        let today = Date()
        let orderDate = dateFormatter.string(from: today)
        
        //
        var orderRecord = [Record]()
        for item in carts {
            let orderinfo = Record(fields:OrderInfo(name: userName, drink: item.drinkName, size: item.size, sweet: item.sugarLevel, ice: item.iceLevel, extra: item.extraAdd, quantity: item.quantity, price: item.price, orderDate: orderDate, imgUrl: item.imgUrl))
            orderRecord.append(orderinfo)
        }
        let orderData = OrderData(records: orderRecord)
        
        do {
            //將訂單資料JSON編碼＆發送到伺服器
            let jsonData = try JSONEncoder().encode(orderData)
            sendOrderToServer(jsonData: jsonData)
            
            let alert = UIAlertController(title: "送出訂單囉！😀", message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "確定", style: .default))
            present(alert, animated: true)
        } catch {
            print("編碼錯誤: \(error)")
        }
        
        carts.removeAll()
        cartTableView.reloadData()
        updatePrice()
        orderConfirmButton.isHidden = true
        delegate?.cartViewController(self, didUpdateCart: carts)
    }
    
    //將訂單發送到伺服器
    func sendOrderToServer(jsonData: Data) {
        let url = URL(string: "https://api.airtable.com/v0/appIJuX7xoYEEZrDd/Kebuke")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(APIKey.default)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        //發送請求
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print(error)
                return
            }
            guard let responseCode = response as? HTTPURLResponse,
                  responseCode.statusCode == 200 else {
                print("StatusCode Error")
                return
            }
            guard let data else {
                print("Data Error")
                return
            }
            print("Success", data)
        }.resume()
    }
    
}

protocol CartViewControllerDelegate: AnyObject {
    func cartViewController(_ controller: CartViewController, didUpdateCart cart: [CartInfo])
}

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if carts.count == 0 {
            emptyCartView.isHidden = false
        }
        return carts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(CartTableViewCell.self)", for: indexPath) as! CartTableViewCell
        
        //清空圖片避免出現舊圖片
        cell.drinkImageView.image = nil
        
        let item = carts[indexPath.row]
        cell.drinkImageView.layer.cornerRadius = 10
        cell.drinkImageView.clipsToBounds = true
        cell.drinkImageView.kf.setImage(with: item.imgUrl)
        cell.drinkNameLabel.text = item.drinkName
        cell.drinkSizeLabel.text = item.size
        cell.iceLevelLabel.text = item.iceLevel
        cell.sugarLevelLabel.text = item.sugarLevel
        cell.quantityLabel.text = "\(item.quantity)"
        cell.priceLabel.text = "$\(item.price)"
        
        if item.extraAdd.isEmpty != true {
            var textArray = [String]()
            let extraAdd = item.extraAdd.split(separator: ",")
            for text in extraAdd{
                if text.hasPrefix("菓玉"){
                    textArray.append(text.replacingOccurrences(of: "(不可做溫熱飲)", with: ""))
                }else{
                    textArray.append(String(text))
                }
            }
            
            if textArray.count > 1{
                cell.extraAddLabel.text = "\(textArray[0])\n\(textArray[1])"
            }else{
                cell.extraAddLabel.text = "\(textArray[0])\n"
            }
        }else{
            cell.extraAddLabel.text = item.extraAdd
        }
        
        cell.quantityAddButton.tag = indexPath.row
        cell.quantityMinusButton.tag = indexPath.row
        if item.quantity > 1 {
            cell.quantityMinusButton.setImage(UIImage(systemName: "minus"), for: .normal)
        }else {
            cell.quantityMinusButton.setImage(UIImage(systemName: "trash"), for: .normal)
        }
        
        updatePrice()
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        carts.remove(at: indexPath.row)
        updatePrice()
        if carts.count == 0 {
            orderConfirmButton.isHidden = true
        }
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadData()
        delegate?.cartViewController(self, didUpdateCart: carts)
    }
    
    
    func updatePrice(){
        var totalPrice = 0
        for item in carts{
            totalPrice += item.price
        }
        orderConfirmButton.setTitle("送出訂單・$\(totalPrice)", for: .normal)
    }
    
    
}
