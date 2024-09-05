//
//  OrderTableViewCell.swift
//  Kebuke
//
//  Created by Adam Chen on 2024/8/29.
//

import UIKit

class OrderTableViewCell: UITableViewCell {

    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var checkBoxImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool ) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        checkBoxImageView.image = selected ? UIImage(named: "check") : UIImage(named: "checkbox")
                
    }
    

}
