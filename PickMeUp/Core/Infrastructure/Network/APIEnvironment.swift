//
//  APIEnvironment.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import Foundation

enum APIEnvironment {
    case production

    var baseURL: String { return Bundle.value(forKey: "BASE_URL") }
    var webSocketBaseURL: String { return Bundle.value(forKey: "WebSocket_BASE_URL") }
    var pgID: String { return Bundle.value(forKey: "PGID") }
    var portOneUserCode: String { return Bundle.value(forKey: "PortOne_UserCode") }
    var name: String { return Bundle.value(forKey: "Name") }
    var appScheme: String { return Bundle.value(forKey: "AppScheme") }
    var naverClientSecret: String { return Bundle.value(forKey: "Naver_Client_Secret") }
    var naverClientID: String { return Bundle.value(forKey: "Naver_Client_ID") }
}
