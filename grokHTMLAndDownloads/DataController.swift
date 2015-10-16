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

let URLString = "http://ocsdata.ncd.noaa.gov/BookletChart/AtlanticCoastBookletCharts.htm"

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
          
          // find the table of charts in the HTML
          let tables = doc.nodesMatchingSelector("tbody")
          var chartsTable:HTMLElement?
          for table in tables {
            if let tableElement = table as? HTMLElement {
              if tableElement.children.count > 0 {
                let firstChild = tableElement.childAtIndex(0)
                let lowerCaseContent = firstChild.textContent.lowercaseString
                if lowerCaseContent.containsString("number") && lowerCaseContent.containsString("scale") && lowerCaseContent.containsString("title") {
                  chartsTable = tableElement
                  break;
                }
              }
            }
          }
          // make sure we found the table of charts
          guard let tableContents = chartsTable else {
            // TODO: error
            completionHandler(nil)
            return
          }
          
          self.charts = []
          for row in tableContents.children {
            var url: NSURL?
            var number: Int?
            var scale: Int?
            var title: String?
            if let rowElement = row as? HTMLElement { // TODO: should be able to combine this with loop above
              // first column: URL and number
              if let firstColumn = rowElement.childAtIndex(1) as? HTMLElement {
                // skip the first row, or any other where the first row doesn't contain a number
                if let entry = firstColumn.childAtIndex(1) as? HTMLElement {
                  if let urlNode = entry.firstNodeMatchingSelector("a") {
                    if let urlString = urlNode.objectForKeyedSubscript("href") as? String {
                      url = NSURL(string: urlString)
                    }
                  }
                  if (firstColumn.children.count > 1) {
                    let contents = firstColumn.childAtIndex(1).textContent
                    // need to make sure it's a number
                    number = Int(contents)
                  }
                  if (url == nil || number == nil) {
                    continue // can't do anything without a URL, e.g., the header row
                  }
                }
              }
              
              if let secondColumn = rowElement.childAtIndex(3) as? HTMLElement {
                if let entry = secondColumn.childAtIndex(1) as? HTMLElement {
                  scale = Int(entry.textContent.stringByReplacingOccurrencesOfString(",", withString: ""))
                }
              }
              // third column: Name
              if let thirdColumn = rowElement.childAtIndex(5) as? HTMLElement {
                if let entry = thirdColumn.childAtIndex(1) as? HTMLElement {
                  var titleString = entry.textContent
                  // strip out linebreaks and repeated spaces that occur in some titles
                  titleString = titleString.stringByReplacingOccurrencesOfString("  ", withString: " ")
                  title = titleString.stringByReplacingOccurrencesOfString("\n", withString: "")
                }
              }
              
              if let title = title, url = url, number = number, scale = scale {
                let newChart = Chart(title: title, url: url, number: number, scale: scale)
                self.charts?.append(newChart)
              }
            }
          }
        }
        // TODO: bubble up errors
        completionHandler(nil)
    }
  }
  
  func isChartDownloaded(chart: Chart) -> Bool {
    if let path = chart.urlInDocumentsDirectory?.path {
      let fileManager = NSFileManager.defaultManager()
      return fileManager.fileExistsAtPath(path)
    }
    return false
  }
  
  func downloadChart(chart: Chart, completionHandler: (Double?, NSError?) -> Void) {
    guard isChartDownloaded(chart) == false else {
      completionHandler(1.0, nil) // already have it
      return
    }
    
    let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
    Alamofire.download(.GET, chart.url, destination: destination)
      .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
        print(totalBytesRead)
        dispatch_async(dispatch_get_main_queue()) {
          let progress = Double(totalBytesRead) / Double(totalBytesExpectedToRead)
          completionHandler(progress, nil)
        }
      }
      .responseString { response in
        print(response.result.error)
    }
    
  }
}
