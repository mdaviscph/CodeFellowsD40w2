//
//  ParseImagesViewController.swift
//  ParseStarterProject
//
//  Created by mike davis on 8/13/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class ParseImagesViewController: UITableViewController {
  
  // MARK: Private Properties
  private var cloudImages = [UIImage]()
  
  // MARK: Life Cycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // clearsSelectionOnViewWillAppear = false
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // navigationItem.rightBarButtonItem = self.editButtonItem()

    let query = PFQuery(className: PhotoFilterConsts.ParsePostClassname)
    query.whereKeyExists(PhotoFilterConsts.PostImage)
    query.findObjectsInBackgroundWithBlock { (pfObjects, error) -> Void in
      if let pfObjects = pfObjects as? [PFObject] {
        for pfObject in pfObjects {
          if let pfFile = pfObject[PhotoFilterConsts.PostImage] as? PFFile {
            pfFile.getDataInBackgroundWithBlock { (data, error) -> Void in
              if let data = data, image = UIImage(data: data) {
                self.cloudImages.append(image)
                self.tableView.reloadData()
              }
            }
          }
        }
      }
    }
  }
}

// MARK: - Table view data source
extension ParseImagesViewController: UITableViewDataSource {
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cloudImages.count
  }
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(StoryboardConsts.ParseImageCellReuseIdentifier, forIndexPath: indexPath) as! ParseImageCell
    cell.parseImage = cloudImages[indexPath.row]
    return cell
  }
}
  /*
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
  // Return NO if you do not want the specified item to be editable.
  return true
  }
  */
  
  /*
  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
  if editingStyle == .Delete {
  // Delete the row from the data source
  tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
  } else if editingStyle == .Insert {
  // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
  }
  }
  */
