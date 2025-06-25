//
//  CoreDataStack.swift
//  PickMeUp
//
//  Created by 김태형 on 6/25/25.
//

import CoreData
import Foundation

final class CoreDataStack {
    static let shared = CoreDataStack()

    private init() {}

    // MARK: - Persistent Container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ChatDataModel") // .xcdatamodeld 파일명과 일치해야 함

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // 개발 중에는 fatalError, 실제 배포 시에는 적절한 에러 처리 필요
                fatalError("CoreData 로드 실패: \(error), \(error.userInfo)")
            }

            print("✅ CoreData 스토어 로드 성공: \(storeDescription)")
        }

        // 자동 병합 설정
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy

        return container
    }()

    // MARK: - View Context (Main Thread)
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Background Context (Background Thread)
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }

    // MARK: - Save Context
    func saveViewContext() {
        let context = viewContext
        saveContext(context)
    }

    func saveContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
                print("✅ CoreData 저장 성공")
            } catch {
                print("❌ CoreData 저장 실패: \(error)")
                // 실제 앱에서는 사용자에게 알림이나 적절한 에러 처리 필요
            }
        }
    }
}
