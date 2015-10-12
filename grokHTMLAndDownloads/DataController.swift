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
  
  func chartsCount() -> Int {
    return charts?.count ?? 0
  }
  
  func chartAtIndex(index: Int) -> Chart? {
    guard let charts = charts else {
      return nil
    }
    guard index >= 0 || index < charts.count else {
      return nil
    }
    return charts[index]
  }
  
  func fetchCharts(completionHandler: (NSError?) -> Void) {
    Alamofire.request(.GET, URLString)
      .responseString { responseString in
        if let htmlAsString = responseString.result.value {
          // TODO checks from Alamofire page
          let doc = HTMLDocument(string: htmlAsString)
          if let tableContents = doc.firstNodeMatchingSelector("tbody") {
            self.charts = []
            for row in tableContents.children {
              var url: String?
              var number: Int?
              var scale: Int?
              var title: String?
              if let rowElement = row as? HTMLElement { // TODO: should be able to combine this with loop above
                // first column: URL and number
                if let firstColumn = rowElement.children[0] as? HTMLElement {
                  // skip the first row, or any other where the first row doesn't contain a number
                  if let entry = firstColumn.childAtIndex(0) as? HTMLElement {
                    url = entry.objectForKeyedSubscript("href") as? String
                    if let contents = entry.childAtIndex(0) as? HTMLTextNode {
                      number = Int(contents.textContent)
                    }
                  }
                }
                // second column: Scale
                if (url == nil) {
                  continue // can't do anything without a URL, e.g., the header row
                }
                if let secondColumn = rowElement.children[1] as? HTMLElement {
                  if let entry = secondColumn.childAtIndex(0) as? HTMLTextNode {
                    scale = Int(entry.textContent)
                  }
                }
                // third column: Name
                if let thirdColumn = rowElement.children[2] as? HTMLElement {
                  if let entry = thirdColumn.childAtIndex(0) as? HTMLTextNode {
                    title = entry.textContent
                  }
                }

                if let title = title, url = url, number = number, scale = scale {
                  let newChart = Chart(title: title, url: url, number: number, scale: scale)
                  self.charts?.append(newChart)
                }
              }
            }
          }
        }
        // TODO: bubble up errors
        completionHandler(nil)
    }
  }
}
