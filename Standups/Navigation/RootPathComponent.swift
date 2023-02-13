import Foundation

import StandupDetailFeature
import RecordStandupFeature
import Models

enum RootPathComponent: Hashable {
    case detail(model: StandupDetailModel, destination: StandupDetailDestination?)
    case meeting(Meeting, standup: Standup)
    case record(RecordStandupModel)
}
