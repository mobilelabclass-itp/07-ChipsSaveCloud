//
//  ItemModel.swift
//  Created by jht2 on 1/18/22.

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ItemModel: Identifiable, Hashable, Encodable, Decodable {
  @DocumentID var id: String?
  @ServerTimestamp var createdAt: Date?
  
  var label: String = "red"
  var x: Int = 100
  var y: Int = 100
  var width: Int = 50
  var height: Int = 50
  var colorNum: Int = 0xFFFF0000
  var rotation: Double = 0.0
  var selected: Bool = false
  var uid: Int = 0
  var userId: String?
  var order: Int = 0
  
  var colorName: String {
    String(format: "#%x", colorNum)
  }
  
  var color: Color {
    // !!@ Can't use color as func name due to var color property name
    color_(colorNum: colorNum)
  }
}

func colorNum_(color: Color) -> Int {
  if let cgColor = color.cgColor {
    let cc = cgColor.components
    let r = Int(cc![0] * 255.0)
    let g = Int(cc![1] * 255.0)
    let b = Int(cc![2] * 255.0)
    let a = Int(cc![3] * 255.0)
    print("colorNum cc \(String(describing: cc))")
    return ((a << 24) | (r << 16) | (g << 8) | b)
  }
  else {
    print("colorNum failed color \(color)")
    return 0
  }
}

func color_(colorNum: Int) -> Color {
  let a = Double((colorNum >> 24) & 255)/255.0
  let r = Double((colorNum >> 16) & 255)/255.0
  let g = Double((colorNum >>  8) & 255)/255.0
  let b = Double((colorNum      ) & 255)/255.0
  return Color(.displayP3, red: r, green: g, blue: b, opacity: a)
}

func randomColorNum_rgb() -> Int {
  let r = Int.random(in:0...255)
  let g = Int.random(in:0...255)
  let b = Int.random(in:0...255)
  return (255 << 24) | (r << 16) | (g << 8) | b
}

let colorNums_rgy = [0xFFFF0000, 0xFF00FF00, 0xFFFFFF00]

func randomColorNum_rgy() -> Int {
  let i = Int.random(in:0..<colorNums_rgy.count)
  return colorNums_rgy[i]
}

func randomColorNum_bw() -> Int {
  let i = Int.random(in:0..<2)
  return [0xFF000000, 0xFFFFFFFF][i]
}
