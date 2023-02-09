import Dependencies
import SwiftUI
import SwiftUINavigation
import SwiftUINavigationBackport
import XCTestDynamicOverlay

import Models
import RecordStandupFeature

// MARK: - StandupDetailView

public struct StandupDetailView<DestinationStandups: View>: View {
    
    // MARK: Properties
    
    @ObservedObject private var model: StandupDetailModel<DestinationStandups>
    
    // MARK: Initializers
    
    public init(model: StandupDetailModel<DestinationStandups>) {
        self.model = model
    }
    
    // MARK: Body
    
    public var body: some View {
        List {
            Section(content: {
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
            }, header: {
                Text("Standup Info")
            })
            
            Section(content: {
                ForEach(model.standup.meetings) { meeting in
                    Button(action: { model.meetingTapping(meeting) }) {
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
            }, header: {
                Text("Past meetings")
            })
            
            Section(content: {
                ForEach(model.standup.attendees) { attendee in
                    Button(action: { model.pushAllStandupsButtonTapped(attendee: attendee) }) {
                        Label(attendee.name, systemImage: "person")
                    }
                }
            }, header: {
                Text("Attendees")
            })
            
            Section {
                Button("Delete") { model.deleteButtonTapped() }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
            }

            if let attendee = model.standup.attendees.first {
                Button("Preent Standups for \(attendee.name)") { model.presentAllStandupsButtonTapped(attendee: attendee) }
            }

            Section {
                Button("Switch to Other Tab") { model.switchToOtherTabButtonTapped() }
            }
        }
        .navigationTitle(model.standup.title)
        .toolbar {
            Button("Edit") { model.editButtonTapped() }
        }
        .navigationDestination(
            unwrapping: $model.destination,
            case: /StandupDetailModel.Destination.meeting,
            destination: { $meeting in
                MeetingView(meeting: meeting, standup: model.standup)
            }
        )
        .navigationDestination(
            unwrapping: $model.destination,
            case: /StandupDetailModel.Destination.record,
            destination: { $recordModel in
                RecordStandupView(model: recordModel)
            }
        )
        .navigationDestination(
            unwrapping: $model.destination,
            case: /StandupDetailModel.Destination.external
        ) { $view in
            view
        }
        .sheet(
            unwrapping: $model.destination,
            case: /StandupDetailModel.Destination.edit
        ) { $editModel in
            NavigationView {
                EditStandupView(model: editModel)
                    .navigationTitle(model.standup.title)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { model.cancelEditButtonTapped() }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { model.doneEditingButtonTapped() }
                        }
                    }
            }
        }
    }
}

// MARK: - StandupDetailView+Previews

struct StandupDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            var standup = Standup.mock
            let _ = standup.duration = 60
            let _ = standup.attendees = [
                Attendee(id: Attendee.ID(UUID()), name: "Blob")
            ]
            StandupDetailView<EmptyView>(
                model: StandupDetailModel(
                    destination: .record(RecordStandupModel(standup: standup)),
                    standup: standup
                )
            )
        }
    }
}
