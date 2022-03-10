//
//  ContentView.swift
//  Created by jht2 on 1/12/22.
//

import SwiftUI

struct ContentView: View {
  
  // Whould to reference store from property but fails
  // @ObservedObject var theStore = viewModel.store
  @ObservedObject var theStore: ItemStore

  @EnvironmentObject var viewModel: ViewModel
  
  var body: some View {
    GeometryReader { geometry in
      let rect = geometry.frame(in: .local)
      ZStack {
        Rectangle()
          .fill(Color(white: 0.9))
          .onTapGesture {
            print("ContentView onTapGesture")
            viewModel.clearSelection()
          }
        VStack {
          if viewModel.items.isEmpty {
            Spacer()
          }
          else {
            ZStack {
              ForEach(viewModel.items) { item in
                ItemDragView(item: item)
              }
            }
          }
          if let item = viewModel.selectedItem {
            selectedItemGroup(item)
          }
          editRow(rect)
          infoRow()
        }
        .padding(20)
        .onAppear() {
          // viewModel.addCenteredItem(rect: rect)
        }
      }
    }
  }
  
  func selectedItemGroup(_ item: ItemModel) -> some View {
    Group {
      // Text("x \(item.x) y \(item.y) color \(item.colorName)")
      HStack {
        Text(infoTextFor(item))
        Button("Delete") {
          viewModel.delete()
        }
      }
      HStack {
        ColorPicker("", selection: $viewModel.itemColor).frame(width: 40)
        Button("Rotate") {
          viewModel.update(rotationBy: 45.0)
        }
        Button("+Size") {
          viewModel.update(sizeBy: 1.1)
        }
        Button("-Size") {
          viewModel.update(sizeBy: 0.9)
        }
      }
      HStack {
        Button("To Back") {
          withAnimation {
            viewModel.sendToBack();
          }
        }
        Button("To Front") {
          withAnimation {
            viewModel.sendToFront();
          }
        }
      }
    }
    .buttonStyle(.bordered)
  }
  
  func infoRow() -> some View {
    HStack {
      // Text("frame \(format(rect))")
      Text("userId: \(format(id: theStore.userId))")
      // Text("Store: ")
      Picker("Store", selection: $viewModel.itemStore.storeSelection) {
        ForEach(storeList, id: \.self) { cat in
          Text(cat)
            .tag(cat)
        }
      }
      Picker("Palette", selection: $viewModel.selectedPalette) {
        Text("rgb").tag(Palette.rgb)
        Text("rgy").tag(Palette.rgy)
        Text("bw").tag(Palette.bw)
      }
    }
  }
  
  func editRow(_ rect: CGRect) -> some View {
    HStack {
      Button("✚1") {
        withAnimation {
          viewModel.addPlusItems(rect: rect, count: 1)
        }
      }
      Button("✚8") {
        withAnimation {
          viewModel.addPlusItems(rect: rect, count: 8)
        }
      }
      Button("Clear") {
        withAnimation {
          viewModel.removeAll();
        }
      }
      Button("Save") {
        viewModel.save(theStore.storeSelection+".json");
      }
      Button("Restore") {
        viewModel.restore(theStore.storeSelection+".json");
      }
    }
    .buttonStyle(.bordered)
  }
  
  // ContentView
}

func format(id:String) -> String {
  return id.prefix(4)+"..."+id.suffix(4)
}

func infoTextFor(_ item: ItemModel) -> String {
  if let id = item.id {
    //    return "id: " + id.prefix(4) + "..." + id.suffix(4) + " order: " + String(item.order)
    let str = "id: "+format(id: id)
    return str + " order: "+String(item.order)
  }
  else {
    return ""
  }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(model: Model())
//    }
//}

//PlaygroundPage.current.setLiveView(ExampleView())

