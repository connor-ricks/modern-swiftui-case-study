import Foundation
import Tagged

public struct Attendee: Hashable, Identifiable, Codable {
    public let id: Tagged<Self, UUID>
    public var name: String
    
    public init(id: Tagged<Self, UUID>, name: String) {
        self.id = id
        self.name = name
    }
}
