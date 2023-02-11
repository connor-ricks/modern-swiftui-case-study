import SwiftUI
import SwiftUINavigation
import XCTestDynamicOverlay
import Dependencies

import Models

// MARK: - StandupDetailView

public struct StandupDetailView: View {
    
    // MARK: Properties
    
    @ObservedObject private var model: StandupDetailModel
    
    // MARK: Initializers
    
    public init(model: StandupDetailModel) {
        self.model = model
    }
    
    // MARK: Body
    
    public var body: some View {
        List {
            Section("Standup Info") {
                Button(action: { model.startMeetingButtonTapped() }) {
                    Label("Start Meeting", systemImage: "timer")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
                
                HStack {
                    Label("Length", systemImage: "clock")
                    Spacer()
                    Text("\(Int(model.standup.duration))")
                }
                
                HStack {
                    Label("Theme", systemImage: "paintpalette")
                    Spacer()
                    Text(model.standup.theme.name)
                        .padding(4)
                        .foregroundColor(model.standup.theme.accentColor)
                        .background(model.standup.theme.primaryColor)
                        .cornerRadius(4)
                }
            }
            
            Section("Past Meetings") {
                ForEach(model.standup.meetings) { meeting in
                    Button(action: { model.meetingTapped(meeting) }) {
                        HStack {
                            Image(systemName: "calendar")
                            Text(meeting.date, style: .date)
                            Text(meeting.date, style: .time)
                        }
                    }
                }
                .onDelete { indices in
                    model.deleteMeetings(atOffsets: indices)
                }
            }
            
            Section("Attendees") {
                ForEach(model.standup.attendees) { attendee in
                    Label(attendee.name, systemImage: "person")
                }
            }
            
            Section {
                Button("Delete") { model.deleteButtonTapped() }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(model.standup.title)
        .toolbar {
            Button("Edit") { model.editButtonTapped() }
        }
    }
}

// MARK: - StandupDetailView+Previews

struct StandupDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            var standup = Standup.mock
            let _ = standup.duration = 60
            let _ = standup.attendees = [
                Attendee(id: Attendee.ID(UUID()), name: "Blob")
            ]

            StandupDetailView(
                model: StandupDetailModel(standup: standup)
            )
        }
    }
}
