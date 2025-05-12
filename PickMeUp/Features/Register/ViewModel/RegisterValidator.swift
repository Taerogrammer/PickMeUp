//
//  RegisterValidator.swift
//  PickMeUp
//
//  Created by 김태형 on 5/12/25.
//

import Foundation

struct RegisterValidator {
    func validateEmailFormat(_ email: String) -> Bool {
        let pattern = #"^\S+@\S+\.\S+$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    func validateNicknameFormat(_ nickname: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "., ,, ?, *, -, @")
        return nickname.rangeOfCharacter(from: invalidCharacters) == nil
    }

    func validatePasswordFormat(_ password: String) -> Bool {
        let pattern = #"^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$"#
        return password.range(of: pattern, options: .regularExpression) != nil
    }
}
