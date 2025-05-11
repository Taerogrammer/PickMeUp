//
//  APIError.swift
//  PickMeUp
//
//  Created by 김태형 on 5/11/25.
//

import Foundation

/*
enum APIError: Error, LocalizedError {
    case informationNeed     // 400: 필수값이 채워지지 않은 경우
    case invalidateToken     // 401: 유효하지 않은 token일 경우(공백 포함, 한글 포함 등), 계정 확인
    case noUserID            // 403: user_id 조회를 할 수 없는 경우(공백, 탈퇴한 회원 등)
    case unavailableEmail    // 409: 사용 불가 이메일, 이미 가입된 유저
    case refreshTokenExpire  // 418: refreshToken이 만료된 경우
    case accessTokenExpire   // 419: accessToken이 만료된 경우
    case invalidKey          // 420: header의 SeSACKey가 유효하지 않는 경우
    case tooManyRequest      // 429: 정해진 api 호출 횟수를 초과한 경우
    case abnormalRequest     // 444: 이외 서버관련 Error
    case serverError         // 500: 이외 서버관련 Error
    case unknown
}
*/

enum APIError: Error, LocalizedError {
    case serverMessage(String)
    case unknown
}
