//
//  CreateListRecord.swift
//  
//
//  Created by Christopher Jr Riley on 2024-06-01.
//

import Foundation

extension ATProtoBluesky {

    public func createListRecord(
        purpose: AppBskyLexicon.Graph.ListPurpose,
        name: String,
        description: String?,
        inlineFacets: [(url: URL, startPosition: Int, endPosition: Int)]? = nil,
        avatarBytes: Data? = nil,
        labels: ATUnion.ListLabelsUnion? = nil,
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
            purpose: .curatelist,
            name: name,
            description: description,
            descriptionFacets: facets,
            avatarImageBlob: imageBlob,
            labels: labels,
            createdAt: creationDate)
            
        do {
            return try await atProtoKitInstance.createRecord(
                repositoryDID: session.sessionDID,
                collection: "app.bsky.graph.list",
                recordKey: recordKey,
                shouldValidate: shouldValidate,
                record: UnknownType.record(listRecord),
                swapCommit: swapCommit ?? nil
            )
        } catch {
            throw error
        }
    }
    
}
