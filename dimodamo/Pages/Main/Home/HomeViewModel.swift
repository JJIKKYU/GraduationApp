//
//  HomeViewModel.swift
//  dimodamo
//
//  Created by JJIKKYU on 2020/11/23.
//  Copyright © 2020 JJIKKYU. All rights reserved.
//

import Foundation

import Firebase

import RxSwift
import RxRelay

class HomeViewModel {
    
    private let storage = Storage.storage().reference()
    private let db = Firestore.firestore()
    
    let userUID: String = Auth.auth().currentUser?.uid ?? ""
    
    func myDptiType() -> String {
        let type = UserDefaults.standard.string(forKey: "dpti") ?? "M_TI"
        return type
    }
    
    func myNickname() -> String {
        let nickname = UserDefaults.standard.string(forKey: "nickname") ?? "익명"
        return nickname
    }
    
    /*
     ArticlePost
     */
    let articleLoading = BehaviorRelay<Bool>(value: false)
    var articlePost: Board?
    
    init() {
        self.loadArticlePost()
    }
    
    func loadArticlePost() {
        // 리로드 할 수도 있으니 비움
        self.articlePost = nil
        self.articleLoading.accept(false)
        
        print("### articleLoading : \(articleLoading.value)")
        
        db.collection("hongik/article/posts")
            .order(by: "bundle_id", descending: true)
            .limit(to: 1)
            .getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("아티클 포스트를 가져오는데 오류가 생겼습니다. \(err)")
            } else {
                for (index, document) in querySnapshot!.documents.enumerated() {

                    let boardId = (document.data()["board_id"] as? String) ?? ""
                    let boardTitle = (document.data()["board_title"] as? String) ?? ""
                    let bundleId = (document.data()["bundle_id"] as? Double) ?? 0
                    let commentCount = (document.data()["comment_count"] as? Int) ?? 0
                    let nickname = (document.data()["nickname"] as? String) ?? ""
                    let scrapCount = (document.data()["scrap_count"] as? Int) ?? 0
                    let tags = (document.data()["tags"] as? [String]) ?? []
                    let userDpti = (document.data()["user_dpti"] as? String) ?? ""
                    
                    // [String] Image를 [URL?] Image로 변환
                    var images: [String]? = []
                    if let documentImageString: [String] = document.data()["images"] as? [String] {
//                        let documnetImageURL: [URL?] = documentImageString.map { URL(string: $0) }
                        images = documentImageString
                    }
                    
                    
                    let articlePost: Board = Board(boardId: boardId,
                                                       boardTitle: boardTitle,
                                                       bundleId: bundleId,
                                                       category: "",
                                                       commentCount: commentCount,
                                                       createdAt: "",
                                                       description: "",
                                                       images: images,
                                                       links: [],
                                                       nickname: nickname,
                                                       scrapCount: scrapCount,
                                                       tags: tags,
                                                       userDpti: userDpti,
                                                       userId: "",
                                                       videos: [])
                    
                    print(articlePost)
                    
                    self.articlePost = articlePost
                    
                    
                    // 로딩 유무 확인
                    if querySnapshot?.documents.count == (index + 1) {
                        articleLoading.accept(true)
                        print("### articleLoading : \(articleLoading.value)")
                    }
                }
            }
        }
    }
}
