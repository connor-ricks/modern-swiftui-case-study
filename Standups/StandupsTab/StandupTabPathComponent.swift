import Foundation

import StandupDetailFeature
import RecordStandupFeature
import Models

enum StandupTabPathComponent: Hashable {
    case detail(model: StandupDetailModel)
    case meeting(Meeting, standup: Standup)
    case record(RecordStandupModel)
}
