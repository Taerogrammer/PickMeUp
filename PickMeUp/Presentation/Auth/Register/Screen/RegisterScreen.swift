//
//  RegisterScreen.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import SwiftUI

struct RegisterScreen: View {
    @StateObject private var store: RegisterStore

    init(store: RegisterStore) {
        _store = StateObject(wrappedValue: store)
    }

    var body: some View {
        RegisterView(store: store)
            .navigationTitle("회원가입")
            .alert("알림", isPresented: .constant(store.state.alertMessage != nil)) {
                Button("확인") {
                    if store.state.isRegisterSuccess {
                        store.resetNavigation()
                    }
                    store.clearAlert()
                }
            } message: {
                Text(store.state.alertMessage ?? "")
            }
    }
}

#Preview {
    let container = RegisterStore(router: AppRouter())
    RegisterScreen(store: container)
}
