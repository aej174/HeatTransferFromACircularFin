//
//  ProfileCell.swift
//  HeatTransferToACircularFin
//
//  Created by Allan Jones on 6/8/15.
//  Copyright (c) 2015 Allan Jones. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {
  
  @IBOutlet weak var segmentNumberLabel: UILabel!
  @IBOutlet weak var segmentTemperatureLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
        // Initialization code
  }

  override func setSelected(selected: Bool, animated:Bool) {
    super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
  }

}
