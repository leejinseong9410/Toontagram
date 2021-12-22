//
//  RootTabBarController.swift
//  Toontagram
//
//  Created by MacBookPro on 2021/12/13.
//

import UIKit
import Firebase
import YPImagePicker

class RootTabBarController: UITabBarController {
    //MARK: - Properties
    var user : User? {
       didSet {
           guard let user = user else { return }
           configureVC(with: user)
       }
   }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLogin()
        fetchUserData()
    }
    //MARK: - UserLoginCheck!
    func checkLogin(){
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async { //DispatchQueue 안하면 버벅거린다!
                let loginVC = LogInViewController()
                loginVC.delegate = self // 로그아웃후 로그인후 데이터의 잔존 체크
                let navi = UINavigationController(rootViewController: loginVC)
                navi.modalPresentationStyle = .fullScreen
                self.present(navi, animated: true, completion: nil)
            }
        }
    }
    //MARK: - API Firebase User Data Fetch
    func fetchUserData(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.fetchUser(with: uid) { user in
            self.user = user
        }
    }
    //MARK: - Configure
    private func configureVC(with user : User){
        view.backgroundColor = .white
        self.delegate = self
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key.description)
        }
        let home = navigationControllerSetup(unselected: UIImage(systemName:"house")!, selected: UIImage(systemName:"house.fill")!, rootVC: HomeCollectionViewController())
        let search = navigationControllerSetup(unselected:UIImage(systemName:"list.dash")!,selected:UIImage(systemName:"text.redaction")!,rootVC: SearchViewController())
        let center = navigationControllerSetup(unselected:UIImage(systemName:"wand.and.rays.inverse")!,selected:UIImage(systemName:"wand.and.stars")!,rootVC: CenterViewController())
        let feed = navigationControllerSetup(unselected:UIImage(systemName:"heart.circle")!,selected:UIImage(systemName:"heart.circle.fill")!,rootVC: FeedBackTableViewController())
        let profile = navigationControllerSetup(unselected:UIImage(systemName:"person.crop.rectangle")!,selected:UIImage(systemName:"person.crop.rectangle.fill")!,rootVC: ProfileCollectionViewController(user: user))
        
        viewControllers = [home,search,center,feed,profile]
        tabBar.tintColor = .label
        tabBar.backgroundColor = .secondarySystemBackground
    }
    //MARK: - navigationControllerSetup
    func navigationControllerSetup(unselected:UIImage,selected:UIImage,rootVC:UIViewController) -> UINavigationController {
        let navi = UINavigationController(rootViewController: rootVC)
        navi.tabBarItem.selectedImage = selected
        navi.tabBarItem.image = unselected
        navi.navigationBar.tintColor = .label
        return navi
    }
    
    //MARK: - @objc Action
    
    
    
}
//MARK: - Extension
extension RootTabBarController : AuthDelegate {
    func authComplete() {
        fetchUserData()
        self.dismiss(animated: true, completion: nil)
    }
}
extension RootTabBarController : UITabBarControllerDelegate{
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 2 {
            let vc = SetUpViewController(user: user!)
            vc.delegate = self
            let navi = UINavigationController(rootViewController: vc)
            navi.modalPresentationStyle = .fullScreen
            self.present(navi, animated: true, completion: nil)
        }
        return true
    }
}
extension RootTabBarController : SetUpViewControllerDelegate {
    /*
     업로드후 실행하게될 method
     뷰를 다시 mainVC로 가져오기위한 method
     업로드가 끝난후 MainVC의 collectionView를 Refresh 해줘야 되지만 MainVC 안에서 RefreshController가 작동 X
     (좋아요,댓글등의 count는 refresh되지만 새로 업로드 되는 Cartoon은 refresh X)
     그래서 TabbarController로 넘어와 dismiss 될때 인스턴스를 받고
     MainVC의 Refresh @objc 메소드를 실행을 한번 시켜주는것으로 마무리
     */
    func vcDidFinish(_ vc: SetUpViewController) {
        for key in UserDefaults.standard.dictionaryRepresentation().keys { UserDefaults.standard.removeObject(forKey: key.description)}
        selectedIndex = 0
        vc.dismiss(animated: true, completion: nil)
        guard let vc = viewControllers?.first as? UINavigationController else { return }
        guard let home = vc.viewControllers.first as? HomeCollectionViewController else { return }
        home.userSelect = "ALL"
        home.wantRefresh()
    }
}

