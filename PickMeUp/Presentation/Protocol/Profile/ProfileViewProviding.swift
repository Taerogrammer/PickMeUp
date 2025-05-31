//
//  ProfileViewProviding.swift
//  PickMeUp
//
//  Created by 김태형 on 5/31/25.
//

import SwiftUI

protocol ProfileViewProviding {
    func makeProfileScreen() -> AnyView
    func makeProfileEditView(user: ProfileEntity) -> AnyView
}
