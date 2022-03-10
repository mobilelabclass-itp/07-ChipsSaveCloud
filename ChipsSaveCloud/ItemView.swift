
import SwiftUI

struct ItemDragView: View {
  var item: ItemModel
  
  @EnvironmentObject var viewModel: ViewModel
  
  var body: some View {
    ItemView(item: item, position: positionOffset())
      .gesture(panGesture())
  }
  
  @GestureState private var dragOffset: CGSize = CGSize.zero
  
  func positionOffset() -> CGPoint {
    let x = CGFloat(item.x) + dragOffset.width;
    let y = CGFloat(item.y) + dragOffset.height;
    return CGPoint(x: x, y: y)
  }
  
  private func panGesture() -> some Gesture {
    DragGesture(minimumDistance: 0)
      .updating($dragOffset) { latestValue, dragOffset, _ in
        dragOffset = latestValue.translation
      }
      .onEnded { finalValue in
        let x = Int(CGFloat(item.x) + finalValue.translation.width)
        let y = Int(CGFloat(item.y) + finalValue.translation.height)
        viewModel.update(item: item, x: x, y: y, selected: true)
      }
  }
}

struct ItemView: View {
  var item: ItemModel
  var position: CGPoint;
  
  @EnvironmentObject var viewModel: ViewModel
  
  var body: some View {
    ZStack {
      if (item.selected) {
        Rectangle()
          .stroke(lineWidth: 5)
        
      }
//      Ellipse()
      Rectangle()
        .fill(item.color)
      // on tap here causs pause before drag begins
//        .onTapGesture {
//          viewModel.select(id: item.id, state: !item.selected)
//        }
//      if item.selected, let order = viewModel.itemOrder(id: item.id) {
//        Text("\(order)")
//      }
    }
    .frame(width: CGFloat(item.width), height: CGFloat(item.height))
    .rotationEffect(.degrees(item.rotation))
    .animation(.linear, value:item.rotation)
    .position(position)
  }
}
