//
//  GroupedContactHeaderView.swift
//  SmartCleaner
//
//  Created by Luchik on 09.06.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//

import UIKit

class GroupedContactHeaderView: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        let myCustomView = UINib(nibName: "GroupedContactHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        myCustomView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.addSubview(myCustomView)
        self.get(all: UIStackView.self).forEach({
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onClicked)))
            $0.isUserInteractionEnabled = true
        })
    }
    
    @objc private func onClicked(){
        onSelectAll!()
    }
    
    public var onSelectAll: (() -> Void)?
    
    public func setName(_ name: String){
        self.get(all: UILabel.self).filter({ $0.tag == 404 }).forEach({
            $0.text = name
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
