//
//  DataController.swift
//  grokHTMLAndDownloads
//
//  Created by Christina Moulton on 2015-10-12.
//  Copyright © 2015 Teak Mobile Inc. All rights reserved.
//

import Foundation
import Alamofire
import HTMLReader

let URLString = "http://www.charts.noaa.gov/PDFs/PDFs.shtml"

class DataController {
  var charts: [Chart]?
  
  init() {
    fetchCharts()
  }
  
  func fetchCharts() {

  }
}
