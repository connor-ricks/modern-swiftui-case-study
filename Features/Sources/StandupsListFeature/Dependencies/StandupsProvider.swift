import Foundation
import IdentifiedCollections
import Dependencies

import Models

// MARK: - StandupsProvider

public struct StandupsProvider: Sendable {
    public var load: @Sendable () throws -> IdentifiedArrayOf<Standup>
    public var save: @Sendable (IdentifiedArrayOf<Standup>) throws -> Void
}

// MARK: - StandupsProvider+Dependency

extension DependencyValues {
    public var standupsProvider: StandupsProvider {
        get { self[StandupsProvider.self] }
        set { self[StandupsProvider.self] = newValue }
    }
}

extension StandupsProvider: DependencyKey {
    
    // MARK: Constants
    
    private enum Constants {
        static let standupsURL: URL = {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return URL(string: paths[0].absoluteString + "standups.json")!
        }()
    }
    
    public static let liveValue = StandupsProvider(
        load: {
            try JSONDecoder().decode(
                IdentifiedArray.self,
                from: try Data(contentsOf: Constants.standupsURL)
            )
        },
        save: { standups in
            try JSONEncoder()
                .encode(standups)
                .write(to: Constants.standupsURL)
        }
    )
}

// MARK: - StandupsProvider+Mocks

#if DEBUG
extension StandupsProvider {
    public static func mock(initialData: IdentifiedArrayOf<Standup> = []) -> StandupsProvider {
        let data = LockIsolated(initialData)
        return StandupsProvider(
            load: { data.value },
            save: { newData in data.setValue(newData) }
        )
    }
    
    public static let failToWrite = StandupsProvider(
        load: { [] },
        save: { _ in 
            struct SaveError: Error {}
            throw SaveError()
        }
    )
    public static let failToLoad = StandupsProvider(
        load: {
            struct LoadError: Error {}
            throw LoadError()
        },
        save: { _ in }
    )
}
#endif
