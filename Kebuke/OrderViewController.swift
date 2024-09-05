//
//  OrderViewController.swift
//  Kebuke
//
//  Created by Adam Chen on 2024/8/29.
//

import UIKit

class OrderViewController: UIViewController {
    
    @IBOutlet weak var drinkImageView: UIImageView!
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var drinkPriceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var orderTableView: UITableView!
    @IBOutlet weak var addToCarButton: UIButton!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet var quantityButtons: [UIButton]!
    
    var cart : CartInfo?
    var drinkData : Drink!
    var drinkPrice = 0
    var extraCount = 0
    var quantity = 1
    var optionInfo = [
        ["中杯", "大杯"],
        ["正常冰", "少冰", "微冰", "去冰", "完全去冰"],
        ["正常糖", "少糖", "半糖", "微糖", "一分糖", "無糖"],
        ["白玉", "水玉", "菓玉"]
    ]
    var addPrice = 0
    
    var cartName = ""
    var cartSize = ""
    var cartIceLevel = ""
    var cartSugarLevel = ""
    var cartExtraAdd = ""
    var cartImgUrl = ""
    var cartPrice = 0
    var cartQuantity = 0
    var tempExtraAdd = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        drinkImageView.kf.setImage(with: drinkData.info.imgUrl)
        drinkNameLabel.text = drinkData.name
        drinkPriceLabel.text = "$\(drinkData.info.m)"
        descriptionLabel.text = drinkData.info.description
        quantityLabel.text = "\(quantity)"
        drinkPrice = drinkData.info.m
        addToCarButton.setTitle("加入購物車・$\(drinkPrice)", for: .normal)
        addPrice = drinkData.info.l - drinkData.info.m
        
        cartName = drinkData.name
        cartImgUrl = "\(drinkData.info.imgUrl)"
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard cartSize.isEmpty == false else {
            alertMessage(type: 0)
            return false
        }
        guard cartIceLevel.isEmpty == false else {
            alertMessage(type: 1)
            return false
        }
        guard cartSugarLevel.isEmpty == false else {
            alertMessage(type: 2)
            return false
        }
        return true
    }
    
    func alertMessage(type:Int){
        var title = ""
        if type == 0 {
            title = "請選擇尺寸"
        }else if type == 1 {
            title = "請選擇飲品溫度"
        }else {
            title = "請選擇甜度"
        }
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        cart = CartInfo(drinkName: cartName, size: cartSize, iceLevel: cartIceLevel, sugarLevel: cartSugarLevel, extraAdd: cartExtraAdd, imgUrl: URL(string: cartImgUrl)!, price: cartPrice, quantity: cartQuantity)
    }
    
    @IBAction func quantityAddOrMinus(_ sender: UIButton) {
        if sender.tag == 1{
            quantity += 1
        }else{
            if quantity > 1{
                quantity -= 1
            }
        }
        quantityLabel.text = "\(quantity)"
        updatePrice(drinkPrice: drinkPrice, extraCount: extraCount, quantity: quantity)
    }

}

extension OrderViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        optionInfo.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 30))
        header.backgroundColor = UIColor(red: 8/255, green: 63/255, blue: 83/255, alpha: 1)
        
        var title = ""
        switch section {
        case 0: title = "尺寸"
        case 1: title = "飲品溫度"
        case 2: title = "甜度選擇"
        case 3: title = "加料(最多選擇2項)"
        default : break
        }
        
        let label = UILabel(frame: CGRect(x: 20, y: 5, width: 200, height: header.frame.size.height - 15))
        label.font = label.font.withSize(18)
        label.textColor = .white
        label.text = title
        header.addSubview(label)
        
        return header
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
        
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if drinkData.info.hot {
            optionInfo[1] = ["正常冰", "少冰", "微冰", "去冰", "完全去冰", "常溫", "溫", "熱"]
        }
        
        return optionInfo[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(OrderTableViewCell.self)", for: indexPath) as! OrderTableViewCell
              
        //清空圖片避免出現舊圖片
        cell.checkBoxImageView.image = nil
        
        let item = optionInfo[indexPath.section][indexPath.row]
        
        if indexPath.section == 0 && indexPath.row == 1 {
            cell.optionLabel.text = "\(item) +$\(addPrice)"
        }else if indexPath.section == 3 {
            if indexPath.row == 2 {
                cell.optionLabel.text = "\(item)(不可做溫熱飲) +$10"
            }else{
                cell.optionLabel.text = "\(item) +$10"
            }
        }else{
            cell.optionLabel.text = "\(item)"
        }
        
        cell.selectionStyle = .none

        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        extraCount = tableView.indexPathsForSelectedRows?.count(where:{
            $0.section == 3
        }) ?? 0
        
        if indexPath.section != 3 || extraCount == 2{
            if let selectIndexPathInSection = tableView.indexPathsForSelectedRows?.first(where: {
                $0.section == indexPath.section
               }) {
                tableView.deselectRow(at: selectIndexPathInSection, animated: false)
            }
        }
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == [0, 1]{
            drinkPrice = drinkData.info.l
        }else if indexPath == [0, 0]{
            drinkPrice = drinkData.info.m
        }
        
        extraCount = tableView.indexPathsForSelectedRows?.count(where:{
            $0.section == 3
        }) ?? 0
 
        if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows{
            for index in indexPathsForVisibleRows{
                if index.section == indexPath.section{
                    let cell = tableView.cellForRow(at: index) as! OrderTableViewCell
                    cell.isUserInteractionEnabled = true
                }
            }
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! OrderTableViewCell
        if indexPath.section != 3 {
            cell.isUserInteractionEnabled = false
        }

        updatePrice(drinkPrice: drinkPrice, extraCount: extraCount, quantity: quantity)
        updateCartItem(section: indexPath.section, content: cell.optionLabel.text!, type: 0)
        
    }
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if indexPath == [0, 1]{
            drinkPrice = drinkData.info.l
        }else if indexPath == [0, 0]{
            drinkPrice = drinkData.info.m
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! OrderTableViewCell
        extraCount = tableView.indexPathsForSelectedRows?.count(where:{
            $0.section == 3
        }) ?? 0
        
        updatePrice(drinkPrice: drinkPrice, extraCount: extraCount, quantity: quantity)
        updateCartItem(section: indexPath.section, content: cell.optionLabel.text!, type: 1)

    }
    
    func updatePrice(drinkPrice: Int, extraCount: Int, quantity: Int){
        var totalPrice = 0
        totalPrice = (drinkPrice + (extraCount*10))*quantity
        
        cartQuantity = quantity
        cartPrice = totalPrice
        addToCarButton.setTitle("加入購物車・$\(totalPrice)", for: .normal)
        
    }
    
    func updateCartItem(section: Int, content: String, type: Int){
        switch section {
        case 0:
            cartSize = content
        case 1:
            cartIceLevel = content
        case 2:
            cartSugarLevel = content
        case 3:
            if type == 0 {
                tempExtraAdd.append(content)
                if tempExtraAdd.count > 2{
                    tempExtraAdd.removeFirst()
                }
            }else{
                for (i,item) in tempExtraAdd.enumerated(){
                    if item == content{
                        tempExtraAdd.remove(at: i)
                    }
                }
            }
            cartExtraAdd = tempExtraAdd.joined(separator: ",")
        default:
            return
        }
    }
    
    
}
