//
//  TinyNewsApp.swift
//  TinyNews WatchKit Extension
//
//  Created by Guillermo Frias on 10/10/2020.
//

import SwiftUI

@main
struct TinyNewsApp: App {
    let store = Store()
    
    init() {
        self.store.loadTopStories()
    }
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(store: store).accentColor(.orange)
            }
        }
    }
}
