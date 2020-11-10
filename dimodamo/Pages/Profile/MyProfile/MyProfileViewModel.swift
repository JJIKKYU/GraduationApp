//
//  MyProfileViewModel.swift
//  dimodamo
//
//  Created by JJIKKYU on 2020/11/08.
//  Copyright © 2020 JJIKKYU. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Firebase

class MyProfileViewModel {
    
    private let storage = Storage.storage().reference()
    private let db = Firestore.firestore()
    
    let profileUID = BehaviorRelay<String>(value: "")
    
    let profileSetting = BehaviorRelay<String>(value: "")
    let userProfileData = BehaviorRelay<UserProfileData>(value: UserProfileData())
    var userNickname: String = ""
    
    var disposeBag = DisposeBag()
    
    init() {
        profileUID
            .subscribe(onNext: { uid in
                // uid가 정상적으로 들어왔을 경우 세팅하도록
                if uid != "" || uid.count != 0 {
                    print("uid가 넘어와서 세팅합니다 \(uid)")
                    self.userSetting(userUID: uid)
                } else {
                    print("uid가 정상적으로 넘어오지 않았습니다.")
                }
            })
            .disposed(by: disposeBag)
    }
    
    func getUserType() -> String {
        return self.userProfileData.value.dpti
    }
    
    func userSetting(userUID: String) {
        db.collection("users")
            .document("\(userUID)")
            .getDocument { [weak self] (document, err) in
                if let document = document, document.exists {
                    let data = document.data()
                    
                    let newUserProfile: UserProfileData = UserProfileData()
                    
                    if let nickname = data!["nickName"] as? String {
                        newUserProfile.nickname = nickname
                        self?.userNickname = nickname
                    }
                    
                    if let type = data!["dpti"] as? String {
                        newUserProfile.dpti = type
                        self?.profileSetting.accept(type)
                    }
                    
                    if let createdAt = data!["created_at"] as? String {
                        newUserProfile.createdAt = createdAt
                    }
                    
                    if let commentHeartCount = data!["get_comment_heart_count"] as? Int {
                        newUserProfile.commentHeartCount = commentHeartCount
                    }
                    
                    if let scrapCount = data!["get_scrap_count"] as? Int {
                        newUserProfile.scrapCount = scrapCount
                    }
                    
                    if let manitoGoodCount = data!["get_manito_good_count"] as? Int {
                        print("manitoGoodCount : \(manitoGoodCount)")
                        newUserProfile.manitoGoodCount = manitoGoodCount
                    }
                    
                    if let interests = data!["interest"] as? [String] {
                        print("interests : \(interests)")
                        newUserProfile.interests = interests
                    }
                    
                    self?.userProfileData.accept(newUserProfile)
                    print("userProfile = \(newUserProfile.commentHeartCount)")
                } else {
                    print("프로필에서 유저 데이터를 초기화하지 못했습니다.")
                }
                
                
            }
    }
    
    // 내 프로필일 경우에는 쪽지 보내기 버튼을 비활성화 하기 위해서
    func isMyProfile() -> Bool {
        let uid = profileUID.value
        let myUID = Auth.auth().currentUser!.uid
        
        if uid == myUID {
            print("내 프로필 입니다.")
            return true
        } else {
            print("내 프로필이 아닙니다.")
            return false
        }
    }
}