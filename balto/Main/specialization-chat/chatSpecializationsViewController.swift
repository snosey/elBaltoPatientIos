//
//  chatSpecializationsViewController.swift
//  ElBalto
//
//  Created by rocky on 4/10/19.
//  Copyright © 2019 Abanoub Osama. All rights reserved.
//

import UIKit
import SwiftyJSON

class chatSpecializationsViewController: UIViewController {

    @IBOutlet weak var classTableView: UITableView!
    var content: ContentSession!
    var loadingView: LoadingView!
    var categories = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView = LoadingView(frame: view.frame)
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        self.view.addSubview(loadingView)
        
        classTableView.register(identifiers: [specializationTableViewCell.identifier, separatorTableViewCell.identifier])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadingView.setIsLoading(true)
        DoctorsAPIS.getSpecializations { (data, error) in
            if error == nil {
                if let subCategory = data?["subCategory"].array {
                    self.categories = subCategory
                    print("countis: \(subCategory.count)")
                    self.classTableView.reloadData()
                }
            }
            self.loadingView.setIsLoading(false)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @IBAction override func back(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}

extension chatSpecializationsViewController: UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count * 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: specializationTableViewCell.identifier, for: indexPath) as! specializationTableViewCell
            
            let num = indexPath.row / 2
            let category = categories[num]
            let name = category["name"].string ?? ""
            let logo = category["logo"].string
            // let id = category["id"].string
            cell.setup(name: name, logo: logo)
            
            return cell
        }else {
            return tableView.dequeueReusableCell(withIdentifier: separatorTableViewCell.identifier, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 0 {
            return 80
        }else {
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toQuestionSegue", sender: self)
    }
    
}
