
import Foundation
import Firebase

fileprivate var initCount = 0;

class AuthUserService: ObservableObject {
  @Published var user: User?
  private var authStateHandler: AuthStateDidChangeListenerHandle?

  var icount: Int

  init() {
    initCount += 1
    icount = initCount
    addListeners()
  }

  static func signIn() {
    if Auth.auth().currentUser == nil {
      Auth.auth().signInAnonymously()
    }
  }

  private func addListeners() {
    if let handle = authStateHandler {
      Auth.auth().removeStateDidChangeListener(handle)
    }
    print(" \(icount) AuthenticationService addListeners")
    authStateHandler = Auth.auth()
      .addStateDidChangeListener { _, user in
        print(" \(self.icount) addStateDidChangeListener user: \(String(describing: user))")
        self.user = user
      }
  }
}
