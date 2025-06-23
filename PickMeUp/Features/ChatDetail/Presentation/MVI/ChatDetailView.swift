//
//  ChatDetailView.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import SwiftUI

struct ChatDetailView: View {
    let chatRoom: ChatRoomEntity
    let currentUserID: String

    var body: some View {
        VStack {
            Text("채팅방: \(chatRoom.roomID)")
            Text("상대방: \(opponentName)")

            // 실제 채팅 UI 구현
            Spacer()

            Text("여기에 채팅 메시지들이 표시됩니다")
                .foregroundColor(.secondary)

            Spacer()
        }
        .navigationTitle(opponentName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }

    private var opponentName: String {
        let opponent = chatRoom.participants.first { $0.userID != currentUserID }
        return opponent?.nick ?? "알 수 없는 사용자"
    }
}

//#Preview {
//    ChatDetailView()
//}
