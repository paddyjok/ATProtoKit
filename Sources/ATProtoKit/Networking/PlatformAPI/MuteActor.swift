//
//  MuteActor.swift
//
//
//  Created by Christopher Jr Riley on 2024-03-10.
//

import Foundation

extension ATProtoKit {
    /// Mutes a user account.
    /// 
    /// - Parameter actorDID: The decentralized identifier (DID) or handle of a user account.
    public func muteActor(_ actorDID: String) async throws {
        guard let sessionURL = session.pdsURL,
              let requestURL = URL(string: "\(sessionURL)/xrpc/app.bsky.graph.muteActor") else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        let requestBody = GraphMuteActor(actorDID: actorDID)

        do {
            let request = APIClientService.createRequest(forRequest: requestURL,
                                                         andMethod: .post,
                                                         acceptValue: "application/json",
                                                         contentTypeValue: nil,
                                                         authorizationValue: "Bearer \(session.accessToken)")

            let response = try await APIClientService.sendRequest(request)
        } catch {
            throw error
        }
    }
}
