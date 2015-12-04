//
//  ChartCell.swift
//  grokHTMLAndDownloads
//
//  Created by Christina Moulton on 2015-12-04.
//  Copyright © 2015 Teak Mobile Inc. All rights reserved.
//

import Foundation
import UIKit

class ChartCell: UITableViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var progressBar: UIProgressView!
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    titleLabel.text = ""
    progressBar.progress = 0
    progressBar.hidden = true
    accessoryType = .None
  }
}