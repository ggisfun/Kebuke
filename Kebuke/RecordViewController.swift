//
//  RecordViewController.swift
//  Kebuke
//
//  Created by Adam Chen on 2024/9/4.
//

import UIKit

class RecordViewController: UIViewController {

    @IBOutlet weak var recordTableView: UITableView!
    var orderRecord = [Record]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //獲取訂單記錄
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //獲取訂單記錄
        fetchData()
    }
    
    func fetchData() {
        let url = URL(string: "https://api.airtable.com/v0/appIJuX7xoYEEZrDd/Kebuke?sort%5B0%5D%5Bfield%5D=orderDate&sort%5B0%5D%5Bdirection%5D=desc")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(APIKey.default)", forHTTPHeaderField: "Authorization")
                
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
            
            let decoder = JSONDecoder()
            do {
                let orderData = try decoder.decode(OrderData.self, from: data)
                self.orderRecord = orderData.records
                DispatchQueue.main.async {
                    self.recordTableView.reloadData()
                }
                                                                
            } catch {
                print(error)
            }
            
        }.resume()
    }
}

extension RecordViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        orderRecord.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(RecordTableViewCell.self)", for: indexPath) as! RecordTableViewCell
        
        //清空圖片避免出現舊圖片
        cell.drinkImageView.image = nil
        
        let item = orderRecord[indexPath.row].fields
        cell.drinkImageView.clipsToBounds = true
        cell.drinkImageView.layer.cornerRadius = 10
        cell.drinkImageView.kf.setImage(with: item.imgUrl)
        cell.drinkNameLabel.text = item.drink
        cell.drinkSizeLabel.text = item.size
        cell.iceLevelLabel.text = item.ice
        cell.sugarLevelLabel.text = item.sweet
        cell.orderDateLabel.text = "\(item.orderDate.split(separator: "T")[0])"
        cell.userNameLabel.text = item.name
        cell.quantityLabel.text = "\(item.quantity)杯"
        cell.priceLabel.text = "$\(item.price)"
                        
        if let extraAdd = item.extra{
            var textArray = [String]()
            let extraArray = extraAdd.split(separator: ",")
            for text in extraArray {
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
            cell.extraAddLabel.text = item.extra
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
    
}
