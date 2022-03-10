//
//  ItemStoreJSON.swift
//  Created by jht2 on 1/18/22.

// Save / Restore store items to local JSON file

import Foundation

extension ItemStore {
  
  func saveAsJSON(fileName: String) {
    // Take care to catch errors with do / try / catch
    do {
      let fileMan = FileManager.default
      let directory = try fileMan.url(
        for: .documentDirectory,
           in: .userDomainMask,
           appropriateFor: nil,
           create: true)
      as URL
      let filePath = directory.appendingPathComponent(fileName);
      print("saveAsJSON filePath \(filePath as Any)")
      
      // May have to delete file if case mismatch, eg. Apple.json vs. apple.json
      // let filePathExists = fileMan.fileExists(atPath: filePath.path)
      // if filePathExists {
      //   try fileMan.removeItem(at: filePath)
      // }
      
      // Create reference style array to hold dictionary of representation of firebase item model
      // items --> arr
      let arr:NSMutableArray = [];
      for item in items {
        let dict:NSMutableDictionary = [:];
        
        // id for reference only. new id will be assigned when restored.
        dict["id"] = item.id
        
        // Covert firebase centric Date to string and time interval
        let timeInterval = item.createdAt!.timeIntervalSinceReferenceDate;
        dict["createdAt_string"] = item.createdAt!.description;
        dict["createdAt_timeInterval"] = timeInterval
        
        dict["label"] = item.label
        dict["x"] = item.x
        dict["y"] = item.y
        dict["width"] = item.width
        dict["height"] = item.height
        dict["colorNum"] = item.colorNum
        dict["rotation"] = item.rotation
        dict["selected"] = item.selected
        dict["uid"] = item.uid
        dict["userId"] = item.userId
        dict["order"] = item.order
        
        arr.add( dict );
      }
      // print("arr \(arr) ")
      let data = try JSONSerialization.data(withJSONObject: arr, options: [.prettyPrinted,.withoutEscapingSlashes,.sortedKeys])
      
      let str = String(data: data, encoding: .utf8)!
      // print("Model saveAsJSON encode str \(str)")
      
      try str.write(to: filePath, atomically: true, encoding: .utf8)
      //
    }
    catch {
      fatalError("saveAsJSON error \(error.localizedDescription)")
    }
  }

  func restoreJSON(fileName: String) {
    do {
      // could use common func to get filePath
      let fileMan = FileManager.default
      let directory = try fileMan.url(
        for: .documentDirectory,
           in: .userDomainMask,
           appropriateFor: nil,
           create: true)
      as URL
      let filePath = directory.appendingPathComponent(fileName);
      print("restoreJSON filePath \(filePath as Any)")
      
      let filePathExists = fileMan.fileExists(atPath: filePath.path)
      if !filePathExists {
        print("restoreJSON no file filePath \(filePath as Any)")
        return
      }
      print("restoreJSON filePath \(filePath as Any)")
      
      let jsonData = try String(contentsOfFile: filePath.path).data(using: .utf8)
      
      let arr = try JSONSerialization.jsonObject(with: jsonData!) as! NSArray
      // var nitems = [ItemModel]()
      for dict1 in arr {
        // print("dict1 \(dict1)")
        let dict:NSDictionary = dict1 as! NSDictionary
        
        let createdAt_timeInterval = dict["createdAt_timeInterval"] as! TimeInterval
        let createdAt = Date(timeIntervalSinceReferenceDate: createdAt_timeInterval)
        
        let label = dict["label"] as! String
        let x = (dict["x"] as! NSNumber).intValue
        let y = (dict["y"] as! NSNumber).intValue
        let width = (dict["width"]  as! NSNumber).intValue
        let height = (dict["height"] as! NSNumber).intValue
        let colorNum = (dict["colorNum"] as! NSNumber).intValue
        let rotation = (dict["rotation"] as! NSNumber).doubleValue
        let selected = (dict["selected"] as! NSNumber).intValue != 0
        let uid = (dict["uid"] as! NSNumber).intValue
        let userId = dict["userId"] as! String
        let order = (dict["order"] as! NSNumber).intValue
        
        let nitem = ItemModel(id: nil,
                              createdAt: createdAt,
                              label: label,
                              x: x, y: y,
                              width: width, height: height,
                              colorNum: colorNum,
                              rotation: rotation,
                              selected: selected,
                              uid: uid,
                              userId: userId,
                              order: order)
        addItem(nitem)
      }
      //
    }
    catch {
      fatalError("restoreJSON error \(error.localizedDescription)")
    }
  }
}
