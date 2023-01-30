import Foundation
import SwiftUI

public enum StandupTheme: String, CaseIterable, Equatable, Hashable, Identifiable, Codable {
    case bubblegum
    case buttercup
    case indigo
    case lavender
    case magenta
    case navy
    case orange
    case oxblood
    case periwinkle
    case poppy
    case purple
    case seafoam
    case sky
    case tan
    case teal
    case yellow
    
    public var id: Self { self }
    
    public var name: String {
        rawValue.capitalized
    }
    
    public var primaryColor: Color {
        Color(rawValue)
    }
    
    public var accentColor: Color {
        switch self {
        case .bubblegum,
             .buttercup,
             .lavender,
             .orange,
             .periwinkle,
             .poppy,
             .seafoam,
             .sky,
             .tan,
             .teal,
             .yellow:
            return .black
        case .indigo,
             .magenta,
             .navy,
             .oxblood,
             .purple:
            return .white
        }
    }
}
