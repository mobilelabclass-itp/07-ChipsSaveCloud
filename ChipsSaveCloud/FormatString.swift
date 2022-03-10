//
//  FormatString.swift
//  Created by jht2 on 1/12/22.
//

import SwiftUI

// String(format: "%.1f", model.zoom_x))
// Text("x \(String(format: "%.1f", model.zoom_x)) y \(String(format: "%.1f",  model.zoom_y)) z \(String(format: "%.3f",  zoom_scale))")

// Format double to string
func format(_ v: Double) -> String {
    String(format: "%.1f", v)
}

// Format point to string
func format(_ pt: CGPoint) -> String {
  "\(format(pt.x)) \(format(pt.y))"
}

// Format rect to string
func format(_ rt: CGRect) -> String {
    "\(format(rt.origin.x)) \(format(rt.origin.y)) \(format(rt.size.width)) \(format(rt.size.height))"
}
