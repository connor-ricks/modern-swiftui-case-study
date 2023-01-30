import SwiftUI
import SwiftUINavigation

extension View {
    /// This function is a backport of `navigationDestination` for `iOS 15`.
    /// Once we drop `iOS 15`, we can remove this and utilize `swiftui-navigation's` build in
    /// `navigationDestination(...)
    @available(iOS, deprecated: 16.0, message: "This package can be deleted in favor of using swiftui-navigation's build in .navigationDestination.")
    public func navigationDestination<Enum, Case, WrappedDestination>(
        unwrapping `enum`: Binding<Enum?>,
        case casePath: CasePath<Enum, Case>,
        destination: @escaping (Binding<Case>) -> WrappedDestination
    ) -> some View where WrappedDestination: View {
        background {
            NavigationLink(
                unwrapping: `enum`,
                case: casePath,
                onNavigate: { _ in },
                destination: destination,
                label: { }
            )
        }
    }
}
