//
//  SettingsViewController.swift
//  Spotify
//
//  Created by Akhadjon Abdukhalilov on 2/28/21.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tabelView:UITableView={
        let tabelView = UITableView(frame: .zero, style: .grouped)
        tabelView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tabelView
    }()
    private var sections = [Section]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureModels()
        title = "Settings"
        view.backgroundColor = .systemBackground
        view.addSubview(tabelView)
        tabelView.dataSource = self
        tabelView.delegate = self
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabelView.frame = view.bounds
    }
    

    private func  configureModels(){
        sections.append(Section(title: "Profile", options: [Option(title: "View your Profile", handler: {[weak self] in
            self?.viewProfile()
        })]))
        sections.append(Section(title: "Account", options: [Option(title: "Sign Out", handler: {[weak self] in
            self?.signOutTapped()
        })]))
    }
    
    private func viewProfile(){
        let vc = ProfileViewController()
        vc.title = "Profile"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func signOutTapped(){
        
    }
   
    //MARK:-UItable View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
        let cell = tabelView.dequeueReusableCell(withIdentifier: "cell", for:   indexPath)
        cell.textLabel?.text = model.title
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //call handler for cell
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let model = sections[section]
        return model.title
    }

}

