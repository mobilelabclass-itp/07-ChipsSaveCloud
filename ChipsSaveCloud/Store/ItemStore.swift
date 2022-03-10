//
//  ItemStore.swift

import Foundation

import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

// Debug to track how many instances created.
// We expect only one
fileprivate var initCount = 0;

// List of stores presented in ContentView Picker("Store"...
// maybe better placed as static property of ItemStore
//
var storeList = [
  "apple",
  "banana",
  "cherry",
  "donuts",
  "jack"
]

class ItemStore: ObservableObject {
  
  private let store = Firestore.firestore()
  
  @Published var items: [ItemModel] = []
  
  // Use property observer to trigger store refresh when a new store is selected
  @Published var storeSelection = storeList[0] {
    didSet {
      print("storeSelection set \(storeSelection)")
      get()
    }
  }
  
  // Firebase document name for store.
  // eg. apple-items
  private var path: String {
    storeSelection + "-items"
  }
  
  // User id is obtained from AuthUserService
  var userId = ""
  private let authUserService = AuthUserService()
  private var cancellables: Set<AnyCancellable> = []
  
  var icount: Int
  
  static var static_store: ItemStore? = nil
  
  static var single: ItemStore {
    if let a_store = static_store {
      return a_store
    }
    static_store = ItemStore();
    return static_store!
  }
  
  var listener :ListenerRegistration? = nil
  
  init() {
    initCount += 1;
    icount = initCount
    print("\(icount) ItemStore init count \(self.items.count)")
    authUserService.$user
      .compactMap { user in
        user?.uid
      }
      .assign(to: \.userId, on: self)
      .store(in: &cancellables)
    
    authUserService.$user
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.get()
      }
      .store(in: &cancellables)
  }
  
  func get() {
    // print("\(self.icount) ItemStore get count \(self.items.count)")
    if let listener = listener {
      print("\(self.icount) ItemStore get listener remove")
      listener.remove()
    }
    listener = store.collection(path)
      // .whereField("userId", isEqualTo: userId)
      // .order(by: "createdAt", descending: true )
      .order(by: "order" )
      .addSnapshotListener { querySnapshot, error in
        print("  \(self.icount) snapshotListener  count \(self.items.count)")
        if let error = error {
          print("snapshotListener getting items error: \(error.localizedDescription)")
          return
        }
        let qr = querySnapshot?.documents.compactMap { document in
          return try? document.data(as: ItemModel.self)
        }
        self.items = qr ?? []
      }
  }
  
  func addItem(_ item: ItemModel) {
    do {
      var newItem = item
      newItem.userId = userId
      _ = try store.collection(path).addDocument(from: newItem)
    } catch {
      fatalError("Unable to add item: \(error.localizedDescription).")
    }
  }
  
  func update(_ item: ItemModel) {
    // print("update item \(item)")
    guard let itemId = item.id else { return }
    do {
      try store.collection(path).document(itemId).setData(from: item)
    } catch {
      fatalError("Unable to update item: \(error.localizedDescription).")
    }
  }
  
  func remove(_ item: ItemModel) {
    guard let itemId = item.id else { return }
    store.collection(path).document(itemId).delete { error in
      if let error = error {
        print("Unable to remove item: \(error.localizedDescription)")
      }
    }
  }
  
  func removeAll () {
    for item in items {
      remove(item)
    }
  }
}

// based on:
// https://www.raywenderlich.com/11609977-getting-started-with-cloud-firestore-and-swiftui
// https://koenig-media.raywenderlich.com/uploads/2020/12/FireCards_SwiftUI.zip

