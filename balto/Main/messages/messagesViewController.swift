//
//  messagesViewController.swift
//  ElBalto
//
//  Created by rocky on 2/25/19.
//  Copyright © 2019 Abanoub Osama. All rights reserved.
//

import UIKit
import SwiftyJSON

fileprivate let nib_identifier = "messagesTableViewCell"
fileprivate let separator_identifier = "separatorTableViewCell"

class messagesViewController: UIViewController {

    @IBOutlet weak var classTableView: UITableView!
    var chats = [JSON]()
    var id_chat: Int = 0
    var loadingView: LoadingView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        classTableView.register(UINib(nibName: nib_identifier, bundle: nil), forCellReuseIdentifier: nib_identifier)
        classTableView.register(UINib(nibName: separator_identifier, bundle: nil), forCellReuseIdentifier: separator_identifier)
        
        loadingView = LoadingView(frame: view.frame)
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        self.view.addSubview(loadingView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadingView.setIsLoading(true)
        let params = [
            "id_patient": SettingsManager().getUserId(),
            "type": "patient"
        ] as [String: Any]
        DoctorsAPIS.getMessages(params: params) { (json, error) in
            let data = JSON(json)
            
            if let chats = data["chats"].array {
                self.chats = chats
                self.classTableView.reloadData()
            }
            self.loadingView.setIsLoading(false)
        }
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChatViewControllerSegue" {
            if let dest = segue.destination as? chatViewController {
                dest.id_chat = self.id_chat
            }
        }
    }
}

extension messagesViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ( chats.count * 2 )
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: nib_identifier, for: indexPath) as! messagesTableViewCell
            
            let num = indexPath.row / 2
            let chat = chats[num]
            
            if let image = chat["doctor"]["image"].string {
                cell.imageProfile.findMe(url: image)
            }
            
            let lang = LocalizationSystem.sharedInstance.getLanguage()
            let first_name = ( chat["doctor"]["first_name_\(lang)"].string ?? "" )
            let last_name = ( chat["doctor"]["last_name_\(lang)"].string ?? "" )
            let title = first_name + " " + last_name
            let date = chat["created_at"].string ?? ""
            let prof = chat["category"]["name_\(lang)"].string ?? ""
            let rate = chat[""].double ?? 5.0
            
            cell.configCell(title: title, profession: prof, date: date, rate: rate)
            
            cell.profession.font = UIFont.systemFont(ofSize: 10)
            
            
            return cell
        }else {
            return tableView.dequeueReusableCell(withIdentifier: separator_identifier, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 0 {
            return 100
        } else {
          return 10
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            
            let num = ( indexPath.row / 2 )
            let chat = self.chats[num]
            self.id_chat = chat["id"].int ?? 2 
            self.performSegue(withIdentifier: "toChatViewControllerSegue", sender: self)
        }
    }
    
}
