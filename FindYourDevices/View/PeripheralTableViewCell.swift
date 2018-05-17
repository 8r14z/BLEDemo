//
//  DeviceTableViewCell.swift
//  FindYourDevices
//
//  Created by Le Vu Hoai An on 10/3/17.
//  Copyright © 2017 Le Vu Hoai An. All rights reserved.
//

import UIKit

class PeripheralTableViewCell: UITableViewCell {
    
    let DEFAULT_PADDING     = 20    as CGFloat
    let DEFAULT_WIDTH       = 100   as CGFloat
    let DEFAULT_HEIGHT      = 20    as CGFloat
    private var _deviceNameLabel: UILabel!
    private var _rssiNumberLabel: UILabel!
    private var _deviceStatusLabel: UILabel!
    private var _serialNumberLabel: UILabel!
    private var _activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        
        self._deviceNameLabel           = UILabel(frame: CGRect(x: DEFAULT_PADDING, y: 5, width: DEFAULT_WIDTH + 30, height: DEFAULT_HEIGHT))
        self._deviceNameLabel.font      = UIFont.boldSystemFont(ofSize: 17)
        
        self._rssiNumberLabel           = UILabel(frame: CGRect(x: UIScreen.main.bounds.width - DEFAULT_WIDTH - DEFAULT_PADDING, y: 10, width: DEFAULT_WIDTH, height: DEFAULT_HEIGHT))
        self._rssiNumberLabel.textAlignment = NSTextAlignment.right
        
        self._serialNumberLabel         = UILabel(frame: CGRect(x: UIScreen.main.bounds.width - DEFAULT_WIDTH - DEFAULT_PADDING, y: 30, width: DEFAULT_WIDTH, height: DEFAULT_HEIGHT))
        self._serialNumberLabel.textAlignment = NSTextAlignment.right
        self._serialNumberLabel.font    = UIFont.systemFont(ofSize: 12)
        
        self._deviceStatusLabel         = UILabel(frame: CGRect(x: DEFAULT_PADDING + 4, y: 30, width: DEFAULT_WIDTH, height: DEFAULT_HEIGHT))
        self._deviceStatusLabel.font    = UIFont.systemFont(ofSize: 12)
        
        self._activityIndicator         = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self._activityIndicator.frame   = CGRect(x: self._deviceStatusLabel.frame.origin.x + DEFAULT_WIDTH, y: 32, width: 10, height: 10)
        
        self.addSubview(self._deviceNameLabel)
        self.addSubview(self._rssiNumberLabel)
        self.addSubview(self._deviceStatusLabel)
        self.addSubview(self._activityIndicator)
        self.addSubview(self._serialNumberLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func startAnimating() {
        self._activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        self._activityIndicator.stopAnimating()
    }
    
    func configCell(withDeviceName deviceName:String?,rssi RSSI:NSInteger?,serialNumber number:String?, deviceStatus status:String?) {
        if deviceName == nil {
            self._deviceNameLabel.text = "No name"
        }
        else {
            self._deviceNameLabel.text = deviceName
        }
        
        if let tmpRSSI = RSSI {
            self._rssiNumberLabel.text = String.init(format: "%d", tmpRSSI)
        }
        else {
            self._rssiNumberLabel.text = nil
        }
        
        if number == nil {
            self._serialNumberLabel.text = nil
        }
        else {
            self._serialNumberLabel.text = number
        }
        
        self._deviceStatusLabel.text    = status
        
        if status == "Connecting" {
            self._activityIndicator.startAnimating()
        }
        else {
            self._activityIndicator.stopAnimating()
        }
    }

}
