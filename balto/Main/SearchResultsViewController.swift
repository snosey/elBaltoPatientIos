//
//  SearchResultsViewController.swift
//  balto
//
//  Created by Mena Gamal on 4/3/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PickerDelegate {
    
    enum SortBy: String {
        case NameAsc, NameDes, RatingDes
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var doctors = [Doctor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SearchResultTableViewCell", bundle: nil), forCellReuseIdentifier: "search")
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = LocalizationSystem.sharedInstance.localizedStringForKey(key: "searchResult", comment: "")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    @IBAction func filter(_ sender: UIButton) {
        
        let vc = DoctorFilterViewController.getInstance(searchResultsViewController: self)
//        self.present(vc, animated: true, completion: nil)
        self.show(vc, sender: self)
    }
    
    @IBAction func sort(_ sender: UIButton) {
        
        let keys = [SortBy.NameAsc.rawValue, SortBy.NameDes.rawValue, SortBy.RatingDes.rawValue]
        var names = [String]()
        for item in keys {
            names.append(LocalizationSystem.sharedInstance.localizedStringForKey(key: item, comment: ""))
        }
        
        let _ = PickerViewController.present(self, delegate: self, items: names)
    }
    
    func done(picker: PickerViewController) -> Bool {
        
         let values = [SortBy.NameAsc, SortBy.NameDes, SortBy.RatingDes]
        
        let sortBy = values[picker.pickerView.selectedRow(inComponent: 0)]
         
        switch sortBy {
        case .NameAsc:
            doctors.sort(by: { (dr1, dr2) -> Bool in
                
                return dr1.name.compare(dr2.name) == ComparisonResult.orderedAscending
            })
            break
        case .NameDes:
            doctors.sort(by: { (dr1, dr2) -> Bool in
                
                return dr1.name.compare(dr2.name) == ComparisonResult.orderedDescending
            })
            break
        case .RatingDes:
            doctors.sort(by: { (dr1, dr2) -> Bool in
                
                return dr1.rate ?? -1 > dr2.rate ?? -1
            })
            break
        }
        
        tableView.reloadData()
        
        return false
    }
    
    func cancel(picker: PickerViewController) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doctors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "search", for: indexPath) as! SearchResultTableViewCell
        
        let doctor = doctors[indexPath.row]
        
        cell.setDetails(vc: self, doctor: doctor)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let height = 117
        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.doctorId = doctors[indexPath.row].id
        self.show(vc, sender: nil)
    }
}
