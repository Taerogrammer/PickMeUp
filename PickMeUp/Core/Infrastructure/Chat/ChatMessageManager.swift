//
//  SocketMessage.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import Foundation

final class ChatMessageManager: ObservableObject {
    @Published var messages: [ChatMessageEntity] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingHistory: Bool = false
    @Published var sendError: String?
    @Published var historyError: String?

    // 채팅 내역 로드 (디버깅 강화 버전)
    func loadChatHistory(roomID: String, next: String = "") async {
        await MainActor.run {
            isLoadingHistory = true
            historyError = nil
        }

        do {
            print("🔍 [Chat History] 요청 시작 - roomID: \(roomID), next: \(next)")

            // 🔧 NetworkManager 사용하도록 변경
            let request = GetChattingRequest(roomID: roomID, next: next)
            let response = try await NetworkManager.shared.fetch(
                ChatRouter.getChatting(request: request),
                successType: GetChattingResponse.self,
                failureType: CommonMessageResponse.self
            )

            // 🔍 응답 상세 디버깅
            print("🔍 [Chat History] 응답 상태:")
            print("  - statusCode: \(response.statusCode)")
            print("  - success 존재: \(response.success != nil)")
            print("  - failure 존재: \(response.failure != nil)")
            print("  - isFromCache: \(response.isFromCache)")

            if let success = response.success {
                print("✅ [Chat History] 성공 응답 받음")
                print("  - 메시지 개수: \(success.data.count)")

                let chatMessages = success.data.map { $0.toEntity() }
                let sortedMessages = chatMessages.sorted { $0.createdAt < $1.createdAt }

                await MainActor.run {
                    isLoadingHistory = false
                    messages = sortedMessages
                }
                print("✅ 채팅 내역 로드 성공: \(sortedMessages.count)개 메시지")
            } else if let failure = response.failure {
                print("❌ [Chat History] 실패 응답 받음")
                print("  - 에러 메시지: \(failure.message)")
                await MainActor.run {
                    isLoadingHistory = false
                    historyError = failure.message
                }
            } else {
                print("🚨 [Chat History] Success와 Failure 모두 nil!")
                print("  - 이는 JSON 파싱 실패를 의미합니다.")
                print("  - StatusCode: \(response.statusCode)")

                // 🔍 원시 응답 확인을 위한 추가 요청
                await debugRawResponse(roomID: roomID, next: next)

                await MainActor.run {
                    isLoadingHistory = false
                    historyError = "응답 파싱 실패 (StatusCode: \(response.statusCode))"
                }
            }

        } catch {
            await MainActor.run {
                isLoadingHistory = false
                historyError = "네트워크 오류: \(error.localizedDescription)"
            }
            print("🚨 채팅 내역 로드 에러: \(error)")
        }
    }

    // 🔍 원시 응답 디버깅 함수
    private func debugRawResponse(roomID: String, next: String) async {
        do {
            let url = URL(string: "http://pickup.sesac.kr:31668/v1/chats/\(roomID)")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            // 헤더 설정
            if let accessToken = KeychainManager.shared.load(key: KeychainType.accessToken.rawValue) {
                request.setValue(accessToken, forHTTPHeaderField: "Authorization")
            }
            if let sesacKey = Bundle.main.object(forInfoDictionaryKey: "SeSACKey") as? String {
                request.setValue(sesacKey, forHTTPHeaderField: "SeSACKey")
            }

            // next 파라미터가 있으면 쿼리에 추가
            if !next.isEmpty {
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                components?.queryItems = [URLQueryItem(name: "next", value: next)]
                request.url = components?.url
            }

            let (data, response) = try await URLSession.shared.data(for: request)

            print("🔍 [Raw Response Debug]")
            if let httpResponse = response as? HTTPURLResponse {
                print("  - Status Code: \(httpResponse.statusCode)")
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("  - Raw JSON: \(jsonString)")
            }

        } catch {
            print("🚨 [Raw Response Debug] 실패: \(error)")
        }
    }

    // 기존 메서드들...
    func sendMessage(roomID: String, content: String, files: [String]? = nil) async -> Bool {
        await MainActor.run {
            isLoading = true
            sendError = nil
        }

        let request = ChatSendRequest(
            roomID: roomID,
            content: content,
            files: files
        )

        do {
            let response = try await NetworkManager.shared.fetch(
                ChatRouter.postChatting(request: request),
                successType: ChatSendResponse.self,
                failureType: CommonMessageResponse.self
            )

            await MainActor.run {
                isLoading = false

                if let success = response.success {
                    let messageEntity = success.toEntity()
                    addMessage(messageEntity)
                    print("✅ 메시지 전송 성공: \(success.content)")
                } else if let failure = response.failure {
                    sendError = failure.message
                    print("❌ 메시지 전송 실패: \(failure.message)")
                } else {
                    sendError = "메시지 전송 실패"
                }
            }

            return response.success != nil

        } catch {
            await MainActor.run {
                isLoading = false
                sendError = "네트워크 오류: \(error.localizedDescription)"
            }
            print("🚨 메시지 전송 에러: \(error)")
            return false
        }
    }

    func addMessage(_ message: ChatMessageEntity) {
        if !messages.contains(where: { $0.id == message.id }) {
            messages.append(message)
            messages.sort { $0.createdAt < $1.createdAt }
        }
    }

    func removeMessage(withId id: String) {
        messages.removeAll { $0.id == id }
    }

    func clearMessages() {
        messages.removeAll()
    }
}
