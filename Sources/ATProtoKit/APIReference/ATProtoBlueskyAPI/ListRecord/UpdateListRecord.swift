//
//  File.swift
//  ATProtoKit
//
//  Created by Patrick O'Keeffe on 4/20/25.
//

import Foundation

extension ATProtoBluesky {

    public func updateListRecord(
        listURI: String,
        name: String,
        description: String?,
        inlineFacets: [(url: URL, startPosition: Int, endPosition: Int)]? = nil,
        avatarBytes: Data? = nil
    ) async throws -> ComAtprotoLexicon.Repository.StrongReference {
        guard let session else {
            throw ATRequestPrepareError.missingActiveSession
        }

        guard session.pdsURL != nil else {
            throw ATRequestPrepareError.invalidPDS
        }
        
        guard let recordKey = listURI.components(separatedBy: "/").last else {
            throw ATProtoBlueskyError.invalidURLText(message: "Unable to get recordKey from URI '\(listURI)'.")
        }
        
        let listRecordExisting = try await atProtoKitInstance.getRepositoryRecord(from: session.sessionDID, collection: "app.bsky.graph.list", recordKey: recordKey)
        
        guard let existingListRecord = listRecordExisting.value?.getRecord(ofType: AppBskyLexicon.Graph.ListRecord.self) else {
            throw ATProtoBlueskyError.listNotFound(message: "Unable to list record.")
        }
        
        var facets: [AppBskyLexicon.RichText.Facet]? = nil
        
        if let description {
            let descriptionText = description.truncated(toLength: 300)
            
            facets = await ATFacetParser.parseFacets(from: descriptionText, pdsURL: session.pdsURL ?? "https://bsky.social")
            if let inlineFacets {
                for (url, start, end) in inlineFacets {
                    do {
                        let facet = try await ATFacetParser.createInlineLink(url: url, start: start, end: end)
                        facets!.append(facet)
                    } catch {
                        print("Failed to create inline link: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        var imageBlob: ComAtprotoLexicon.Repository.UploadBlobOutput? = nil
        
        if let avatarBytes {
            // Check if the image is too large.
            guard avatarBytes.count <= 1_000_000 else {
                throw ATBlueskyError.imageTooLarge
            }
            
            // Upload the image, then get the server response.
            let blobContainer = try await ATProtoKit(canUseBlueskyRecords: false).uploadBlob(
                pdsURL: session.serviceEndpoint.absoluteString,
                accessToken: session.accessToken,
                filename: "listavatar.jpeg",
                imageData: avatarBytes
            )
            
            imageBlob = blobContainer.blob
        }

        
        
        let listRecord = AppBskyLexicon.Graph.ListRecord(
            purpose: existingListRecord.purpose,
            name: name,
            description: description,
            descriptionFacets: facets,
            avatarImageBlob: imageBlob,
            labels: existingListRecord.labels,
            createdAt: existingListRecord.createdAt
        )
            
        do {
            return try await atProtoKitInstance.putRecord(
                repository: session.sessionDID,
                collection: "app.bsky.graph.list",
                recordKey: recordKey,
                record: UnknownType.record(listRecord)
            )
        } catch {
            throw error
        }
    }
    
}
