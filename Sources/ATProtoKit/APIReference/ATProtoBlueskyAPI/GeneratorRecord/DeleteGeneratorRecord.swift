//
//  DeleteGeneratorRecord.swift
//
//
//  Created by Christopher Jr Riley on 2024-06-01.
//

import Foundation

extension ATProtoBluesky {

    public func deleteGeneratorRecord(_ record: RecordIdentifier) async throws {
        return try await deleteActionRecord(record)
    }
    
}
