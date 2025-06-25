//
//  ParticipantEntity.swift
//  PickMeUp
//
//  Created by 김태형 on 6/23/25.
//

import Foundation

struct ParticipantEntity: Equatable, Hashable {
    let userID: String
    let nick: String
    let profileImage: String?
}
