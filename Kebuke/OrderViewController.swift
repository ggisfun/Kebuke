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
    
    var optionInfo: [[DrinkOption]] = [
        [
            DrinkOption(type: .cupSize, option: "中杯", isSelected: false),
            DrinkOption(type: .cupSize, option: "大杯", isSelected: false)
        ],
        [
            DrinkOption(type: .iceLevel, option: "正常冰", isSelected: false),
            DrinkOption(type: .iceLevel, option: "少冰", isSelected: false),
            DrinkOption(type: .iceLevel, option: "微冰", isSelected: false),
            DrinkOption(type: .iceLevel, option: "去冰", isSelected: false),
            DrinkOption(type: .iceLevel, option: "完全去冰", isSelected: false)
        ],
        [
            DrinkOption(type: .sugarLevel, option: "正常糖", isSelected: false),
            DrinkOption(type: .sugarLevel, option: "少糖", isSelected: false),
            DrinkOption(type: .sugarLevel, option: "半糖", isSelected: false),
            DrinkOption(type: .sugarLevel, option: "微糖", isSelected: false),
            DrinkOption(type: .sugarLevel, option: "一分糖", isSelected: false),
            DrinkOption(type: .sugarLevel, option: "無糖", isSelected: false)
        ],
        [
            DrinkOption(type: .topping, option: "白玉", isSelected: false),
            DrinkOption(type: .topping, option: "水玉", isSelected: false),
            DrinkOption(type: .topping, option: "菓玉", isSelected: false)
        ]
    ]
    
    var addPrice = 0
    var showType : Int?
    var cartIndex : Int?
    var extraArray = [Int]()
    
    //購物車
    var cartName = ""
    var cartSize = ""
    var cartIceLevel = ""
    var cartSugarLevel = ""
    var cartExtraAdd = ""
    var cartImgUrl = ""
    var cartPrice = 0
    var cartQuantity = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        optionForHot()
        
        if showType == 1 {
            updateOptionInfo()
            quantity = cart!.quantity
            cartSize = cart!.size
            cartIceLevel = cart!.iceLevel
            cartSugarLevel = cart!.sugarLevel
            cartExtraAdd = cart!.extraAdd
            cartPrice = cart!.price
            cartQuantity = cart!.quantity
        }
        
        for (i,item) in optionInfo[3].enumerated(){
            if item.isSelected {
                extraArray.append(i)
            }
        }
        
        updatePrice()
        
        drinkImageView.kf.setImage(with: drinkData.info.imgUrl)
        drinkNameLabel.text = drinkData.name
        drinkPriceLabel.text = "$\(drinkData.info.m)"
        descriptionLabel.text = drinkData.info.description
        quantityLabel.text = "\(quantity)"
        addPrice = drinkData.info.l - drinkData.info.m
        
        cartName = drinkData.name
        cartImgUrl = "\(drinkData.info.imgUrl)"
        
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
        cart = CartInfo(drinkName: cartName, size: cartSize, iceLevel: cartIceLevel, sugarLevel: cartSugarLevel, extraAdd: cartExtraAdd, imgUrl: URL(string: cartImgUrl)!, price: cartPrice, quantity: cartQuantity, sizeM: drinkData.info.m, sizeL: drinkData.info.l, description: drinkData.info.description, hot: drinkData.info.hot)
    }
    
    @IBAction func cartAddOrEdited(_ sender: Any) {
        guard cartSize.isEmpty == false else {
            alertMessage(type: 0)
            return
        }
        guard cartIceLevel.isEmpty == false else {
            alertMessage(type: 1)
            return
        }
        guard cartSugarLevel.isEmpty == false else {
            alertMessage(type: 2)
            return
        }
        
        if showType == 0 {
            performSegue(withIdentifier: "unwindToMenu", sender: nil)
        }else{
            performSegue(withIdentifier: "unwindToCart", sender: nil)
        }
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
        updatePrice()
    }
    
    func optionForHot(){
        if drinkData.info.hot {
            optionInfo[1] = [
                DrinkOption(type: .iceLevel, option: "正常冰", isSelected: false),
                DrinkOption(type: .iceLevel, option: "少冰", isSelected: false),
                DrinkOption(type: .iceLevel, option: "微冰", isSelected: false),
                DrinkOption(type: .iceLevel, option: "去冰", isSelected: false),
                DrinkOption(type: .iceLevel, option: "完全去冰", isSelected: false),
                DrinkOption(type: .iceLevel, option: "常溫", isSelected: false),
                DrinkOption(type: .iceLevel, option: "溫", isSelected: false),
                DrinkOption(type: .iceLevel, option: "熱", isSelected: false),
            ]
        }
    }
    
    func updateOptionInfo(){
        if cart?.size == "中杯" {
            optionInfo[0][0].isSelected = true
        }else {
            optionInfo[0][1].isSelected = true
        }
        
        for (i,item) in optionInfo[1].enumerated() {
            if item.option == cart!.iceLevel {
                optionInfo[1][i].isSelected = true
            }
        }
        
        for (i,item) in optionInfo[2].enumerated() {
            if item.option == cart!.sugarLevel {
                optionInfo[2][i].isSelected = true
            }
        }
        
        let array = cart?.extraAdd.split(separator: ",")
        if array?.count ?? 0 > 0 {
            for item in array! {
                if item.hasPrefix("白玉") {
                    optionInfo[3][0].isSelected = true
                }else if item.hasPrefix("水玉") {
                    optionInfo[3][1].isSelected = true
                }else if item.hasPrefix("菓玉") {
                    optionInfo[3][2].isSelected = true
                }
            }
        }
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
        return optionInfo[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(OrderTableViewCell.self)", for: indexPath) as! OrderTableViewCell
        
        //清空圖片避免出現舊圖片
        cell.checkBoxImageView.image = nil
        
        let item = optionInfo[indexPath.section][indexPath.row]
        cell.checkBoxImageView.image = optionInfo[indexPath.section][indexPath.row].isSelected ? UIImage(named: "check") : UIImage(named: "checkbox")
        
        if indexPath.section == 0 && indexPath.row == 1 {
            cell.optionLabel.text = "\(item.option) +$\(addPrice)"
        }else if indexPath.section == 3 {
            if indexPath.row == 2 {
                cell.optionLabel.text = "\(item.option)(不可做溫熱飲) +$10"
            }else{
                cell.optionLabel.text = "\(item.option) +$10"
            }
        }else{
            cell.optionLabel.text = "\(item.option)"
        }
        
        cell.selectionStyle = .none

        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let section = indexPath.section
        let row = indexPath.row
        
        if section != 3{
            for i in 0..<optionInfo[section].count{
                optionInfo[section][i].isSelected = false
            }
        }else {
            if extraArray.count == 2 {
                if !extraArray.contains(row) {
                    let i = extraArray.first!
                    extraArray.removeFirst()
                    optionInfo[section][i].isSelected = false
                }
            }
        }
        tableView.reloadData()
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        optionInfo[section][row].isSelected.toggle()
        let cell = tableView.cellForRow(at: indexPath) as! OrderTableViewCell
        cell.checkBoxImageView.image = optionInfo[section][row].isSelected ? UIImage(named: "check") : UIImage(named: "checkbox")
        
        if section == 3 {
            if optionInfo[section][row].isSelected {
                extraArray.append(row)
            }else{
                if let indexToRemove = extraArray.firstIndex(of: row) {
                    extraArray.remove(at: indexToRemove)
                }
            }
        }
        
        updatePrice()
        updateCarItem()
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        let section = indexPath.section
        let row = indexPath.row
        
        if section != 3 {
            for i in 0..<optionInfo[section].count{
                optionInfo[section][i].isSelected = false
            }
        }else {
            if extraArray.count == 2 {
                if !extraArray.contains(row) {
                    let i = extraArray.first!
                    extraArray.removeFirst()
                    optionInfo[section][i].isSelected = false
                }
            }
        }
        tableView.reloadData()
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        optionInfo[section][row].isSelected.toggle()
        let cell = tableView.cellForRow(at: indexPath) as! OrderTableViewCell
        cell.checkBoxImageView.image = optionInfo[section][row].isSelected ? UIImage(named: "check") : UIImage(named: "checkbox")
        
        if section == 3 {
            if optionInfo[section][row].isSelected {
                extraArray.append(row)
            }else{
                if let indexToRemove = extraArray.firstIndex(of: row) {
                    extraArray.remove(at: indexToRemove)
                }
            }
        }
        
        updatePrice()
        updateCarItem()
    }
        
    func updatePrice(){
        drinkPrice = optionInfo[0][1].isSelected ? drinkData.info.l: drinkData.info.m
        extraCount = extraArray.count
        
        let totalPrice = (drinkPrice + (extraCount * 10)) * quantity
        cartQuantity = quantity
        cartPrice = totalPrice
        
        if showType == 0 {
            addToCarButton.setTitle("加入購物車・$\(totalPrice)", for: .normal)
        }else {
            addToCarButton.setTitle("更新購物車・$\(totalPrice)", for: .normal)
        }
    }
    
    func updateCarItem(){
        for item in optionInfo[0]{
            if item.isSelected{
                if item.option == "大杯"{
                    cartSize = "大杯 +$\(addPrice)"
                }else{
                    cartSize = item.option
                }
            }
        }
        
        for item in optionInfo[1]{
            if item.isSelected{
                cartIceLevel = item.option
            }
        }
        
        for item in optionInfo[2]{
            if item.isSelected{
                cartSugarLevel = item.option
            }
        }
        
        var extraText = ""
        var tempExtraAdd = [String]()
        for item in extraArray{
            if item == 2 {
                extraText = "\(optionInfo[3][item].option)(不可做溫熱飲) +$10"
            }else{
                extraText = "\(optionInfo[3][item].option) +$10"
            }
            tempExtraAdd.append(extraText)
        }
        cartExtraAdd = tempExtraAdd.joined(separator: ",")
    }
    
    
}
