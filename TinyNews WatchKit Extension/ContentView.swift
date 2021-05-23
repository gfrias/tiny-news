//
//  ContentView.swift
//  HelloWatch WatchKit Extension
//
//  Created by Guillermo Frias on 10/10/2020.
//

import SwiftUI
import Combine
import UIKit

struct ContentView: View {
    @ObservedObject var store: Store
    
    var body: some View {
        if let items = store.items[0] {
            return AnyView(
                List(items) { item in
                    NavigationLink(destination: StoryDetail(store: store, item: item)){
                        StoryRow(item: item)
                    }
                }.navigationTitle(Text("TinyNews")))
        } else {
            return AnyView(ProgressView())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(mock: true))
    }
}
