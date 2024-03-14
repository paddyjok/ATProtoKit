//
//  RequestCrawl.swift
//
//
//  Created by Christopher Jr Riley on 2024-03-14.
//

import Foundation

extension ATProtoKit {
    /// Requests the crawling service to begin crawling the repositories.
    ///
    public static func requestCrawl(in crawlingHostname: URL? = nil, pdsURL: String = "https://bsky.social") async throws {
        guard let requestURL = URL(string: "\(pdsURL)/xrpc/app.bsky.graph.notifyOfUpdate") else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        // Check if the `crawlingHostname` and `pdsURL` are the same.
        // If so, then default the variable to `pdsURL`.
        guard let finalHostName = crawlingHostname ?? URL(string: pdsURL) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Hostname"])
        }

        let requestBody = SyncCrawler(
            crawlingHostname: finalHostName
        )

        do {
            let request = APIClientService.createRequest(forRequest: requestURL,
                                                         andMethod: .post,
                                                         acceptValue: "application/json",
                                                         contentTypeValue: "application/json",
                                                         authorizationValue: nil)

            let response = try await APIClientService.sendRequest(request, withEncodingBody: requestBody)
        } catch {
            throw error
        }
    }
}
