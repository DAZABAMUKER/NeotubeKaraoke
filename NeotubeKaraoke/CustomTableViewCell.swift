//
//  CustomTableViewCell.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/01/03.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    static let cellId = "CellId"
    //let img = UIImageView()
    let title = UILabel()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has been implemented")
    }
    
    func layout() {
        //self.addSubview(img)
        self.addSubview(title)
        /*
        img.translatesAutoresizingMaskIntoConstraints = false
        img.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        img.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        img.widthAnchor.constraint(equalToConstant: 120).isActive = true
        img.heightAnchor.constraint(equalToConstant: 60).isActive = true
        */
        title.translatesAutoresizingMaskIntoConstraints = false
        title.leadingAnchor.constraint(equalTo: self.trailingAnchor, constant: 10).isActive = true
        title.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
}
