//
//  MasterViewController.swift
//  grokHTMLAndDownloads
//
//  Created by Christina Moulton on 2015-10-12.
//  Copyright © 2015 Teak Mobile Inc. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
  var detailViewController: DetailViewController? = nil
  var dataController = DataController()

  // MARK: - Table View

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataController.chartsCount()
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

    if let chart = dataController.chartAtIndex(indexPath.row) {
      cell.textLabel!.text = chart.title
    } else {
      cell.textLabel!.text = ""
    }
    
    return cell
  }

}

