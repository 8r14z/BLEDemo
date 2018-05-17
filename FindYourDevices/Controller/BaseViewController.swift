//
//  BaseViewController.swift
//  FindYourDevices
//
//  Created by Le Vu Hoai An on 10/4/17.
//  Copyright © 2017 Le Vu Hoai An. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    let DEFAULT_CELL_IDENTIFIER = "BaseCellID"
    
    var _tableView: UITableView!
    var _activityIndicator: UIActivityIndicatorView!
    var _data: Array<Any>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupUI()
    }
    
    func setupUI() -> Void {
        // Set up tableview
        self._tableView             = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        self._tableView.delegate    = self
        self._tableView.dataSource  = self
        self._tableView .register(UITableViewCell.self, forCellReuseIdentifier: DEFAULT_CELL_IDENTIFIER)
        self.view .addSubview(self._tableView)
        
        // Set up loading indicator
        self._activityIndicator         = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self._activityIndicator.frame   = CGRect(x: 10, y: 10, width: 30, height: 30)
        self._activityIndicator.center  = self.view.center
        self.view .addSubview(self._activityIndicator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension BaseViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = self._data {
            return data.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: DEFAULT_CELL_IDENTIFIER)!

        return cell
    }
}

extension BaseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
