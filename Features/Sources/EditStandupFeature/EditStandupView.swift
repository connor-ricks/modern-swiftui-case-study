import Foundation
import SwiftUI
import SwiftUINavigation

import Models

// MARK: - EditStandupView

public struct EditStandupView: View {
    
    // MARK: Field
    
    public enum Field: Hashable {
        case attendee(Attendee.ID)
        case title
    }
    
    // MARK: Properties
    
    @FocusState var focus: Field?
    @ObservedObject private var model: EditStandupModel
    
    public init(model: EditStandupModel) {
        self.model = model
    }
    
    // MARK: Body
    
    public var body: some View {
        Form {
            Section(content: {
                TextField("Title", text: $model.standup.title)
                    .focused($focus, equals: .title)
                HStack {
                    Slider(value: $model.standup.duration, in: 5...30, step: 1) {
                        Text("Length")
                    }
                    Spacer()
                    Text("\(Int(model.standup.duration))")
                }
                ThemePicker(selection: $model.standup.theme)
            }, header: {
                Text("Standup Info")
            })
            
            Section(content: {
                ForEach($model.standup.attendees) { $attendee in
                    TextField("Name", text: $attendee.name)
                        .focused($focus, equals: .attendee(attendee.id))
                }
                .onDelete { indices in
                    model.deleteAttendees(atOffsets: indices)
                }
                
                Button("New attendee") {
                    model.addAttendeeButtonTapped()
                }
            }, header: {
                Text("Attendees")
            })
        }
        .navigationTitle(model.navigationTitle)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Dismiss") { self.model.cancelEditingButtonTapped() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { self.model.finishEditingButtonTapped() }
            }
        }
        .bind($model.focus, to: $focus)
    }
}

// MARK: - EditStandup+Previews

struct EditStandup_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditStandupView(model: EditStandupModel(standup: .mock))
        }
    }
}
