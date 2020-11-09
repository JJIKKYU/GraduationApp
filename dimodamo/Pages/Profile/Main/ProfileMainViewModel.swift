//
//  ProfileMainViewModel.swift
//  dimodamo
//
//  Created by JJIKKYU on 2020/11/04.
//  Copyright © 2020 JJIKKYU. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Firebase

class ProfileMainViewModel {
    
    private let storage = Storage.storage().reference()
    private let db = Firestore.firestore()
    
    let profileSetting = BehaviorRelay<String>(value: "")
    
    /*
     디모인
     */
    var dimoPeopleArr: [DimoPeople] = []
    let dimoPeopleArrIsLoading = BehaviorRelay<Bool>(value: false)
    
    
    init() {
        self.getUserType()
        self.loadDimoPeople()
    }
    
    func getUserType() {
        let type = UserDefaults.standard.string(forKey: "dpti") ?? "M_TI"
        profileSetting.accept(type)
    }
    
    func loadDimoPeople() {
        // 리로드 할 수도 있으니 비움
        self.dimoPeopleArr = []
        self.dimoPeopleArrIsLoading.accept(false)
        
        db.collection("users")
            .whereField("school", isEqualTo: "홍익대학교")
            .getDocuments{ [weak self] (querySnapshot, err) in
                if let err = err {
                    print("디모피플을 가져오는데 오류가 발생했습니다. \(err.localizedDescription)")
                } else {
                    
                    var newDimoPeopleArr: [DimoPeople] = []
                    
                    for (index, document) in querySnapshot!.documents.enumerated() {
                        let data = document.data()
                        let dimoPeopleData = DimoPeople()
                        
                        if let dptiType: String = data["dpti"] as? String {
                            dimoPeopleData.dpti = dptiType
                        }
                        
                        if let nickname: String = data["nickName"] as? String {
                            dimoPeopleData.nickname = nickname
                        }
                        
                        if let interests: [String] = data["interest"] as? [String] {
                            dimoPeopleData.interests = interests
                        }
                        
                        newDimoPeopleArr.append(dimoPeopleData)
                        print("newDimoPeopleArr = \(newDimoPeopleArr[index].nickname)")
                    }
                    
                    self?.dimoPeopleArr = newDimoPeopleArr
                    self?.dimoPeopleArrIsLoading.accept(true)
                }
            }
        
    }
}
