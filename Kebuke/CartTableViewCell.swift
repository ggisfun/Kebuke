//
//  CartTableViewCell.swift
//  Kebuke
//
//  Created by Adam Chen on 2024/9/3.
//

import UIKit

class CartTableViewCell: UITableViewCell {

    @IBOutlet weak var drinkImageView: UIImageView!
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var drinkSizeLabel: UILabel!
    @IBOutlet weak var iceLevelLabel: UILabel!
    @IBOutlet weak var sugarLevelLabel: UILabel!
    @IBOutlet weak var extraAddLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityAddButton: UIButton!
    @IBOutlet weak var quantityMinusButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
