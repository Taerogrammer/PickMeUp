//
//  WebViewRepresentable.swift
//  PickMeUp
//
//  Created by 김태형 on 6/9/25.
//

import SwiftUI
import WebKit

struct WebViewRepresentable: UIViewRepresentable {
    let webView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}
