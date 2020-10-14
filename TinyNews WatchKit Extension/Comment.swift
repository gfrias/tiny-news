//
//  Comment.swift
//  TinyNews WatchKit Extension
//
//  Created by Guillermo Frias on 11/10/2020.
//
import SwiftUI

struct CommentList: View {
    @ObservedObject var store: Store
    var item: Item
    var depth: Int
    
    init(store: Store, item: Item, depth: Int) {
        self.store = store
        self.item = item
        self.depth = depth
        self.store.loadItems(parent: item.id, ids: item.kids ?? [])
    }
    
    var body: some View {
        if let comments = self.store.items[item.id] {
            if comments.count == 1 {
                CommentDetails(store: store, comment: comments[0], depth: self.depth)
            } else {
                List(comments) { comment in
                    if let text = comment.text {
                        NavigationLink(destination: CommentDetails(store: store, comment: comment, depth: self.depth)){
                            Text(text).lineLimit(2)
                        }
                    }
                }.navigationTitle("[\(self.depth)] Comment")
            }
        } else {
            AnyView(ProgressView())
        }
    }
}

struct CommentDetails: View {
    var store: Store
    let comment: Item
    var depth: Int
    
    init(store: Store, comment: Item, depth: Int) {
        self.store = store
        self.comment = comment
        self.depth = depth
        
        if store.items[comment.id] == nil {
            store.loadItems(parent: comment.id, ids: comment.kids ?? [])
        }
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                Text("\(comment.by ?? "someone") (\(comment.elapsedTime())) wrote:").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                Spacer()
                Text(comment.text ?? "")
                if let item = store.items[comment.id], item.count > 0 {
                    NavigationLink(destination: buildDestination(comment: comment)){
                        Text("Replies (\(item.count))")
                    }
                }
            }.frame(minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: .infinity,
                    alignment: .topLeading)
        }.navigationTitle("[\(self.depth)] Comment")
    }
    
    func buildDestination(comment: Item) -> some View {
        return AnyView(CommentList(store: store, item: comment, depth: self.depth+1))
    }
    
}
