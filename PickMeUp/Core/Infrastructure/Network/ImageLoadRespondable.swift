//
//  ImageLoadRespondable.swift
//  PickMeUp
//
//  Created by 김태형 on 6/3/25.
//

import SwiftUI

protocol ImageLoadRespondable {
    func onImageLoaded(_ image: UIImage)
    func onImageLoadFailed(_ errorMessage: String)
}
