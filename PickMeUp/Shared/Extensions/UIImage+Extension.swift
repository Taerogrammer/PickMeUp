//
//  UIImage+Extension.swift
//  PickMeUp
//
//  Created by 김태형 on 6/3/25.
//

import SwiftUI

extension UIImage {
    func inferredFormat() -> ImageFormat {
        if let data = self.pngData(), data.starts(with: [0x89, 0x50, 0x4E, 0x47]) {
            return .png
        } else {
            return .jpeg
        }
    }

    var isPNG: Bool {
        guard let data = self.pngData() else { return false }
        return data.starts(with: [0x89, 0x50, 0x4E, 0x47])
    }

    var isJPEG: Bool {
        guard let data = self.jpegData(compressionQuality: 1.0) else { return false }
        return data.starts(with: [0xFF, 0xD8])
    }
}
