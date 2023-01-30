import SwiftUI
import Models

import StandupDetailFeature
import StandupsListFeature

@main
struct StandupsApp: App {
    var body: some Scene {
        WindowGroup {
            var standup = Standup.mock
            let _ = standup.duration = 10
            let _ = standup.attendees = [
                Attendee(id: Attendee.ID(UUID()), name: "Blob")
            ]
            
            StandupsListView(model: .init(
                destination: .detail(
                    StandupDetailModel(
                        destination: .edit(
                            EditStandupModel(
                                focus: .attendee(standup.attendees[0].id),
                                standup: standup
                            )
                        ),
                        standup: standup
                    )
                )
            ))
        }
    }
}
