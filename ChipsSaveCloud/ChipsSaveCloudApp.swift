//
//  ChipsSaveCloudApp.swift
//  ChipsSaveCloud
//
//  Created by jht2 on 3/10/22.
//

// firebase access sample
// https://github.com/firebase/firebase-ios-sdk.git
//  storeList, viewModel

import SwiftUI
import Firebase

// Needed to avoid swizzle warning for FirebaseApp package
// https://peterfriese.dev/swiftui-new-app-lifecycle-firebase/
//
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    print("GuestureApp ApplicationDelegate didFinishLaunchingWithOptions")
    FirebaseApp.configure()
    AuthUserService.signIn()
    return true
  }
}

@main
struct GuestureApp: App {
  
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  @StateObject var viewModel = ViewModel()
  // @StateObject var theStore = ItemStore()
  
  // init () {
  // We use AppDelegate and to configure there because Firebase library gives warning about need to swizzle
  // FirebaseApp.configure()
  // AuthenticationService.signIn()
  // Can't init because these properties are get-only due to @StateObject
  // theStore = ItemStore()
  // viewModel = ViewModel(theStore: theStore)
  // }
  
  var body: some Scene {
    WindowGroup {
      // theStore is property so changes can be monitored with @ObservedObject
      ContentView(theStore: viewModel.itemStore)
        .environmentObject(viewModel)
    }
  }
}
