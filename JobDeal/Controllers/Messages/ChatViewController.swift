//
//  ChatViewController.swift
//  JobDeal
//
//  Created by Macbook Pro on 1/23/19.
//  Copyright © 2019 Priba. All rights reserved.
//

import UIKit

class ChatViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    
    @IBOutlet weak var chatTableView: UITableView!
    
    var inboxArray = [MessageModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

      setupNavigationBar(title:LanguageManager.sharedInstance.getStringForKey(key: "notifications", uppercased: true), withGradient: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.inboxArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row % 2 == 0 ){
            
            let tmp = inboxArray[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatUserTableViewCell", for: indexPath) as! ChatTableViewCell
            
            cell.populateUserWith(inboxMessage:tmp)
            return cell
        }
        else {
                
                let tmp = inboxArray[indexPath.row]
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatWriterTableViewCell", for: indexPath) as! ChatTableViewCell
                
                cell.populateUserWith(inboxMessage: tmp)
                
                return cell
        }
        
    }
    
    
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func setupUI(){
        
        chatTableView.backgroundColor = UIColor.clear
        chatTableView.separatorColor  = UIColor.clear
        chatTableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        chatTableView.allowsSelection = false
        chatTableView.backgroundColor = UIColor.baseBackgroundColor
        chatTableView.rowHeight = UITableView.automaticDimension
        chatTableView.estimatedRowHeight = 200
        
    }
    
    override func setupStrings(){
        
    }
    
    override func loadData() {
        
        let messages: [[String:Any]] = [
            
            [
                "message" : "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English.",
                "data": "21.Oct",
                "city": "Beograd",
                "name": "Darko Batur"
                
            ],
            [
                "message" : "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                "data": "21.Oct",
                "city": "Beograd",
                "name": "Darko Batur"
            ],
            [
                "message" : "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
                "data": "21.Oct",
                "city": "Beograd",
                "name": "Darko Batur"
            ],
            [
                "message" : "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English.",
                "data": "21.Oct",
                "city": "Beograd",
                "name": "Darko Batur"
            ],
            [
                "message" : "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
                "data": "21.Oct",
                "city": "Beograd",
                "name": "Darko Batur"
            ],
            [
                "message" : "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English.",
                "data": "21.Oct",
                "city": "Beograd",
                "name": "Darko Batur"
            ],
            [
                "message" : "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English.",
                "data": "21.Oct",
                "city": "Beograd",
                "name": "Darko Batur"
            ]
            
        ]
        for dict in messages {
            // Condition required to check for type safety :)
            let object = MessageModel(dict: dict as NSDictionary)
            inboxArray.append(object)
        }
        
    }

}

