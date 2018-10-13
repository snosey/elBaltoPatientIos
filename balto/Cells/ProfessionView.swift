//
//  Profession.swift
//  balto
//
//  Created by Abanoub Osama on 4/27/18.
//  Copyright © 2018 Abanoub Osama. All rights reserved.
//

import UIKit

class ProfessionView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ContentDelegate {
    
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var loadingView: LoadingView!
    
    private var vc: UIViewController!
    
    private var account: ContentSession!
    
    private var action: ((_ : MainCategory) -> Void)!
    
    private var professions = [MainCategory]()
    
    class func instantiateFromNib(vc: UIViewController, action: ((_ : MainCategory) -> Void)!) -> ProfessionView {
        
        let view = UINib(nibName: "ProfessionView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ProfessionView
        
        view.vc = vc
        view.action = action
        
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(UINib(nibName: "ProfessionCollectionCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        account = ContentSession(delegate: self)
        
        loadingView.setLoadingImage(image: UIImage(named: "loading")!)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loadingView.isHidden = true
        
        account.mainCategories()
    }
    
    // start of collectionView's dataSource, delegate and flowDelegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let count = CGFloat(professions.count > 0 ? professions.count : 1)
        
        let col = collectionViewLayout as! UICollectionViewFlowLayout
        
        return CGSize(width: collectionView.frame.size.width / count - col.minimumInteritemSpacing, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return professions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ProfessionCollectionCell
        
        let profession = professions[indexPath.row]
        
        cell.imageView.sd_setImage(with: URL(string: profession.logo), completed: nil)
        cell.labelName.text = profession.name
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        action(professions[indexPath.row])
    }
    // end of collectionView's dataSource, delegate and flowDelegate
    
    func onPreExecute(action: ContentSession.ActionType) {
        loadingView.setIsLoading(true)
    }
    
    func onPostExecute(status: BaseUrlSession.Status, action: ContentSession.ActionType, response: Any!) {
        loadingView.setIsLoading(false)
        if status.success {
            
            switch action {
            case .mainCategories:
                
                self.professions = response as! [MainCategory]
                
                collectionView.reloadData()
                break
            default:
                break
            }
        } else {
            Toast.showAlert(viewController: vc, text: status.message)
        }
    }
}
