//
//  ImageCacheManager.swift
//  PickMeUp
//
//  Created by 김태형 on 6/16/25.
//

import SwiftUI
import ImageIO

// MARK: - WWDC 2018 Session 416 공식 다운샘플링
final class ImageDownSampler {
    static func downsampleImage(at imageURL: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage? {
        // CGImageSource 생성 (캐시 비활성화로 메모리 효율성 증대)
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else { return nil }

        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale

        // 옵션 설정 (WWDC)
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,         // 항상 썸네일 생성
            kCGImageSourceShouldCacheImmediately: true,                 // 즉시 캐시하여 성능 향상
            kCGImageSourceCreateThumbnailWithTransform: true,           // 이미지 회전 정보 적용
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels   // 최대 픽셀 크기 제한
        ] as CFDictionary

        // 다운샘플링 실행 (메모리 스파이크 없이 원하는 크기로 생성)
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil }

        // 다운샘플링된 이미지를 UIImage로 변환
        return UIImage(cgImage: downsampledImage)
    }

    // 네트워크에서 받은 Data를 사용한 다운샘플링
    static func downsampleImage(from imageData: Data, to pointSize: CGSize, scale: CGFloat) -> UIImage? {

        // Data에서 이미지 소스 생성
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else { return nil }

        // 픽셀 단위 최대 크기 계산
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale

        // 다운샘플링 적용
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary

        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil }

        return UIImage(cgImage: downsampledImage)
    }
}
