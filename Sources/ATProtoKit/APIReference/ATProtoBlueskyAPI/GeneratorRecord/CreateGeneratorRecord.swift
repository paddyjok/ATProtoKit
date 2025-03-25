//
//  CreateGeneratorRecord.swift
//
//
//  Created by Christopher Jr Riley on 2024-06-01.
//

import Foundation

extension ATProtoBluesky {

    public func createGeneratorRecord(
        feedId: String,
        displayName: String,
        description: String,
        avatarURL: URL? = nil,
        serviceDID: String,
        labels: ATUnion.GeneratorLabelsUnion? = nil,
        creationDate: Date = Date(),
        shouldValidate: Bool? = true,
        swapCommit: String? = nil
    ) async throws -> ComAtprotoLexicon.Repository.StrongReference {
        guard let session else {
            throw ATRequestPrepareError.missingActiveSession
        }

        guard session.pdsURL != nil else {
            throw ATRequestPrepareError.invalidPDS
        }
        
        let generatorRecord = AppBskyLexicon.Feed.GeneratorRecord(
            feedDID: serviceDID,
            displayName: displayName,
            description: description,
            descriptionFacets: nil,
            avatarImageBlob: nil,
            canAcceptInteractions: nil,
            labels: labels,
            contentMode: .unspecified,
            createdAt: creationDate)
            
        do {
            return try await atProtoKitInstance.createRecord(
                repositoryDID: session.sessionDID,
                collection: "app.bsky.feed.generator",
                recordKey: feedId,
                shouldValidate: shouldValidate,
                record: UnknownType.record(generatorRecord),
                swapCommit: swapCommit ?? nil
            )
        } catch {
            throw error
        }
    }
    
//    public func uploadImages(_ images: [ATProtoTools.ImageQuery], pdsURL: String = "https://bsky.social",
//                             accessToken: String) async throws -> ATUnion.PostEmbedUnion {
//        var embedImages = [AppBskyLexicon.Embed.ImagesDefinition.Image]()
//
//        for image in images {
//            // Check if the image is too large.
//            guard image.imageData.count <= 1_000_000 else {
//                throw ATBlueskyError.imageTooLarge
//            }
//
//            // Upload the image, then get the server response.
//            let blobReference = try await ATProtoKit(canUseBlueskyRecords: false).uploadBlob(
//                pdsURL: pdsURL,
//                accessToken: accessToken,
//                filename: image.fileName,
//                imageData: image.imageData
//            )
//
//            let embedImage = AppBskyLexicon.Embed.ImagesDefinition.Image(
//                imageBlob: blobReference.blob,
//                altText: image.altText ?? "",
//                aspectRatio: image.aspectRatio
//            )
//            embedImages.append(embedImage)
//        }
//
//        return .images(AppBskyLexicon.Embed.ImagesDefinition(images: embedImages))
//    }
    
    
}
