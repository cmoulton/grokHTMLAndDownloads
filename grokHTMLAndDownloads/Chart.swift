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
  let url: NSURL
  let number: Int
  let scale: Int

  required init(title: String, url: NSURL, number: Int, scale: Int) {
    self.title = title
    self.url = url
    self.number = number
    self.scale = scale
  }
  
  var filename: String? {
    return url.lastPathComponent
  }
  
  var urlInDocumentsDirectory: NSURL? {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    if paths.count > 0 {
      let path = paths[0]
      if let directory = NSURL(string: path), filename = filename {
        let fileURL = directory.URLByAppendingPathComponent(filename)
        return fileURL
      }
    }
    return nil
  }
}