import Foundation

import EditStandupFeature

enum StandupTabDestination: Hashable {
    case add(EditStandupModel)
    case edit(EditStandupModel)
}
