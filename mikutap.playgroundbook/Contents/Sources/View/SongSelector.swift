//
//  SongSelector.swift
//  mikutap
//
//  Created by Liuliet.Lee on 24/3/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import UIKit
import MediaPlayer

class SongSelector: UIView, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView: UITableView!
    private var list: [MPMediaItem]!
    
    private func commonInit() {
        tableView = UITableView()
        addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 8.0),
            tableView.topAnchor.constraint(equalTo: topAnchor, constant: 64.0),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 16.0)
        ])
        
        tableView.register(UITableViewCell.self as AnyClass, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        let titleLabel = UILabel()
        titleLabel.text = "Choose a song"
        titleLabel.font = UIFont.systemFont(ofSize: 28.0)
        addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16.0)
        ])
        
        backgroundColor = .white
        let query = Audio.shared.query
        list = query.items ?? []
        layer.masksToBounds = true
        layer.cornerRadius = 10.0
    }
    
    init() {
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = list[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Audio.shared.mediaPlayItem = list[indexPath.row]
        Audio.shared.playBackgroundMusic()
        removeFromSuperview()
    }
}
