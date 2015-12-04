//
//  MasterViewController.swift
//  grokHTMLAndDownloads
//
//  Created by Christina Moulton on 2015-10-12.
//  Copyright © 2015 Teak Mobile Inc. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, UIDocumentInteractionControllerDelegate {
  var dataController = DataController()
  var docController: UIDocumentInteractionController?
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    dataController.fetchCharts { _ in
      // TODO: handle errors
      self.tableView.reloadData()
    }
  }
  
  // MARK: - Table View
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataController.charts?.count ?? 0
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    
    if let chartCell = cell as? ChartCell {
      if let chart = dataController.charts?[indexPath.row] {
        chartCell.titleLabel.text = "\(chart.number): \(chart.title)"
        
        if self.dataController.isChartDownloaded(chart) {
          // show disclosure indicator if we already have it
          chartCell.accessoryType = .Checkmark
        } 
      }
    }
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let chart = dataController.charts?[indexPath.row] {
      dataController.downloadChart(chart) { progress, error in
        // TODO: handle error
        print(progress)
        print(error)
        if (progress < 1.0) {
          if let cell = self.tableView.cellForRowAtIndexPath(indexPath), chartCell = cell as? ChartCell, progressValue = progress {
            chartCell.progressBar.hidden = false
            chartCell.progressBar.progress = Float(progressValue)
            chartCell.setNeedsDisplay()
          }
        }
        if (progress == 1.0) {
          if let filename = chart.filename {
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let docs = paths[0]
            let pathURL = NSURL(fileURLWithPath: docs, isDirectory: true)
            let fileURL = NSURL(fileURLWithPath: filename, isDirectory: false, relativeToURL: pathURL)
          
            self.docController = UIDocumentInteractionController(URL: fileURL)
            self.docController?.delegate = self
            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) {
              self.docController?.presentOptionsMenuFromRect(cell.frame, inView: self.tableView, animated: true)
              if let chartCell = cell as? ChartCell {
                chartCell.accessoryType = .Checkmark
                chartCell.setNeedsDisplay()
              }
            }
          }
        }
      }
    }
  }
  
  // MARK: - UIDocumentInteractionControllerDelegate
  func documentInteractionController(controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
    self.docController = nil
    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRowAtIndexPath(indexPath, animated:true)
    }
  }

  
}

