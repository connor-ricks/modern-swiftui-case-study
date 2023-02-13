import Foundation
import Tagged

public struct Meeting: Hashable, Identifiable, Codable {
    public let id: Tagged<Self, UUID>
    public let date: Date
    public var transcript: String
    
    public init(id: Tagged<Self, UUID>, date: Date, transcript: String) {
        self.id = id
        self.date = date
        self.transcript = transcript
    }
}
