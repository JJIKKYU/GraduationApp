//
//  DptiResultViewController.swift
//  dimodamo
//
//  Created by JJIKKYU on 2020/09/11.
//  Copyright © 2020 JJIKKYU. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class DptiResultViewController: UIViewController {

    @IBOutlet weak var resultCardView: UIView!
    @IBOutlet weak var typeTitle: UILabel!
    @IBOutlet weak var typeDesc: UITextView!
    @IBOutlet weak var positionIcon: UIImageView!
    @IBOutlet weak var positionDesc: UILabel!
    @IBOutlet weak var circleNumber: UILabel!
    @IBOutlet var designs : Array<UILabel>!
    @IBOutlet var designsDesc : Array<UILabel>!
    @IBOutlet weak var toolImg: UIImageView!
    @IBOutlet weak var toolName: UILabel!
    @IBOutlet weak var toolDesc: UITextView!
    @IBOutlet weak var todo: UITextView!
    
    
    @IBOutlet var circleNumbers : Array<UILabel>?
    
    let viewModel = DptiResultViewModel()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Title Binding
        viewModel.typeTitle
            .map { "\($0)"}
            .asDriver(onErrorJustReturn: "")
            .drive(typeTitle.rx.text)
            .disposed(by: disposeBag)
        
        // TypeDesc Binding
        viewModel.typeDesc
            .map { "\($0)"}
            .asDriver(onErrorJustReturn: "")
            .drive(typeDesc.rx.text)
            .disposed(by: disposeBag)
        
        // Position Binding
        viewModel.positonDesc
            .map { "\($0)"}
            .asDriver(onErrorJustReturn: "")
            .drive(positionDesc.rx.text)
            .disposed(by: disposeBag)
        
        // Design Binding
        viewModel.designs
            .map{ "\($0[0])" }
            .asDriver(onErrorJustReturn: "")
            .drive(designs[0].rx.text)
            .disposed(by: disposeBag)
        
        viewModel.designsDesc
            .map{ "\($0[0])"}
            .asDriver(onErrorJustReturn: "")
            .drive(designsDesc[0].rx.text)
            .disposed(by: disposeBag)
    
        viewModel.designs
            .map{ "\($0[1])" }
            .asDriver(onErrorJustReturn: "")
            .drive(designs[1].rx.text)
            .disposed(by: disposeBag)
        
        viewModel.designsDesc
            .map{ "\($0[1])"}
            .asDriver(onErrorJustReturn: "")
            .drive(designsDesc[1].rx.text)
            .disposed(by: disposeBag)
    
        
        // Tool Binding
        
        viewModel.toolName
            .map{ "\($0)" }
            .asDriver(onErrorJustReturn: "")
            .drive(toolName.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.toolDesc
            .map{ "\($0)"}
            .asDriver(onErrorJustReturn: "")
            .drive(toolDesc.rx.text)
            .disposed(by: disposeBag)
        
        // Todo Binding
        
        viewModel.todoDesc
            .map { "\($0)" }
            .asDriver(onErrorJustReturn: "")
            .drive(todo.rx.text)
            .disposed(by: disposeBag)
        
        resultCardViewInit()
        circleNumberSetting()
    }

    
    func resultCardViewInit() {
        resultCardView.layer.cornerRadius = 24
        resultCardView.addShadow(offset: CGSize(width: 0, height: 4), color: UIColor.black, radius: 16, opacity: 0.12)
    }
    
    func circleNumberSetting() {
        for circleNumber in circleNumbers! {
            circleNumber.layer.cornerRadius = 16
            circleNumber.layer.masksToBounds = true
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

