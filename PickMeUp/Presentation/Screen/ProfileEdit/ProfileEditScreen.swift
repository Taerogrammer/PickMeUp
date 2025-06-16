//
//  ProfileEdit.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import SwiftUI

struct ProfileEditScreen: View {
    @ObservedObject private var store: ProfileEditStore

    init(store: ProfileEditStore) {
        self.store = store
    }

    var body: some View {
        ProfileEditView(store: store)
    }
}
