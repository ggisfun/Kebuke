//
//  MenuItem.swift
//  Kebuke
//
//  Created by Adam Chen on 2024/8/28.
//

import Foundation

struct DrinkMenu: Codable {
    let category: String
    let drinks: [Drink]
}

struct Drink: Codable {
    let name: String
    let info: DrinkInfo
}

struct DrinkInfo: Codable {
    let m: Int
    let l: Int
    let description: String
    let sugar_info: SugarInfo?
    let hot: Bool
    let notes: String?
    let imgUrl: URL
}

struct SugarInfo: Codable {
    let m: SugarDetails
    let l: SugarDetails
}

struct SugarDetails: Codable {
    let sugar: String
    let calories: String
    let caffeine: String
    let vegetarian: String
}
