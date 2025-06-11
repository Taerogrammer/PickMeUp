//
//  LocalNotificationManager.swift
//  PickMeUp
//
//  Created by 김태형 on 6/11/25.
//

import UserNotifications

class LocalNotificationManager: NSObject, ObservableObject {
    static let shared = LocalNotificationManager()

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    // 1. 권한 요청
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            return granted
        } catch {
            print("알림 권한 요청 실패: \(error)")
            return false
        }
    }

    // 2. 알림 스케줄링
    func scheduleNotification(
        id: String,
        title: String,
        body: String,
        timeInterval: TimeInterval
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInterval,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 스케줄링 실패: \(error)")
            }
        }
    }

    // 3. 알림 취소
    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension LocalNotificationManager: UNUserNotificationCenterDelegate {
    // 앱이 포그라운드에 있을 때도 알림 표시
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound, .badge])
    }

    // 알림 탭했을 때
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("알림 탭됨: \(response.notification.request.identifier)")
        completionHandler()
    }
}
