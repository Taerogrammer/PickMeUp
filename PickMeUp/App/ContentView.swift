//
//  ContentView.swift
//  PickMeUp
//
//  Created by 김태형 on 5/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            PrimaryButton {
                print("클릭")
            } content: {
                Text("lsdk")
            }

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
