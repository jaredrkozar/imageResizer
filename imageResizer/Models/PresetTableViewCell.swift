//
//  PresetTableViewCell.swift
//  imageResizer
//
//  Created by JaredKozar on 12/30/21.
//

import UIKit

class PresetTableViewCell: UITableViewCell {

    @IBOutlet var dimension: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.accessoryType = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        self.accessoryType = selected ? .checkmark : .none
    }
    
}
