//
//  ArticleDetailViewModel.swift
//  dimodamo
//
//  Created by JJIKKYU on 2020/10/19.
//  Copyright © 2020 JJIKKYU. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Firebase

import SwiftLinkPreview

class ArticleDetailViewModel {
    
    private let storage = Storage.storage().reference()
    private let db = Firestore.firestore()
    
    /*
     POSTUID를 main에서 prepare로 전달 받았을 경우에 초기화 시작
     */
    let postUidRelay = BehaviorRelay<String>(value: "")
    
    var categoryRelay = BehaviorRelay<String>(value: "")
    var titleRelay = BehaviorRelay<String>(value: "")
    var tagsRelay = BehaviorRelay<[String]>(value: [])
    
    /*
     이미지
     */
    let thumbnailImageRelay = BehaviorRelay<URL?>(value: URL(string: ""))
    let imagesRelay = BehaviorRelay<[URL?]>(value: [])
    
    /*
     본문 첨부 영상
     */
    let videosRelay = BehaviorRelay<[URL?]>(value: [])
    
    /*
     본문 텍스트
     */
    let descriptionRelay = BehaviorRelay<String>(value: "")
    
    /*
     URL link view
     */
    let linksDataRelay = BehaviorRelay<[PreviewResponse]>(value: []) // 링크에 있는 데이터를 해체해 가지고 있음
    let urlLinksRelay = BehaviorRelay<[String]>(value: []) // 링크만 가지고 있음
    static let slp = SwiftLinkPreview(cache: InMemoryCache())
    
    
    /*
     댓글
     */
    // 목록
    let commentsRelay = BehaviorRelay<[Comment]>(value: [])
    // 입력
    let commentInputRelay = BehaviorRelay<String>(value: "")
    
    func linkViewSetting() {
        var linksData: [PreviewResponse] = []
        
        for link in self.urlLinksRelay.value {
            // 캐시 체크
            if let cached = ArticleDetailViewModel.slp.cache.slp_getCachedResponse(url: "\(link)") {
                print("->> cached : \(cached)")
            }
            
            
            ArticleDetailViewModel.slp.previewLink("\(link)",
                                                   onSuccess: { [self] result in
                                                    let resultArr = result
                                                    let linkData: PreviewResponse = PreviewResponse(url: resultArr["url"] as! URL,
                                                                                                    title: resultArr["title"] as! String,
                                                                                                    image: resultArr["image"] as! String,
                                                                                                    icon: resultArr["icon"] as! String)
                                                    linksData.append(linkData)
                                                    
                                                    // 모든 데이터가 다 들어갔을 때 마지막 한 번만 호출
                                                    if urlLinksRelay.value.count == linksData.count {
                                                        self.linksDataRelay.accept(linksData)
                                                        //                                    print("ulrLinks.count = \(urlLinks.count), linksData = \(linksData.count)")
                                                    }
                                                   }, onError: { error in
                                                    print("\(error)")
                                                   })
        }
    }
    
    func dataSetting() {
        db.collection("articlePosts/").document("\(self.postUidRelay.value)").getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                
                let data = document.data()
                
                if let imagesArr: [String] = data!["image"] as? [String] {
                    let imagesUrlArr: [URL?] = imagesArr.map { URL(string: $0) }
                    self?.imagesRelay.accept(imagesUrlArr)
                }
                
                if let videosArr: [String] = data!["videos"] as? [String] {
                    let videosUrlArr: [URL?] = videosArr.map { URL(string: $0) }
                    self?.videosRelay.accept(videosUrlArr)
                }
                
                self?.descriptionRelay.accept(data!["description"] as! String)
                self?.urlLinksRelay.accept(data!["links"] as! [String])
                self?.commentSetting()
                //                print("documnetData : \(dataDescription)")
                
            } else {
                print("Documnet does not exist")
            }
        }
    }
    
    func commentSetting() {
        db.collection("hongik/article/comments/")
            .whereField("post_id", isEqualTo: postUidRelay.value)
            .whereField("is_deleted", isEqualTo: false)
            .order(by: "bundle_id")
            .getDocuments(completion: { [weak self] (querySnapshot, err) in
                if let err = err {
                    print("댓글을 가져오는데 실패했습니다. \(err.localizedDescription)")
                    return
                }
                
                // 코멘트를 담을 배열 생성
                var comments: [Comment] = []
                
                // 댓글을 성공적으로 가져왔을 경우
                for document in querySnapshot!.documents {
                    
                    let data = document.data()
                    
                    let comment: Comment = Comment()
                    comment.settingDataFromDocumentData(data: data)
                    comments.append(comment)
                    
                    print("setting완료 : \(comment.comment)")
                    
                    
                }
                
                self?.commentsRelay.accept(comments)
            })
    }
    
    func commentInput() {
        if commentInputRelay.value.count == 0 { return }
        
        let unixTimestamp = NSDate().timeIntervalSince1970
        let date = Date(timeIntervalSince1970: unixTimestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+9")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MM/dd HH:mm"
        let strDate = dateFormatter.string(from: date)
        
        // 유저 디폹트에서 닉네임을 불러옴
        let userDefaults = UserDefaults.standard
        let nickname: String = userDefaults.string(forKey: "nickname") ?? "익명"
        
        let comment: Comment = Comment()
        comment.setData(bundle_id: unixTimestamp,
                        bundle_order: unixTimestamp,
                        comment: self.commentInputRelay.value,
                        comment_id: "",
                        created_at: "\(strDate)",
                        depth: 0,
                        heart_count: 0,
                        is_deleted: false,
                        nickname: "\(nickname)",
                        post_id: self.postUidRelay.value,
                        user_id: Auth.auth().currentUser!.uid)
        
        var ref: DocumentReference? = nil
        
        ref = db.collection("hongik/article/comments").addDocument(data: comment.dictionary) {
            err in
            if let err = err {
                print("error adding document: \(err.localizedDescription)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                self.commentSetting()
                
            }
        }
        
    }
    
    init() {
        
        
    }
    
    
    
    
}
