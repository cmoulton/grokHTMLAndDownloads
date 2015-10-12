//
//  Chart.swift
//  grokHTMLAndDownloads
//
//  Created by Christina Moulton on 2015-10-12.
//  Copyright © 2015 Teak Mobile Inc. All rights reserved.
//

import Foundation

class Chart {
  let title: String
  let url: String
  let number: Int
  let scale: Int

  required init(title: String, url: String, number: Int, scale: Int) {
    self.title = title
    self.url = url
    self.number = number
    self.scale = scale
  }
}