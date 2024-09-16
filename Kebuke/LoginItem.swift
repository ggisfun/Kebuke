//
//  LoginItem.swift
//  Kebuke
//
//  Created by Adam Chen on 2024/9/15.
//

import Foundation

struct User: Codable {
    var user: UserInfo
}

struct UserInfo: Codable {
    var login: String
    var email: String?
    var password: String
    
}

struct Result: Codable {
    var userToken: String?
    var login: String?
    var errorCode: Int?
    var message: String?
    
    enum CodingKeys: String,CodingKey {
        case userToken = "User-Token"
        case login
        case errorCode = "error_code"
        case message
    }
}

enum APIURL {
    static let baseURL = URL(string: "https://favqs.com/api")!
    
    case register
    case login
    
    var url: URL {
        switch self {
        case .register:
            return APIURL.baseURL.appendingPathComponent("users")
        case .login:
            return APIURL.baseURL.appendingPathComponent("session")
        }
    }
}

let apiKey = "FavQs ApiKey"

enum ErrorMessage: Error, LocalizedError {
    case statusCodeError
    case decodeDataError
}
