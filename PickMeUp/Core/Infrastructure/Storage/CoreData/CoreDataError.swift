//
//  CoreDataError.swift
//  PickMeUp
//
//  Created by 김태형 on 6/25/25.
//

import Foundation

enum CoreDataError: Error, LocalizedError {
    case saveError(Error)
    case fetchError(Error)
    case deleteError(Error)
    case entityNotFound
    case contextError

    var errorDescription: String? {
        switch self {
        case .saveError(let error):
            return "저장 실패: \(error.localizedDescription)"
        case .fetchError(let error):
            return "조회 실패: \(error.localizedDescription)"
        case .deleteError(let error):
            return "삭제 실패: \(error.localizedDescription)"
        case .entityNotFound:
            return "데이터를 찾을 수 없습니다"
        case .contextError:
            return "CoreData 컨텍스트 오류"
        }
    }
}
