//
//  CommunityMainViewModel.swift
//  dimodamo
//
//  Created by JJIKKYU on 2020/10/16.
//  Copyright © 2020 JJIKKYU. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Firebase

class CommunityMainViewModel {
    
    private let storage = Storage.storage().reference()
    private let db = Firestore.firestore()
    
    var articles: [Article] = []
    var informationPosts: [Board] = []
    
    let articleLoading = BehaviorRelay<Bool>(value: false)
    let informationLoading = BehaviorRelay<Bool>(value: false)
    
    init() {
        // Article Setting
        // TODO : 정렬해서 가져와야함
        
        db.collection("articlePosts").getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("아티클 포스트를 가져오는데 오류가 생겼습니다. \(err)")
            } else {
                for (index, document) in querySnapshot!.documents.enumerated() {

                    let uid = (document.data()["uid"] as! String)
                    let title =  (document.data()["title"] as! String)
                    let tags =  (document.data()["tags"] as! [String])
                    let nickname = (document.data()["nickname"] as! String)
                    let scrapCnt = (document.data()["scrapCnt"] as! Int)
                    let commentCnt = (document.data()["commentCnt"] as! Int)
                    let author = (document.data()["author"] as! String)
                    
                    // [String] Image를 [URL?] Image로 변환
                    let documentImageString: [String] = document.data()["image"] as! [String]
                    let documnetImageURL: [URL?] = documentImageString.map { URL(string: $0) }
                    let images = documnetImageURL
                    
                    let article: Article = Article(uid: uid,
                                                   images: images,
                                                   videos : [],
                                                   category: .magazine,
                                                   title: title,
                                                   tags: tags,
                                                   profile: nil,
                                                   nickname: nickname,
                                                   author: author,
                                                   scrapCnt: scrapCnt,
                                                   commentCnt: commentCnt)
                    
                    self.articles.append(article)
                    
                    
                    // 로딩 유무 확인
                    if querySnapshot?.documents.count == (index + 1) {
                        articleLoading.accept(true)
                    }
                    
                    
//                    self.imageDownlad(postUID: document.documentID, index: index)
                    
                    
//                    print("\(document.documentID) => \(document.data()["title"])")
                }
            }
        }
        
        db.collection("hongik/information/posts")
            .order(by: "bundle_id")
            .getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("인포메이션 포스트를 가져오는데 오류가 생겼습니다. \(err)")
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
                    
                    let informationPost: Board = Board(boardId: boardId,
                                                       boardTitle: boardTitle,
                                                       bundleId: bundleId,
                                                       category: "",
                                                       commentCount: commentCount,
                                                       createdAt: "",
                                                       description: "",
                                                       images: [],
                                                       links: [],
                                                       nickname: nickname,
                                                       scrapCount: scrapCount,
                                                       tags: tags,
                                                       userDpti: userDpti,
                                                       userId: "",
                                                       videos: [])
                    
                    self.informationPosts.append(informationPost)
                    print(informationPost)
                    
                    // 로딩 유무 확인
                    if querySnapshot?.documents.count == (index + 1) {
                        informationLoading.accept(true)
                    }
                }
            }
            
        }
        
        
        
        
    }
    
//    func profileDownload() {
//        // profile Download
//        storage.child("test/profile.png").downloadURL(completion: { url, error in
//            guard let url = url, error == nil else {
//                return
//            }
//
////            let urlString = url.absoluteString
////            print("profileDownloadURL : \(urlString)")
//            self.articles[0].profile = url
//            print("loadingCompleted")
////            print("### articles[0] Profile = \(self.articles[0])")
//            self.profileLoading.accept(true)
//
//        })
//    }
    
//    func imageDownlad(postUID: String, index: Int) {
//        // image Download
//        storage.child("test/\(postUID).jpg").downloadURL(completion: { url, error in
//            guard let url = url, error == nil else {
//                return
//            }
//            let urlString = url.absoluteString
//            print("imageDownloadURL : \(urlString)")
//            self.articles[index].image = url
//            self.imageLoading.accept(true)
//        })
//
//    }
}
