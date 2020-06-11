//
//  ChatViewController.swift
//  week11_testApp
//
//  Created by JJIKKYU on 2020/06/09.
//  Copyright © 2020 JJIKKYU. All rights reserved.
//

import UIKit
import Firebase


class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        navigationItem.title = "대화하기"
        navigationItem.hidesBackButton = true
        
        // xib파일 연결
        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        
        // 데이터 읽기
        loadMessages()
        loadLikeProgressBar()

 
        
    }
    
    func loadMessages() {
        
        // .order와 listener 주의해서 보기
        db.collection(Constants.FStore.collectionName)
            .order(by: Constants.FStore.dataField)
            .addSnapshotListener { (querySnapShot, error) in
            
            self.messages = []
            
            if let e = error {
                print("There was an issue retriebing data from Firestore. \(e)")
            } else {
                 
                if let snapshotDocuments = querySnapShot?.documents {
                    // 각각 데이터 출력
                    for doc in snapshotDocuments {
                        // print(doc.data())
                        let data = doc.data()
                        if let messageSender = data[Constants.FStore.senderField] as? String,
                           let messageBody = data[Constants.FStore.bodyField] as? String {
                           let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                
                                // 메세지 보내면 스크롤
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                                
                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    func loadLikeProgressBar() {
        
        // 흰색 바
        let likeBar = UILabel()

        likeBar.frame = CGRect(x: 0, y: 0, width: 383, height: 40)
        likeBar.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        likeBar.layer.cornerRadius = 20
        // 흰색 바 섀도우
        likeBar.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12).cgColor
        likeBar.layer.shadowOpacity = 1
        likeBar.layer.shadowOffset = CGSize(width: 0, height: 4)
        likeBar.layer.shadowRadius = 20
        likeBar.layer.masksToBounds = false
        
        
        let likeBarParent = self.view!
        likeBarParent.addSubview(likeBar)
        likeBar.translatesAutoresizingMaskIntoConstraints = false
        likeBar.widthAnchor.constraint(equalToConstant: 394).isActive = true
        likeBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        likeBar.leadingAnchor.constraint(equalTo: likeBarParent.leadingAnchor, constant: 10).isActive = true
        likeBar.topAnchor.constraint(equalTo: likeBarParent.topAnchor, constant: 100).isActive = true

        
        let view = UILabel()

        view.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        view.layer.cornerRadius = view.frame.width / 2
        view.layer.backgroundColor = UIColor(red: 0.843, green: 0.882, blue: 1, alpha: 1).cgColor


        let parent = self.view!
        parent.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 32.09).isActive = true
        view.heightAnchor.constraint(equalToConstant: 32).isActive = true
        view.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 365).isActive = true
        view.topAnchor.constraint(equalTo: parent.topAnchor, constant: 104).isActive = true
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        let writtenMessage = self.messageTextfield.text
        if writtenMessage == "" {
            return
        }
        self.messageTextfield.text = ""
        // 옵셔널 String이기 때문에
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection(Constants.FStore.collectionName).addDocument(data:
                [Constants.FStore.senderField: messageSender,
                 Constants.FStore.bodyField: writtenMessage,
                 Constants.FStore.dataField: Date().timeIntervalSince1970
            ]) { (error) in
                    if let e = error {
                        print("There was an issue saving data to firestore, \(e)")
                    } else {
                        print("Successfully saved data.")
                    }
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
            
            
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }

}

// 데이터 소스를 담당하는 프로토콜
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath)
            as! MessageCell
        cell.label.text = message.body
        
        // This is a message from the current user.
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightBox.isHidden = true
            cell.leftBox.isHidden = false
            // cell.rightImageView.isHidden = false
            // UIColor(named: Constants.BrandColors.lightPurple)
            cell.messageBubble.layer.borderWidth = 0
            cell.messageBubble.backgroundColor = UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0)
            
            cell.label.textColor = UIColor(red: 0.49, green: 0.49, blue: 0.49, alpha: 1.0)
            cell.label.textAlignment = .right
            // cell.messageBubble.widthAnchor.constant = cell.label.intrinsicContentSize.width
            
            // cell.messageBubble.frame = CGRect(x: 0, y: 0, width: cell.label.intrinsicContentSize.width-100, height: cell.messageBubble.frame.height)
            
            
            
        }
        // This is a message from another sender.
        else {
            cell.leftImageView.isHidden = false
            cell.rightBox.isHidden = false
            cell.leftBox.isHidden = true
            // cell.rightImageView.isHidden = true
            cell.messageBubble.layer.borderWidth = 1.0
            cell.messageBubble.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.messageBubble.layer.borderColor = UIColor(red: 0.45, green: 0.48, blue: 0.9, alpha: 1.0).cgColor
            cell.label.textColor = UIColor(red: 0.45, green: 0.48, blue: 0.9, alpha: 1.0)
            cell.label.textAlignment = .left
            
        }
        return cell
    }
}
