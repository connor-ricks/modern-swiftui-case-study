//
//  DeepLinkParser.swift
//  Standups
//
//  Created by Connor Ricks on 2/14/23.
//

import Foundation
import Dependencies

import StandupDetailFeature
import EditStandupFeature
import Models

// MARK: - DeepLinkComponents

struct DeepLinkComponents {
    let target: AppModel.Tab
    let path: [String]
    let parameters: [URLQueryItem]
}

// MARK: - DeepLinkParser

@MainActor
struct DeepLinkParser {
    static func target(for url: URL) -> DeepLinkComponents? {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let tab = AppModel.Tab(rawValue: urlComponents.scheme ?? "") else {
            return nil
        }

        let components = urlComponents.path.components(separatedBy: "/").filter { !$0.allSatisfy(\.isWhitespace) }
        return .init(target: tab, path: components, parameters: urlComponents.queryItems ?? [])
    }

    static func standupsTabModel(for path: [String], parameters: [URLQueryItem]) async -> StandupsTabModel? {
        var path = ArraySlice(path)


        guard let string = path.popFirst(),
              let uuid = UUID(uuidString: string),
              let detailModel = await StandupDetailModel(id: .init(uuid)) else {
            return nil
        }

        var destination: StandupTabDestination?
        if let item = parameters.first(where: { $0.name == "edit" }),
           let value = Bool(item.value ?? ""),
           value {
            destination = .edit(EditStandupModel(standup: detailModel.standup))
        }

        return StandupsTabModel(
            path: [.detail(model: detailModel)],
            destination: destination,
            standupsListModel: .init()
        )
    }
}
