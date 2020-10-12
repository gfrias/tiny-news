//
//  Comment.swift
//  TinyNews WatchKit Extension
//
//  Created by Guillermo Frias on 11/10/2020.
//
import SwiftUI

struct Comment: Identifiable, Codable {
    var by: String?
    let id: Int
    var kids: [Int]?
    let parent: Int
    var text: String?
    let time: Int
    let type: String
    var deleted: Bool?
    
    func elapsedTime() -> String {
        let d = Date(timeIntervalSince1970:TimeInterval(self.time))
        return d.getElapsedInterval()
    }
}

struct CommentList: View {
    @ObservedObject var store: Store
    var itemId: Int
    var depth: Int
    
    init(store: Store, item: Item, depth: Int) {
        self.store = store
        self.itemId = item.id
        self.depth = depth
        
        store.loadComments(itemId: itemId, kids: item.kids )
    }
    
    init(store: Store, comment: Comment, depth: Int) {
        self.store = store
        self.itemId = comment.id
        self.depth = depth
        
        store.loadComments(itemId: itemId, kids: comment.kids ?? [] )
    }
    
    var body: some View {
        if let comments = self.store.comments[itemId] {
            if comments.count == 1 {
                CommentDetails(store: store, comment: comments[0], depth: self.depth)
            } else {
                List(comments) { comment in
                    if let text = comment.text {
                        NavigationLink(destination: CommentDetails(store: store, comment: comment, depth: self.depth)){
                            Text(text).lineLimit(2)
                        }
                    }
                }.navigationTitle((self.depth > 0 ? "[\(self.depth)] " : "") + "Comment")
            }
        } else {
            AnyView(ProgressView())
        }
    }
}

struct CommentDetails: View {
    var store: Store
    let comment: Comment
    var depth: Int
    
    init(store: Store, comment: Comment, depth: Int) {
        self.store = store
        self.comment = comment
        self.depth = depth
        store.loadComments(itemId: comment.id, kids: comment.kids ?? [])
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                Text("\(comment.by ?? "someone") (\(comment.elapsedTime())) wrote:").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                Text(comment.text ?? "").padding(.top)
                if let kids = comment.kids, kids.count > 0 {
                    NavigationLink(destination: buildDestination(comment: comment)){
                        Text("Replies (\(kids.count))")
                    }
                }
            }
        }.navigationTitle((self.depth > 0 ? "[\(self.depth)] " : "") + "Comment")
    }
    
    func buildDestination(comment: Comment) -> some View {
//        if let kids = comment.kids, kids.count == 1 {
//            return AnyView(CommentDetails(store: store, id: kids[0], depth: self.depth+1))
//
//        }
        return AnyView(CommentList(store: store, comment: comment, depth: self.depth+1))
    }
    
}

struct CommentList_Previews: PreviewProvider {
    static var previews: some View {
        let sampleStore = Store.makeSampleStore()
        
        if let item = sampleStore.listItems?[0] {
            return AnyView(CommentList(store: sampleStore, item: item, depth: 0))
        } else {
            return AnyView(EmptyView())
        }
    }
}
