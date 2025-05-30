//
//  TabbarReducer.swift
//  PickMeUp
//
//  Created by 김태형 on 5/30/25.
//

import Foundation

struct TabbarReducer {
    static func reduce(state: inout TabbarState, intent: TabbarIntent) {
        switch intent {
        case .selectTab(let tab):
            state.selectedTab = tab
        }
    }
}
