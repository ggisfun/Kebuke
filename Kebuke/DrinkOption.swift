//
//  DrinkOption.swift
//  Kebuke
//
//  Created by Adam Chen on 2024/9/10.
//
struct DrinkOption {
    let type: OptionType
    var option: String
    var isSelected: Bool
}

enum OptionType {
    case cupSize
    case iceLevel
    case sugarLevel
    case topping
}
