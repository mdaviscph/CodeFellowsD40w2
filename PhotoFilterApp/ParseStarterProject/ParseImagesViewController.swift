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
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    let query = PFQuery(className: StringConsts.ParsePostClassname)
    query.whereKeyExists(StringConsts.PostImage)
    let date = NSDate()
    query.findObjectsInBackgroundWithBlock { (pfObjects, error) -> Void in
      if let pfObjects = pfObjects as? [PFObject] {
        for pfObject in pfObjects {
          if let pfFile = pfObject[StringConsts.PostImage] as? PFFile {
            pfFile.getDataInBackgroundWithBlock { (data, error) -> Void in
              if let data = data, image = UIImage(data: data) {
                self.cloudImages.append(image)
                NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
                  println(String(format: "findObjectsInBackgroundWithBlock in %0.4f seconds", -date.timeIntervalSinceNow))
                  self.tableView.reloadData()
                }
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
