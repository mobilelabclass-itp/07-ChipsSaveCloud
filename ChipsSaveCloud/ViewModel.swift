//
//  Document.swift
//  Guesture
//
//  Created by jht2 on 1/12/22.
//

import SwiftUI

class ViewModel: ObservableObject
{
  @Published var itemStore: ItemStore = ItemStore()
  @Published var selectedPalette:Palette = .rgb
  @Published var selectedId: String? = nil

  var store: ItemStore {
    itemStore
  }
  
  var selectedItem: ItemModel? {
    store.items.first { $0.selected }
  }
  
  init() {
    print("ViewModel init")
  }
  
  var items:[ItemModel] {
    // Debug to see when ItemView is re-built
    print("ViewModel items \(store.items.count)")
    return store.items
  }
  
  func clearSelection() {
    for index in  0..<store.items.count {
      var nitem = store.items[index];
      if nitem.selected {
        nitem.selected = false;
        store.update(nitem);
      }
    }
  }
    
  func update(item: ItemModel, x: Int, y: Int, selected: Bool) {
    print("update id \(String(describing: item.id)) selected: \(selected)")
    var nitem = item;
    nitem.selected = selected
    nitem.x = x
    nitem.y = y
    store.update(nitem)
    // Mark all others not selected
    for index in  0..<store.items.count {
      nitem = store.items[index];
      if nitem.id != item.id && nitem.selected {
        nitem.selected = false;
        store.update(nitem);
      }
    }
  }

  // Computed property to change the color the selected item
  //  ColorPicker("Color", selection: $viewModel.itemColor)
  var itemColor:Color {
    get {
      if let item = selectedItem {
        return item.color
      }
      else {
        return Color.red
      }
    }
    set {
      print("ViewModel color set \(newValue)")
      if var item = selectedItem {
        let colorNum = colorNum_(color: newValue)
        item.colorNum = colorNum
        store.update(item)
      }
    }
  }
  
  func delete() {
    print("delete")
    if let item = selectedItem {
      print("delete item \(item)")
      store.remove(item)
    }
  }
  
  func update(sizeBy: Double) {
    if var item = selectedItem {
      let w = Double(item.width)
      let h = Double(item.height)
      item.width = Int(w * sizeBy);
      item.height = Int(h * sizeBy);
      store.update(item)
    }
  }
  
  func update(rotationBy: Double) {
    if var item = selectedItem {
      var rotation = item.rotation
      rotation = (rotation < 360 ? rotation + rotationBy : 0)
      item.rotation = rotation
      store.update(item)
    }
  }

  func sendToBack() {
    // We could update all item orders but this would cost more write update
    // update selected item only to keep update cost low
    // There is a risk of integer underflow after Int.max updates
    // Find the item with the lowest order
    let min = items.reduce(Int.max, { result, item in
      item.order < result ? item.order: result
    })
    print("sendToBack min \(min)")
    // Update the selected item order to be less than the minimum order found
    if var item = selectedItem {
      if min != item.order {
        item.order = min - 1
        store.update(item)
      }
    }
  }
  
  func sendToFront() {
    let max = items.reduce(Int.min, { result, item in
      item.order > result ? item.order: result
    })
    print("sendToBack max \(max)")
    // Update the selected item order to be more than the maximum order found
    if var item = selectedItem {
      if max != item.order {
        item.order = max + 1
        store.update(item)
      }
    }
  }

  func removeAll () {
    store.removeAll()
  }
  
  func addItem(rect: CGRect) {
    let x = Int(rect.width / 2);
    let y = Int(rect.height / 2);
    addItem(x: x, y: y)
  }
  
  func addItem(x: Int, y: Int) {
    let order = store.items.count+1
    addItem(x: x, y: y, order: order)
  }

  func addItem(x: Int, y: Int, order: Int) {
    let colorNum = randomColorNum()
    let item = ItemModel(x: x, y: y, colorNum: colorNum, order: order)
    store.addItem(item)
  }
  
  func randomColorNum() -> Int {
    switch selectedPalette {
    case .rgy:
      return randomColorNum_rgy()
    case .bw:
      return randomColorNum_bw()
    case .rgb:
      return randomColorNum_rgb()
    }
  }
  
  func addCenteredItem(rect: CGRect) {
    let x = rect.width / 2;
    let y = rect.height / 2;
    let item = ItemModel(x: Int(x), y: Int(y))
    store.addItem(item)
  }
  
  func addPlusItems(rect: CGRect, count maxCount: Int) {
    let len = 50
    var x = -len
    var y = 0
    var order = 0
    var icount = 0;
    if items.count > 0 {
      let item = items[items.count-1]
      x = item.x
      y = item.y
      order = items.count
    }
    let bottom = Int(rect.height - 250.0)
    while icount < maxCount {
      x += len;
      if x > Int(rect.width) {
        x = 0
        y += len;
        if y > bottom {
          y = 0
        }
      }
      icount += 1
      order += 1
      addItem(x: x, y: y, order: order)
    }
  }
    
  func save(_ fileName: String) {
    store.saveAsJSON(fileName: fileName)
  }
  
  func restore(_ fileName: String) {
    store.restoreJSON(fileName: fileName)
  }
}

enum Palette: String, CaseIterable, Identifiable {
  case bw
  case rgy
  case rgb
  var id: String { self.rawValue }
}
