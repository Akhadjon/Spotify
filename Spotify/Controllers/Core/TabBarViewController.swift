//
//  TabBarViewController.swift
//  Spotify
//
//  Created by Akhadjon Abdukhalilov on 2/28/21.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let v1 = HomeViewController()
        let v2 = SearchViewController()
        let v3 = LibraryViewController()
        
        v1.title = "Browse"
        v2.title = "Search"
        v3.title = "Library"
        
        v1.navigationItem.largeTitleDisplayMode = .always
        v2.navigationItem.largeTitleDisplayMode = .always
        v3.navigationItem.largeTitleDisplayMode = .always
        
        let nav1 = UINavigationController(rootViewController: v1);
        let nav2 = UINavigationController(rootViewController: v2);
        let nav3 = UINavigationController(rootViewController: v3);
        
        nav1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "music.note.list"), tag: 3)
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        
        setViewControllers([nav1, nav2,nav3], animated: false)
        
    }
    

  

}
