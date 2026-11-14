//
//  SwiftOpenAIChatApp.swift
//  SwiftOpenAIChat
//
//  Created by Anderson on 11/3/26.
//

import SwiftUI

@main
struct SwiftOpenAIChatApp: App {
    @StateObject private var viewModel = ChatViewModel()

    var body: some Scene {
        WindowGroup {
            ChatView(viewModel: viewModel)
        }
    }
}
