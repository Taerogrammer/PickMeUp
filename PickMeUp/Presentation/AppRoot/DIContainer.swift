//
//  DIContainer.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import SwiftUI

final class DIContainer: AuthViewProviding, OrderViewProviding, StoreViewProviding, StoreDetailViewProviding, ChatViewProviding, ProfileViewProviding {
    let router = AppRouter()

    // CoreData 관련 추가
    let coreDataStack: CoreDataStack
    let chatRepository: ChatRepositoryProtocol

    init() {
        self.coreDataStack = CoreDataStack.shared
        self.chatRepository = ChatRepository(coreDataStack: coreDataStack)
    }

    // ChatDetailStore 생성 시 Repository 주입
    func makeChatDetailStore(chatRoom: ChatRoomEntity, currentUserID: String) -> ChatDetailStore {
        return ChatDetailStore(
            chatRoom: chatRoom,
            currentUserID: currentUserID,
            messageManager: ChatMessageManager(repository: chatRepository), // Repository 주입
            socketManager: ChatSocketManager()
        )
    }

    // MARK: - AuthViewProviding
    func makeLandingView(appLaunchState: AppLaunchState) -> AnyView {
        let state = LandingState()
        let store = LandingStore(
            initialState: state,
            router: self.router,
            appLaunchState: appLaunchState
        )
        return AnyView(LandingView(store: store))
    }

    func makeRegisterScreen() -> AnyView {
        let store = RegisterStore(router: router)
        return AnyView(RegisterScreen(store: store))
    }

    // MARK: - OrderViewProviding
    func makeOrderScreen() -> AnyView {
        let state = OrderHistoryState()
        let effect = OrderHistoryEffect()
        let reducer = OrderHistoryReducer()

        let store = OrderHistoryStore(
            state: state,
            effect: effect,
            reducer: reducer
        )

        return AnyView(OrderScreen(store: store))
    }

    // MARK: - StoreViewProviding
    func makeStoreScreen() -> AnyView {
        let state = StoreListState()
        let effect = StoreListEffect()
        let reducer = StoreListReducer()
        let store = StoreListStore(
            state: state,
            effect: effect,
            reducer: reducer,
            router: self.router
        )
        return AnyView(StoreScreen(store: store))
    }

    // MARK: - StoreDetailViewProviding
    func makeStoreDetailScreen(storeID: String) -> AnyView {
        let state = StoreDetailState(
            storeID: storeID,
            entity: StoreDetailScreenEntity.placeholder(storeID: storeID),
            isLikeLoading: false
        )
        let effect = StoreDetailEffect()
        let reducer = StoreDetailReducer()
        let store = StoreDetailStore(
            state: state,
            effect: effect,
            reducer: reducer,
            router: self.router
        )
        return AnyView(StoreDetailScreen(store: store))
    }

    func makePaymentView(paymentInfo: PaymentInfoEntity) -> AnyView {
        return AnyView(PaymentView(
            paymentInfo: paymentInfo,
            router: router
        ))
    }

    // MARK: - ChattingViewProviding
    func makeChatScreen() -> AnyView {
        let state = ChatListState()
        let store = ChatListStore(state: state, router: self.router)
        return AnyView(ChatScreen(store: store))
    }

    // 채팅 상세 뷰 추가
    func makeChatDetailView(chatRoom: ChatRoomEntity, currentUserID: String) -> AnyView {
        return AnyView(ChatDetailView(
            chatRoom: chatRoom,
            currentUserID: currentUserID
        ))
    }

    // MARK: - ProfileViewProviding
    func makeProfileScreen() -> AnyView {
        let state = ProfileState(
            user: MeProfileResponse.empty,
            profile: MeProfileResponse.empty.toEntity()
        )
        let effect = ProfileEffect()
        let reducer = ProfileReducer()

        let store = ProfileStore(
            state: state,
            effect: effect,
            reducer: reducer,
            router: self.router
        )

        return AnyView(ProfileScreen(store: store))
    }

    func makeProfileEditScreen(user: ProfileEntity) -> AnyView {
        let state = ProfileEditState(profile: user)
        let effect = ProfileEditEffect()
        let reducer = ProfileEditReducer()
        let store = ProfileEditStore(
            state: state,
            reducer: reducer,
            effect: effect,
            router: self.router
        )
        return AnyView(ProfileEditScreen(store: store))
    }

}

extension DIContainer {
    @ViewBuilder
    func handleNavigation(route: AppRoute) -> some View {
        switch route {
        case .register:
            makeRegisterScreen()
        case .editProfile(let user):
            makeProfileEditScreen(user: user)
        case .storeDetail(let storeID):
            makeStoreDetailScreen(storeID: storeID)
        case .payment(let paymentInfo):
            makePaymentView(paymentInfo: paymentInfo)
        case .chatDetail(let chatRoom, let currentUserID):
            makeChatDetailView(chatRoom: chatRoom, currentUserID: currentUserID)
        }
    }
}

