//
//  CartItem.swift
//  Kebuke
//
//  Created by Adam Chen on 2024/9/1.
//

import Foundation

struct CartInfo: Codable {
    var drinkName: String
    var size: String
    var iceLevel: String
    var sugarLevel: String
    var extraAdd: String
    var imgUrl: URL
    var price: Int
    var quantity: Int
}

struct OrderData: Codable {
    let records: [Record]
}

struct Record: Codable {
    let fields: OrderInfo
}

struct OrderInfo: Codable {
    let name: String
    let drink: String
    let size: String
    let sweet: String
    let ice: String
    let extra: String?
    let quantity: Int
    let price: Int
    let orderDate: String
    let imgUrl: URL
}

