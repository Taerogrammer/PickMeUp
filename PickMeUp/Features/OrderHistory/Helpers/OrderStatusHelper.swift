//
//  OrderStatusHelper.swift
//  PickMeUp
//
//  Created by 김태형 on 6/12/25.
//

import Foundation

struct OrderStatusHelper {
    // MARK: - Status Display Names
    static func getDisplayName(_ status: String) -> String {
        switch status {
        case "PENDING_APPROVAL": return "승인대기"
        case "APPROVED": return "주문승인"
        case "IN_PROGRESS": return "조리 중"
        case "READY_FOR_PICKUP": return "픽업대기"
        case "PICKED_UP": return "픽업완료"
        default: return status
        }
    }

    // MARK: - Button Configuration
    static func getButtonText(_ status: String) -> String {
        switch status {
        case "PENDING_APPROVAL": return "주문 승인"
        case "APPROVED": return "조리 시작하기"
        case "IN_PROGRESS": return "픽업대기"
        case "READY_FOR_PICKUP": return "픽업 하기"
        default: return "다음 단계로"
        }
    }

    static func getButtonIcon(_ status: String) -> String {
        switch status {
        case "PENDING_APPROVAL": return "checkmark.circle.fill"
        case "APPROVED": return "flame.fill"
        case "IN_PROGRESS": return "checkmark.shield.fill"
        case "READY_FOR_PICKUP": return "hand.raised.fill"
        default: return "arrow.right.circle.fill"
        }
    }

    // MARK: - Status Validation
    static func shouldShowActionButton(for status: String) -> Bool {
        return ["PENDING_APPROVAL", "APPROVED", "IN_PROGRESS", "READY_FOR_PICKUP"].contains(status)
    }

    static func isCompleted(_ status: String) -> Bool {
        return status == "PICKED_UP"
    }

    static func isPickupReady(_ status: String) -> Bool {
        return status == "READY_FOR_PICKUP"
    }
}

struct OrderCalculationHelper {
    // MARK: - Quantity Calculations
    static func getTotalQuantity(from orderData: OrderDataEntity) -> Int {
        return orderData.orderMenuList.reduce(0) { $0 + $1.quantity }
    }

    // MARK: - Price Calculations
    static func calculateItemTotal(price: Int, quantity: Int) -> Int {
        return price * quantity
    }

    static func formatPrice(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}

struct DateFormattingHelper {
    // MARK: - Date Formatters
    private static let inputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()

    private static let dateDisplayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d HH:mm"
        return formatter
    }()

    private static let timeDisplayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    // MARK: - Public Methods
    static func formatDate(_ dateString: String) -> String {
        guard let date = inputFormatter.date(from: dateString) else {
            return dateString
        }
        return dateDisplayFormatter.string(from: date)
    }

    static func formatTime(_ dateString: String) -> String {
        guard let date = inputFormatter.date(from: dateString) else {
            return dateString
        }
        return timeDisplayFormatter.string(from: date)
    }
}

extension Int {
    var formattedPrice: String {
        return OrderCalculationHelper.formatPrice(self)
    }
}

extension String {
    func formatAsOrderDate() -> String {
        return DateFormattingHelper.formatDate(self)
    }

    func formatAsOrderTime() -> String {
        return DateFormattingHelper.formatTime(self)
    }
}
