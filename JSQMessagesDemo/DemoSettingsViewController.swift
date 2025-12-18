//
//  DemoSettingsViewController.swift
//  JSQMessagesDemo
//

import UIKit

class DemoSettingsViewController: UITableViewController {

    @IBOutlet weak var extraMessagesSwitch: UISwitch!
    @IBOutlet weak var longMessageSwitch: UISwitch!
    @IBOutlet weak var emptySwitch: UISwitch!
    @IBOutlet weak var incomingAvatarsSwitch: UISwitch!
    @IBOutlet weak var outgoingAvatarsSwitch: UISwitch!
    @IBOutlet weak var springySwitch: UISwitch!
    @IBOutlet weak var accessoryButtonSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.extraMessagesSwitch.isOn = UserDefaults.extraMessagesSetting()
        self.longMessageSwitch.isOn = UserDefaults.longMessageSetting()
        self.emptySwitch.isOn = UserDefaults.emptyMessagesSetting()
        self.accessoryButtonSwitch.isOn = UserDefaults.accessoryButtonForMediaMessages()

        self.incomingAvatarsSwitch.isOn = UserDefaults.incomingAvatarSetting()
        self.outgoingAvatarsSwitch.isOn = UserDefaults.outgoingAvatarSetting()

        self.springySwitch.isOn = UserDefaults.springinessSetting()
    }

    @IBAction func didTapSwitch(_ sender: UISwitch) {
        if sender == self.extraMessagesSwitch {
            UserDefaults.saveExtraMessagesSetting(sender.isOn)
        } else if sender == self.longMessageSwitch {
            UserDefaults.saveLongMessageSetting(sender.isOn)
        } else if sender == self.emptySwitch {
            UserDefaults.saveEmptyMessagesSetting(sender.isOn)
        } else if sender == self.accessoryButtonSwitch {
            UserDefaults.saveAccessoryButtonForMediaMessages(sender.isOn)
        } else if sender == self.incomingAvatarsSwitch {
            UserDefaults.saveIncomingAvatarSetting(sender.isOn)
        } else if sender == self.outgoingAvatarsSwitch {
            UserDefaults.saveOutgoingAvatarSetting(sender.isOn)
        } else if sender == self.springySwitch {
            UserDefaults.saveSpringinessSetting(sender.isOn)
        }

        UserDefaults.standard.synchronize()
    }
}
