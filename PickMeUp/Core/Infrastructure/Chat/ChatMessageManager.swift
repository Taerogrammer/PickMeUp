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

    // 이미 저장된 메시지 ID 추적
    private var savedMessageIDs: Set<String> = []

    // Repository 주입 생성자 추가
    init(repository: ChatRepositoryProtocol = ChatRepository()) {
        self.repository = repository
    }

    // MARK: - 로컬 데이터 로드
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

                // 로컬에서 로드된 메시지들의 ID를 추적 목록에 추가
                savedMessageIDs = Set(localMessages.map { $0.id })

                print("✅ [Local History] 로컬 데이터 로드 성공: \(localMessages.count)개 메시지")
                print("📝 [Local History] 추적 중인 메시지 ID: \(savedMessageIDs.count)개")

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

    // MARK: - 서버 데이터 동기화
    func loadChatHistory(roomID: String, next: String = "") async {
        let hasLocalData = !messages.isEmpty

        if !hasLocalData {
            await MainActor.run {
                isLoadingHistory = true
                historyError = nil
            }
        }

        do {
            print("🔍 [Server History] 서버 동기화 시작 - roomID: \(roomID)")

            let request = GetChattingRequest(roomID: roomID, next: next)
            let response = try await NetworkManager.shared.fetch(
                ChatRouter.getChatting(request: request),
                successType: GetChattingResponse.self,
                failureType: CommonMessageResponse.self
            )

            // 응답 상세 디버깅
            print("🔍 [Server History] 응답 상태:")
            print("  - statusCode: \(response.statusCode)")
            print("  - success 존재: \(response.success != nil)")
            print("  - failure 존재: \(response.failure != nil)")
            print("  - isFromCache: \(response.isFromCache)")

            if let success = response.success {
                print("✅ [Server History] 서버 응답: \(success.data.count)개 메시지")

                let serverMessages = success.data.map { $0.toEntity() }

                // 새로운 메시지만 필터링 (메모리 기준)
                let newMessages = filterNewMessages(serverMessages)

                if newMessages.isEmpty {
                    print("📝 [Server History] 새 메시지 없음")
                } else {
                    print("🆕 [Server History] 새 메시지 \(newMessages.count)개 발견")

                    // 새 메시지만 저장
                    await saveNewMessagesToLocal(newMessages, in: roomID)

                    // UI 업데이트를 위해 메모리에도 추가
                    await MainActor.run {
                        for message in newMessages {
                            addMessage(message)
                        }
                    }
                }

                await MainActor.run {
                    isLoadingHistory = false
                }

                print("✅ [Server History] 동기화 완료")

            } else if let failure = response.failure {
                print("❌ [Server History] 서버 실패: \(failure.message)")
                await MainActor.run {
                    isLoadingHistory = false
                    if !hasLocalData {
                        historyError = failure.message
                    }
                }
            } else {
                print("🚨 [Server History] Success와 Failure 모두 nil!")
                print("  - 이는 JSON 파싱 실패를 의미합니다.")
                print("  - StatusCode: \(response.statusCode)")

                // 원시 응답 확인을 위한 추가 요청
                await debugRawResponse(roomID: roomID, next: next)

                await MainActor.run {
                    isLoadingHistory = false
                    if !hasLocalData {
                        historyError = "응답 파싱 실패 (StatusCode: \(response.statusCode))"
                    }
                }
            }

        } catch {
            print("🚨 [Server History] 네트워크 에러: \(error)")
            await MainActor.run {
                isLoadingHistory = false
                if !hasLocalData {
                    historyError = "오프라인 상태입니다. 네트워크를 확인해주세요."
                } else {
                    print("📱 [Offline] 로컬 데이터 \(messages.count)개로 오프라인 모드 동작")
                }
            }
        }
    }

    // MARK: - Helper Methods

    // 새로운 메시지만 필터링 (메모리 기준)
    private func filterNewMessages(_ serverMessages: [ChatMessageEntity]) -> [ChatMessageEntity] {
        let existingIDs = Set(messages.map { $0.id })
        return serverMessages.filter { !existingIDs.contains($0.id) }
    }

    // 새 메시지만 로컬에 저장
    private func saveNewMessagesToLocal(_ newMessages: [ChatMessageEntity], in roomID: String) async {
        guard !newMessages.isEmpty else { return }

        print("💾 [Local Save] \(newMessages.count)개 새 메시지 저장 시작")

        for message in newMessages {
            let result = await repository.saveMessage(message, in: roomID)
            switch result {
            case .success:
                savedMessageIDs.insert(message.id)
                print("  ✅ 새 메시지 저장: \(message.content)")
            case .failure(let error):
                print("  ❌ 저장 실패: \(message.content) - \(error)")
            }
        }

        print("💾 [Local Save] 새 메시지 저장 완료")
    }

    // 원시 응답 디버깅 함수
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

    // MARK: - 메시지 전송
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

                    // 이미 저장되지 않은 메시지만 로컬 저장
                    if !savedMessageIDs.contains(messageEntity.id) {
                        Task {
                            let result = await repository.saveMessage(messageEntity, in: roomID)
                            switch result {
                            case .success:
                                savedMessageIDs.insert(messageEntity.id)
                                print("✅ [Send Message] 전송된 메시지 로컬 저장 성공")
                            case .failure(let error):
                                print("❌ [Send Message] 전송된 메시지 로컬 저장 실패: \(error)")
                            }
                        }
                    } else {
                        print("📝 [Send Message] 이미 저장된 메시지, 로컬 저장 스킵")
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

    // MARK: - 실시간 메시지 처리

    // 실시간 메시지 수신 시 로컬 저장도 함께 하는 메서드
    func addMessageAndSaveToLocal(_ message: ChatMessageEntity, roomID: String) {
        // 메모리에 추가
        addMessage(message)

        // 이미 저장되지 않은 메시지만 로컬 저장
        if !savedMessageIDs.contains(message.id) {
            Task {
                let result = await repository.saveMessage(message, in: roomID)
                switch result {
                case .success:
                    savedMessageIDs.insert(message.id)
                    print("✅ [Realtime Message] 실시간 메시지 로컬 저장 성공")
                case .failure(let error):
                    print("❌ [Realtime Message] 실시간 메시지 로컬 저장 실패: \(error)")
                }
            }
        } else {
            print("📝 [Realtime Message] 이미 저장된 메시지, 로컬 저장 스킵")
        }
    }

    // MARK: - 메시지 관리

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
        savedMessageIDs.remove(id) // 추적 목록에서도 제거

        // 로컬DB에서도 삭제
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
        savedMessageIDs.removeAll()
        print("🗑️ [Memory] 메모리 메시지 및 추적 목록 전체 삭제")
    }

    // 로컬DB 전체 삭제 (개발/테스트용)
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
