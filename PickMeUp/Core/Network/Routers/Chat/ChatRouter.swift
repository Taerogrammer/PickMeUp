//
//  ChatRouter.swift
//  PickMeUp
//
//  Created by 김태형 on 6/1/25.
//

import Foundation

enum ChatRouter: APIRouter {
    case getChats
    case postChats(request: ChatRequest)
    case getChattings(roomID: String, next: String)
    case postChattings(roomID: String, request: ChatSendRequest)
    case postFiles(roomID: String, request: FileRequest)

    var environment: APIEnvironment { .production }

    var path: String {
        switch self {
        case .getChats, .postChats:
            return APIConstants.Endpoints.Chat.chat
        case .getChattings(let roomID, _):
            return APIConstants.Endpoints.Chat.chatting(roomID)
        case .postChattings(let roomID, _):
            return APIConstants.Endpoints.Chat.chatting(roomID)
        case .postFiles(let roomID, _):
            return APIConstants.Endpoints.Chat.files(roomID)
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getChats, .getChattings:
            return .get
        case .postChats, .postChattings, .postFiles:
            return .post
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .getChats, .getChattings:
            return nil
        case .postChats(let request):
            return [
                APIConstants.Parameters.Chat.opponentID: request.opponent_id
            ]
        case .postChattings(_, let request):
            return [
                APIConstants.Parameters.Chat.content: request.content,
                APIConstants.Parameters.Chat.files: request.files
            ]
        case .postFiles(_, let request):
            return [
                APIConstants.Parameters.Chat.files: request.files
            ]
        }
    }

    var headers: [String: String]? {
        var baseHeaders: [String: String] = [
            APIConstants.Headers.sesacKey: APIConstants.Headers.Values.sesacKeyValue()
        ]

        if let refreshToken = KeychainManager.shared.load(key: TokenType.refreshToken.rawValue) {
            baseHeaders[APIConstants.Headers.authorization] = refreshToken
        } else {
            print(APIConstants.ErrorMessages.missingRefreshToken)
        }

        return baseHeaders
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .getChats, .postChats, .postChattings, .postFiles:
            return nil
        case .getChattings(_, let next):
            return [URLQueryItem(name: "next", value: next)]
        }
    }
}
