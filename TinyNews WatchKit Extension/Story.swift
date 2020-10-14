//
//  Story.swift
//  TinyNews WatchKit Extension
//
//  Created by Guillermo Frias on 13/10/2020.
//

import SwiftUI

struct StoryRow: View {
    let item: Item
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.title ?? "").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).lineLimit(2)
            Text(item.url ?? "").font(.footnote).lineLimit(1)
        }
    }
}

struct StoryDetail: View {
    var store: Store
    var item: Item
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(item.title ?? "").fontWeight(.bold)
                if let url = item.url {
                    NavigationLink(destination: WebView(url: url)) {
                        Text(url).foregroundColor(.blue)
                    }
                }
                if let kids = item.kids, kids.count > 0 {
                    NavigationLink(destination: CommentList(store: store, item: item, depth: 1)) {
                        Text("Comments (\(kids.count))")
                    }
                }
            }.navigationTitle(Text("Story"))
        }.navigationBarBackButtonHidden(false)
    }
}

//struct StoryDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        let sampleStore = Store.makeSampleStore()
//        if let item = sampleStore.listItems?[0] {
//            return AnyView(StoryDetail(store: sampleStore, item: item))
//        } else {
//            return AnyView(EmptyView())
//        }
//    }
//}
