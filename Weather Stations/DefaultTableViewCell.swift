//
//  DefaultTableViewCell.swift
//  Weather Stations
//
//  Created by Abdullah Alradadi on 7/30/17.
//  Copyright © 2017 Abdullah Alradadi. All rights reserved.
//

import UIKit

class DefaultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var stationDist: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
