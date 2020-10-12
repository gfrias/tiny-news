//
//  Item.swift
//  TinyNews WatchKit Extension
//
//  Created by Guillermo Frias on 10/10/2020.
//

import SwiftUI

struct Item: Identifiable, Codable {
    let by: String
    let descendants: Int
    let id: Int
    let kids: [Int]
    let score: Int
    let time: Int
    let title: String
    let type: String
    let url: String
}

struct ItemRow: View {
    let item: Item
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.title).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).lineLimit(2)
            Text(item.url).font(.footnote).lineLimit(1)
        }
    }
}
struct WebView: View {
    let url: String

    var body: some View {
        ImageView(withURL: url)
    }

}

struct ItemDetail: View {
    var store: Store
    var item: Item
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(item.title).fontWeight(.bold)
                NavigationLink(destination: WebView(url: item.url)) {
                    Text(item.url).foregroundColor(.blue)
                }
                NavigationLink(destination: CommentList(store: store, item: item, depth: 0)) {
                    Text("Comments (\(item.kids.count))")
                }
            }.navigationTitle(Text("Story"))
        }.navigationBarBackButtonHidden(false)
    }
}

struct ItemDetail_Previews: PreviewProvider {
    static var previews: some View {
        let sampleStore = Store.makeSampleStore()
        if let item = sampleStore.listItems?[0] {
            return AnyView(ItemDetail(store: sampleStore, item: item))
        } else {
            return AnyView(EmptyView())
        }
    }
}
