//
//  UserSession.swift
//  
//
//  Created by Christopher Jr Riley on 2024-01-05.
//

import Foundation

public class UserSession: SessionProtocol {
    public private(set) var handle: String
    public private(set) var atDID: String
    public private(set) var email: String?
    public private(set) var emailConfirmed: Bool?
    public private(set) var accessToken: String
    public private(set) var refreshToken: String
    public private(set) var didDocument: DIDDocument?

    public var pdsURL: String?

    public init(handle: String, atDID: String, email: String? = nil, emailConfirmed: Bool? = nil, accessToken: String, refreshToken: String, didDocument: DIDDocument? = nil, pdsURL: String? = nil) {
        self.handle = handle
        self.atDID = atDID
        self.email = email
        self.emailConfirmed = emailConfirmed
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.didDocument = didDocument
        self.pdsURL = pdsURL
    }

    enum CodingKeys: String, CodingKey {
        case handle
        case atDID = "did"
        case email
        case emailConfirmed
        case accessToken = "accessJwt"
        case refreshToken = "refreshJwt"
        case didDocument = "didDoc"
        case pdsURL
    }

    public func isAccessTokenExpired() -> Bool {
        // Implement logic to check if the accessToken is expired
        // This could involve decoding the JWT and checking its expiry timestamp
        return false
    }
}



public struct DIDDocument: Codable {
    var context: [String]
    var id: String
    var alsoKnownAs: [String]?
    var verificationMethod: [VerificationMethod]
    var service: [Service]

    enum CodingKeys: String, CodingKey {
        case context = "@context"
        case id
        case alsoKnownAs
        case verificationMethod
        case service
    }
}

public struct VerificationMethod: Codable {
    var id: String
    var type: String
    var controller: String
    var publicKeyMultibase: String
}

public struct Service: Codable {
    var id: String
    var type: String
    var serviceEndpoint: URL
}
