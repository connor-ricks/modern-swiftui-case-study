import SwiftUI

@MainActor
open class ViewModel: Hashable, ObservableObject {
    public init() {}
    
    public nonisolated static func == (lhs: ViewModel, rhs: ViewModel) -> Bool {
      lhs === rhs
    }

    public nonisolated func hash(into hasher: inout Hasher) {
      hasher.combine(ObjectIdentifier(self))
    }
}
