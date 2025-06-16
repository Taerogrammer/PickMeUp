//
//  ChatRouter.swift
//  PickMeUp
//
//  Created by 김태형 on 6/1/25.
//

import Foundation

enum ChatRouter: APIRouter {
    case getChat
    case postChat(request: PostChatRequest)
    case getChatting(request: GetChattingRequest)
    case postChatting(request: ChatSendRequest)
    case postFile(request: PostFileRequest)

    var environment: APIEnvironment { .production }

    var path: String {
        switch self {
        case .getChat, .postChat:
            return APIConstants.Endpoints.Chat.chat
        case .getChatting(let request):
            return APIConstants.Endpoints.Chat.chatting(request.roomID)
        case .postChatting(let request):
            return APIConstants.Endpoints.Chat.chatting(request.roomID)
        case .postFile(let request):
            return APIConstants.Endpoints.Chat.files(request.roomID)
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getChat, .getChatting:
            return .get
        case .postChat, .postChatting, .postFile:
            return .post
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .getChat, .getChatting:
            return nil
        case .postChat(let request):
            return [
                APIConstants.Parameters.Chat.opponentID: request.opponent_id
            ]
        case .postChatting(let request):
            return [
                APIConstants.Parameters.Chat.content: request.content,
                APIConstants.Parameters.Chat.files: request.files
            ]
        case .postFile(let request):
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
        case .getChatting(let request):
            return [.init(name: APIConstants.Query.Chat.next, value: request.next)]
        default:
            return nil
        }
    }
}
