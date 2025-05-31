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
    }
}

//#Preview {
//    RegisterScreen()
//}
