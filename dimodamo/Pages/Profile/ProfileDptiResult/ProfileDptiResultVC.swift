//
//  ProfileDptiResultVC.swift
//  dimodamo
//
//  Created by JJIKKYU on 2020/11/07.
//  Copyright © 2020 JJIKKYU. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class ProfileDptiResultVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var resultCardView: UIView! {
        didSet {
            resultCardView.layer.cornerRadius = 24
            let aspectRatioHeight: CGFloat = (348 / 414) * UIScreen.main.bounds.width
            resultCardView.heightAnchor.constraint(equalToConstant: aspectRatioHeight).isActive = true
            resultCardView.appShadow(.s12)
        }
    }
    @IBOutlet weak var typeTitle: UILabel!
    @IBOutlet weak var typeIcon: UIImageView! {
        didSet {
            typeIcon.appShadow(.s12)
        }
    }
    @IBOutlet weak var typeDesc: UITextView!
    @IBOutlet weak var typeChar: UIImageView!
    @IBOutlet weak var patternBG: UIImageView!
    @IBOutlet weak var positionIcon: UIImageView!
    @IBOutlet weak var positionDesc: UILabel! {
        didSet {
            positionDesc.textColor = UIColor.appColor(.system)
        }
    }
    @IBOutlet var designs : [UILabel]! {
        didSet {
            for design in designs {
                design.textColor = UIColor.appColor(.system)
            }
        }
    }
    @IBOutlet var designsDesc : [UILabel]!
    @IBOutlet weak var toolImg: UIImageView!
    @IBOutlet weak var toolName: UILabel! {
        didSet {
            toolName.textColor = UIColor.appColor(.system)
        }
    }
    @IBOutlet weak var toolDesc: UITextView!
    @IBOutlet weak var todo: UITextView!
    @IBOutlet var circleNumbers : [UILabel]! {
        didSet {
            for number in circleNumbers {
                number.layer.cornerRadius = 16
                number.layer.masksToBounds = true
                number.backgroundColor = UIColor.appColor(.system)
            }
        }
    }
    
    @IBOutlet weak var allTypeBtn: UIButton! {
        didSet {
            allTypeBtn.layer.cornerRadius = 16
            allTypeBtn.layer.masksToBounds = true
        }
    }
    
    let viewModel = ProfileDptiResultViewModel()
    var disposeBag = DisposeBag()
    
    
    /*
     ViewLoad
     */
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        setColors()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        animate()
    }
    
    private func animate() {
        guard let coordinator = self.transitionCoordinator else {
            return
        }
        coordinator.animate(alongsideTransition: {
            [weak self] context in
            self?.setColors()
        }, completion: nil)
    }
    
    private func setColors(){
        navigationController?.navigationBar.tintColor = UIColor.appColor(.system)
        navigationController?.navigationBar.barTintColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        setColors()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // UILabel Binding
        viewModel.resultObservable.flatMap { [weak self] in
            Observable.from([
                ($0.title, self?.typeTitle),
                ($0.design[0], self?.designs[0]),
                ($0.design[1], self?.designs[1]),
                ($0.toolName, self?.toolName),
                ($0.position, self?.positionDesc),
            ])
        }
        .asDriver(onErrorJustReturn: ("", nil))
        .drive(onNext: { text, label in
            label?.text = text
        })
        .disposed(by: disposeBag)
        
        // TypeDesc Binding
        viewModel.typeDesc
            .map { "\($0)"}
            .asDriver(onErrorJustReturn: "")
            .drive(typeDesc.rx.text)
            .disposed(by: disposeBag)
    
        
        viewModel.designsDesc
            .map{ "\($0[0])"}
            .asDriver(onErrorJustReturn: "")
            .drive(designsDesc[0].rx.text)
            .disposed(by: disposeBag)

        
        viewModel.designsDesc
            .map{ "\($0[1])"}
            .asDriver(onErrorJustReturn: "")
            .drive(designsDesc[1].rx.text)
            .disposed(by: disposeBag)
    
        
        // UITextView Binding
        viewModel.resultObservable.flatMap { [weak self] in
            Observable.from([
                ($0.toolDesc, self?.toolDesc),
                ($0.todo, self?.todo)
            ])
        }
        .asDriver(onErrorJustReturn: ("", nil))
        .drive(onNext: { text, textView in
            textView?.text = text
        })
        .disposed(by: disposeBag)
        
        // UIImage Binding
        viewModel.resultObservable.flatMap { [weak self] in
            Observable.from([
                ("BC_Type_\($0.shape)", self?.typeIcon),
                ("BC_BG_P_\($0.shape)", self?.patternBG),
                ("Icon_\($0.type)", self?.positionIcon),
                ($0.toolImg, self?.toolImg)
            ])
        }
        .asDriver(onErrorJustReturn: ("", nil))
        .drive(onNext: { imageName, uiImage in
            print("이미지 네임 : \(imageName), 이미지 : \(uiImage)")
            uiImage!.image = UIImage(named : imageName)
        })
        .disposed(by: disposeBag)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func pressedAllTypeBtn(_ sender: Any) {
        performSegue(withIdentifier: "AllTypeDptiVC", sender: nil)
    }
    
}
