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

    // Repository 추가
    private let repository: ChatRepositoryProtocol

    // Repository 주입 생성자 추가
    init(repository: ChatRepositoryProtocol = ChatRepository()) {
        self.repository = repository
    }

    // 🆕 로컬 데이터부터 로드하는 새로운 메서드
    func loadLocalChatHistory(roomID: String) async {
        await MainActor.run {
            isLoadingHistory = true
            historyError = nil
        }

        print("📱 [Local History] 로컬 데이터 로드 시작 - roomID: \(roomID)")

        let result = await repository.fetchMessages(roomID: roomID)

        await MainActor.run {
            switch result {
            case .success(let localMessages):
                messages = localMessages.sorted { $0.createdAt < $1.createdAt }
                print("✅ [Local History] 로컬 데이터 로드 성공: \(localMessages.count)개 메시지")

                // 로컬 데이터가 있으면 로딩 상태 해제
                if !localMessages.isEmpty {
                    isLoadingHistory = false
                }
            case .failure(let error):
                historyError = error.localizedDescription
                print("❌ [Local History] 로컬 데이터 로드 실패: \(error)")
                isLoadingHistory = false
            }
        }
    }

    // 기존 서버 데이터 로드 메서드 (수정됨 - 로컬 저장 추가)
    func loadChatHistory(roomID: String, next: String = "") async {
        // 로컬 데이터가 없을 때만 로딩 상태 설정
        if messages.isEmpty {
            await MainActor.run {
                isLoadingHistory = true
                historyError = nil
            }
        }

        do {
            print("🔍 [Server History] 서버 요청 시작 - roomID: \(roomID), next: \(next)")

            // 🔧 NetworkManager 사용하도록 변경
            let request = GetChattingRequest(roomID: roomID, next: next)
            let response = try await NetworkManager.shared.fetch(
                ChatRouter.getChatting(request: request),
                successType: GetChattingResponse.self,
                failureType: CommonMessageResponse.self
            )

            // 🔍 응답 상세 디버깅
            print("🔍 [Server History] 응답 상태:")
            print("  - statusCode: \(response.statusCode)")
            print("  - success 존재: \(response.success != nil)")
            print("  - failure 존재: \(response.failure != nil)")
            print("  - isFromCache: \(response.isFromCache)")

            if let success = response.success {
                print("✅ [Server History] 성공 응답 받음")
                print("  - 메시지 개수: \(success.data.count)")

                let serverMessages = success.data.map { $0.toEntity() }

                // 🆕 서버 메시지들을 로컬DB에 저장
                await saveMessagesToLocal(serverMessages, in: roomID)

                // 🆕 로컬DB에서 다시 조회하여 최신 데이터로 UI 업데이트
                await loadLocalChatHistory(roomID: roomID)

                await MainActor.run {
                    isLoadingHistory = false
                }

                print("✅ [Server History] 서버 데이터 동기화 완료: \(serverMessages.count)개 메시지")

            } else if let failure = response.failure {
                print("❌ [Server History] 실패 응답 받음")
                print("  - 에러 메시지: \(failure.message)")
                await MainActor.run {
                    isLoadingHistory = false
                    historyError = failure.message
                }
            } else {
                print("🚨 [Server History] Success와 Failure 모두 nil!")
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
            print("🚨 [Server History] 네트워크 에러: \(error)")
        }
    }

    // 🆕 서버 메시지들을 로컬DB에 저장하는 메서드
    private func saveMessagesToLocal(_ messages: [ChatMessageEntity], in roomID: String) async {
        print("💾 [Local Save] \(messages.count)개 메시지 로컬 저장 시작")

        for message in messages {
            let result = await repository.saveMessage(message, in: roomID)
            switch result {
            case .success:
                print("  ✅ 로컬 저장 성공: \(message.content)")
            case .failure(let error):
                print("  ❌ 로컬 저장 실패: \(message.content) - \(error)")
            }
        }

        print("💾 [Local Save] 로컬 저장 완료")
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

    // 메시지 전송 (수정됨 - 로컬 저장 추가)
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

                    // 🆕 서버 전송 성공 시 로컬DB에도 저장
                    Task {
                        let result = await repository.saveMessage(messageEntity, in: roomID)
                        switch result {
                        case .success:
                            print("✅ [Send Message] 전송된 메시지 로컬 저장 성공")
                        case .failure(let error):
                            print("❌ [Send Message] 전송된 메시지 로컬 저장 실패: \(error)")
                        }
                    }

                    // 메모리에도 추가
                    addMessage(messageEntity)
                    print("✅ [Send Message] 메시지 전송 성공: \(success.content)")
                } else if let failure = response.failure {
                    sendError = failure.message
                    print("❌ [Send Message] 메시지 전송 실패: \(failure.message)")
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
            print("🚨 [Send Message] 메시지 전송 에러: \(error)")
            return false
        }
    }

    // 🆕 실시간 메시지 수신 시 로컬 저장도 함께 하는 메서드
    func addMessageAndSaveToLocal(_ message: ChatMessageEntity, roomID: String) {
        // 메모리에 추가
        addMessage(message)

        // 로컬DB에 저장
        Task {
            let result = await repository.saveMessage(message, in: roomID)
            switch result {
            case .success:
                print("✅ [Realtime Message] 실시간 메시지 로컬 저장 성공")
            case .failure(let error):
                print("❌ [Realtime Message] 실시간 메시지 로컬 저장 실패: \(error)")
            }
        }
    }

    func addMessage(_ message: ChatMessageEntity) {
        if !messages.contains(where: { $0.id == message.id }) {
            messages.append(message)
            messages.sort { $0.createdAt < $1.createdAt }
            print("✅ [Memory] 메시지 메모리에 추가: \(message.content)")
        } else {
            print("📝 [Memory] 중복 메시지 감지, 추가하지 않음: \(message.content)")
        }
    }

    func removeMessage(withId id: String) {
        messages.removeAll { $0.id == id }

        // 🆕 로컬DB에서도 삭제
        Task {
            let result = await repository.deleteMessage(id: id)
            switch result {
            case .success:
                print("✅ [Delete Message] 메시지 로컬 삭제 성공")
            case .failure(let error):
                print("❌ [Delete Message] 메시지 로컬 삭제 실패: \(error)")
            }
        }
    }

    func clearMessages() {
        messages.removeAll()
        print("🗑️ [Memory] 메모리 메시지 전체 삭제")
    }

    // 🆕 로컬DB 전체 삭제 (개발/테스트용)
    func clearAllLocalData() async {
        let result = await repository.clearAllData()
        switch result {
        case .success:
            print("✅ [Clear All] 로컬DB 전체 삭제 성공")
            await MainActor.run {
                clearMessages()
            }
        case .failure(let error):
            print("❌ [Clear All] 로컬DB 전체 삭제 실패: \(error)")
        }
    }
}
