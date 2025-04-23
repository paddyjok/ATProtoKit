//
//  CreateListItemRecord.swift
//
//
//  Created by Christopher Jr Riley on 2024-06-01.
//

import Foundation

extension ATProtoBluesky {

    public func createListItemRecord(
        subjectDid: String,
        list: String,
        creationDate: Date = Date(),
        recordKey: String? = nil,
        shouldValidate: Bool? = true,
        swapCommit: String? = nil
    ) async throws -> ComAtprotoLexicon.Repository.StrongReference {
        guard let session else {
            throw ATRequestPrepareError.missingActiveSession
        }

        guard session.pdsURL != nil else {
            throw ATRequestPrepareError.invalidPDS
        }
                
        let listItemRecord = AppBskyLexicon.Graph.ListItemRecord(
            subjectDID: subjectDid,
            list: list,
            createdAt: creationDate)
            
        do {
            return try await atProtoKitInstance.createRecord(
                repositoryDID: session.sessionDID,
                collection: "app.bsky.graph.listitem",
                recordKey: recordKey,
                shouldValidate: shouldValidate,
                record: UnknownType.record(listItemRecord),
                swapCommit: swapCommit ?? nil
            )
        } catch {
            throw error
        }
    }

    
}
