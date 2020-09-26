//
//  RegisterIDViewController.swift
//  dimodamo
//
//  Created by JJIKKYU on 2020/09/26.
//  Copyright © 2020 JJIKKYU. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class RegisterIDViewController: UIViewController {
    
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    @IBOutlet weak var progress: UIProgressView!
    
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var checkIcon: UIImageView!
    
    var viewModel : RegisterViewModel? = nil
    var disposeBag = DisposeBag()
    
    // 스크린이 로드 되기 전에 키보드 미리 올려놓기
    override func viewWillAppear(_ animated: Bool) {
        self.textField.becomeFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewDesign()
        
        textField.rx.text.orEmpty
            .map { $0 as String }
            .bind(to: self.viewModel!.userEmailRelay)
            .disposed(by: disposeBag)
        
        viewModel?.userEmailRelay
            .observeOn(MainScheduler.instance)
            .subscribe(onNext : { [weak self] newValue in
//                self?.viewModel!.nameRelay.accept(newValue)
                print("newValue : \(newValue)")
                
                self?.viewModel?.userEmail = newValue
//                print(self?.viewModel?.userName)
                
                if self?.viewModel?.isVailed == true {
                    UIView.animate(withDuration: 0.5) {
                        self?.checkIcon.alpha = 1
                        self?.progress.setProgress(0.28, animated: true)
                        AppStyleGuide.systemBtnRadius16(btn: self!.nextBtn, isActive: true)
                    }
                }else {
                    UIView.animate(withDuration: 0.5) {
                        self?.checkIcon.alpha = 0
                        self?.progress.setProgress(0.14, animated: true)
                        AppStyleGuide.systemBtnRadius16(btn: self!.nextBtn, isActive: false)
                    }
                }
        })
        .disposed(by: disposeBag)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(moveUpTextView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveDownTextView), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "InputBirthday" {
            let destinationVC = segue.destination as? RegisterBirthViewController
            destinationVC?.viewModel = self.viewModel
        }
    }
    
    // 키보드 업, 다운 관련
    @objc func moveUpTextView(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0, animations: {
                            self.nextBtn?.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height)
            })
        }
    }
    
    @objc func moveDownTextView() {
        self.nextBtn?.transform = .identity
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Navigation
    
    @IBAction func pressedNextBtn(_ sender: Any) {
        performSegue(withIdentifier: "InputBirthday", sender: sender)
    }
    
    @IBAction func pressedCloseBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension RegisterIDViewController {
    func viewDesign() {
        AppStyleGuide.systemBtnRadius16(btn: nextBtn, isActive: false)
    }
}
