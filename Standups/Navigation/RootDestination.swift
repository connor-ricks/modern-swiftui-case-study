import Foundation

import EditStandupFeature

enum RootDestination: Hashable {
    case add(EditStandupModel)
    case edit(EditStandupModel)
}
