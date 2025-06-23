//
//  ChatDetailView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import SwiftUI

// MARK: - 채팅 메시지 Entity
struct ChatMessageEntity: Identifiable {
    let id: String
    let roomID: String
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let sender: SenderEntity
    let files: [String]

    var isFromCurrentUser: Bool {
        // 현재 사용자가 보낸 메시지인지 확인
        return false // 임시값, 나중에 currentUserID와 비교
    }
}

// MARK: - 수정된 ChatDetailView
struct ChatDetailView: View {
    let chatRoom: ChatRoomEntity
    let currentUserID: String

    @StateObject private var socketManager = ChatSocketManager()
    @StateObject private var messageManager = ChatMessageManager()
    @State private var newMessage: String = ""

    var body: some View {
        VStack(spacing: 0) {
            // 연결 상태 표시
            connectionStatusView

            // 채팅 메시지 목록
            messageListView

            // 메시지 입력 영역
            messageInputView
        }
        .navigationTitle(opponentName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            loadChatData()
        }
        .onDisappear {
            socketManager.disconnect()
        }
        .alert("오류", isPresented: .constant(messageManager.sendError != nil || messageManager.historyError != nil)) {
            Button("확인") {
                messageManager.sendError = nil
                messageManager.historyError = nil
            }
        } message: {
            if let sendError = messageManager.sendError {
                Text("전송 오류: \(sendError)")
            } else if let historyError = messageManager.historyError {
                Text("채팅 내역 로드 오류: \(historyError)")
            }
        }
    }

    // MARK: - 연결 상태 표시
    private var connectionStatusView: some View {
        HStack {
            Circle()
                .fill(socketManager.isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)

            Text(socketManager.isConnected ? "온라인" : "오프라인")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            if messageManager.isLoadingHistory {
                ProgressView()
                    .scaleEffect(0.8)
                Text("메시지 로딩 중...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if messageManager.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
                Text("전송 중...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }

    // MARK: - 메시지 목록
    private var messageListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    if messageManager.isLoadingHistory {
                        loadingMessagesView
                    } else if messageManager.messages.isEmpty {
                        emptyMessagesView
                    } else {
                        ForEach(messageManager.messages) { message in
                            MessageRow(
                                message: message,
                                isFromCurrentUser: message.sender.userID == currentUserID
                            )
                        }
                    }
                }
                .padding()
            }
            .onChange(of: messageManager.messages.count) { _ in
                // 새 메시지가 추가되면 스크롤을 맨 아래로
                if let lastMessage = messageManager.messages.last {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                // 메시지 로드 완료 후 맨 아래로 스크롤
                if let lastMessage = messageManager.messages.last {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: - 로딩 메시지 뷰
    private var loadingMessagesView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)

            Text("채팅 내역을 불러오는 중...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }

    // MARK: - 빈 메시지 뷰
    private var emptyMessagesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))

            Text("대화를 시작해보세요!")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("첫 메시지를 보내보세요.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }

    // MARK: - 메시지 입력 영역
    private var messageInputView: some View {
        HStack(spacing: 12) {
            // 메시지 입력 필드
            TextField("메시지를 입력하세요...", text: $newMessage, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(1...3)
                .disabled(messageManager.isLoading)

            // 전송 버튼
            Button(action: sendMessage) {
                if messageManager.isLoading {
                    ProgressView()
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                }
            }
            .frame(width: 36, height: 36)
            .background(canSendMessage ? Color.blue : Color.gray)
            .clipShape(Circle())
            .disabled(!canSendMessage || messageManager.isLoading)
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator)),
            alignment: .top
        )
    }

    // MARK: - Computed Properties
    private var opponentName: String {
        let opponent = chatRoom.participants.first { $0.userID != currentUserID }
        return opponent?.nick ?? "알 수 없는 사용자"
    }

    private var canSendMessage: Bool {
        !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Functions
    private func loadChatData() {
        // 1. 채팅 내역 로드
        Task {
            await messageManager.loadChatHistory(roomID: chatRoom.roomID)

            // 2. 소켓 연결 (채팅 내역 로드 후)
            await MainActor.run {
                socketManager.connect(roomID: chatRoom.roomID)
            }
        }
    }

    private func sendMessage() {
        let messageText = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageText.isEmpty else { return }

        // 낙관적 업데이트 - 임시 메시지 추가
        let tempID = "temp_\(UUID().uuidString)"
        let tempMessage = ChatMessageEntity(
            id: tempID,
            roomID: chatRoom.roomID,
            content: messageText,
            createdAt: Date(),
            updatedAt: Date(),
            sender: SenderEntity(
                userID: currentUserID,
                nick: "나",
                profileImage: nil
            ),
            files: []
        )

        messageManager.addMessage(tempMessage)
        newMessage = ""

        // 실제 전송
        Task {
            let success = await messageManager.sendMessage(
                roomID: chatRoom.roomID,
                content: messageText,
                files: nil
            )

            if success {
                // 전송 성공 - 임시 메시지 제거 (실제 메시지로 교체됨)
                await MainActor.run {
                    messageManager.removeMessage(withId: tempID)
                }
            } else {
                // 전송 실패 - 임시 메시지 제거
                await MainActor.run {
                    messageManager.removeMessage(withId: tempID)
                }
            }
        }
    }
}

// MARK: - MessageRow
struct MessageRow: View {
    let message: ChatMessageEntity
    let isFromCurrentUser: Bool

    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer(minLength: 50)
                myMessageBubble
            } else {
                otherMessageBubble
                Spacer(minLength: 50)
            }
        }
    }

    private var myMessageBubble: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(message.content)
                .font(.body)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.blue)
                .clipShape(MessageBubbleShape(isFromCurrentUser: true))

            Text(formattedTime)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    private var otherMessageBubble: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 8) {
                // 프로필 이미지 (간단한 버전)
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(message.sender.nick.prefix(1).uppercased())
                            .font(.caption)
                            .foregroundColor(.gray)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(message.sender.nick)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(message.content)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray5))
                        .clipShape(MessageBubbleShape(isFromCurrentUser: false))
                }
            }

            Text(formattedTime)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.leading, 40)
        }
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")

        if Calendar.current.isDateInToday(message.createdAt) {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "M/d HH:mm"
        }

        return formatter.string(from: message.createdAt)
    }
}

// MARK: - MessageBubbleShape
struct MessageBubbleShape: Shape {
    let isFromCurrentUser: Bool

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: isFromCurrentUser ?
                [.topLeft, .bottomLeft, .topRight] :
                [.topRight, .bottomRight, .topLeft],
            cornerRadii: CGSize(width: 16, height: 16)
        )
        return Path(path.cgPath)
    }
}
//#Preview {
//    ChatDetailView()
//}



// MARK: - 채팅 소켓 매니저 (URLSessionWebSocketTask 사용)
final class ChatSocketManager: NSObject, ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?

    @Published var isConnected: Bool = false
    @Published var connectionError: String?

    private let baseURL = "ws://pickup.sesac.kr:31668"

    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    // 소켓 연결
    func connect(roomID: String) {
        disconnect() // 기존 연결 해제

        guard let accessToken = KeychainManager.shared.load(key: KeychainType.accessToken.rawValue),
              let sesacKey = Bundle.main.object(forInfoDictionaryKey: "SeSACKey") as? String else {
            DispatchQueue.main.async {
                self.connectionError = "인증 정보가 없습니다."
            }
            return
        }

        // WebSocket URL 구성
        let socketURLString = "\(baseURL)/chats-\(roomID)"
        guard let socketURL = URL(string: socketURLString) else {
            DispatchQueue.main.async {
                self.connectionError = "잘못된 소켓 URL입니다."
            }
            return
        }

        // URLRequest 생성 및 헤더 설정
        var request = URLRequest(url: socketURL)
        request.setValue(accessToken, forHTTPHeaderField: "Authorization")
        request.setValue(sesacKey, forHTTPHeaderField: "SeSACKey")

        // WebSocket 연결 생성
        webSocketTask = urlSession?.webSocketTask(with: request)
        webSocketTask?.resume()

        // 메시지 수신 시작
        receiveMessage()

        print("🔌 Attempting to connect to: \(socketURLString)")
    }

    // 소켓 해제
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil

        DispatchQueue.main.async {
            self.isConnected = false
            self.connectionError = nil
        }

        print("🔌 Socket disconnected")
    }

    // 메시지 수신
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("📨 Received text: \(text)")
                    self?.handleReceivedMessage(text)
                case .data(let data):
                    print("📨 Received data: \(data)")
                    if let text = String(data: data, encoding: .utf8) {
                        self?.handleReceivedMessage(text)
                    }
                @unknown default:
                    print("📨 Unknown message type")
                }

                // 다음 메시지 수신을 위해 재귀 호출
                self?.receiveMessage()

            case .failure(let error):
                print("🚨 WebSocket receive error: \(error)")
                DispatchQueue.main.async {
                    self?.connectionError = "메시지 수신 오류: \(error.localizedDescription)"
                    self?.isConnected = false
                }
            }
        }
    }

    // 수신된 메시지 처리
    private func handleReceivedMessage(_ message: String) {
        // JSON 파싱하여 채팅 메시지 처리
        guard let data = message.data(using: .utf8) else { return }

        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("📨 Parsed message: \(json)")

                // 연결 확인 메시지인지 체크
                if let event = json["event"] as? String, event == "connected" {
                    DispatchQueue.main.async {
                        self.isConnected = true
                        self.connectionError = nil
                    }
                }

                // 채팅 메시지인지 체크
                if let chatData = json["chat_id"] as? String {
                    // TODO: 채팅 메시지 처리
                    print("💬 Chat message received: \(json)")
                }
            }
        } catch {
            print("🚨 JSON parsing error: \(error)")
        }
    }

    // 메시지 전송 (나중에 사용)
    func sendMessage(_ message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("🚨 Send error: \(error)")
            } else {
                print("📤 Message sent successfully")
            }
        }
    }
}

// MARK: - URLSessionWebSocketDelegate
extension ChatSocketManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("✅ WebSocket connected successfully")
        DispatchQueue.main.async {
            self.isConnected = true
            self.connectionError = nil
        }
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("❌ WebSocket disconnected with code: \(closeCode)")
        DispatchQueue.main.async {
            self.isConnected = false
        }
    }
}

class ChatMessageManager: ObservableObject {
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
