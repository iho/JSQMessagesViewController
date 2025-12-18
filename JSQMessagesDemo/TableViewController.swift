//
//  TableViewController.swift
//  JSQMessagesDemo
//

import UIKit

class TableViewController: UITableViewController, JSQDemoViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "JSQMessagesViewController"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 2
        case 2: return 1
        case 3: return 1
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cellIdentifier = "CellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            cell?.accessoryType = .disclosureIndicator
        }

        if indexPath.section == 0 {
            switch indexPath.row {
            case 0: cell?.textLabel?.text = "Push via storyboard"
            case 1: cell?.textLabel?.text = "Push programmatically"
            default: break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0: cell?.textLabel?.text = "Modal via storyboard"
            case 1: cell?.textLabel?.text = "Modal programmatically"
            default: break
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0: cell?.textLabel?.text = "Settings"
            default: break
            }
        } else if indexPath.section == 3 {
            switch indexPath.row {
            case 0: cell?.textLabel?.text = "Push view 2 levels"
            default: break
            }
        }

        return cell!
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int)
        -> String?
    {
        switch section {
        case 0: return "Presentation"
        case 2: return "Demo options"
        case 3: return "Other testing"
        default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int)
        -> String?
    {
        return (section == 2) ? "Copyright © 2015\nJesse Squires\nMIT License" : nil
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                self.performSegue(withIdentifier: "seguePushDemoVC", sender: self)
            case 1:
                let vc =
                    DemoMessagesViewController.messagesViewController()
                    as! DemoMessagesViewController
                self.navigationController?.pushViewController(vc, animated: true)
            default: break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                self.performSegue(withIdentifier: "segueModalDemoVC", sender: self)
            case 1:
                let vc =
                    DemoMessagesViewController.messagesViewController()
                    as! DemoMessagesViewController
                vc.delegateModal = self
                let nc = UINavigationController(rootViewController: vc)
                self.present(nc, animated: true, completion: nil)
            default: break
            }
        } else if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                self.performSegue(withIdentifier: "SegueToSettings", sender: self)
            default: break
            }
        } else if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                let blank = UIViewController()
                blank.title = "Blank"
                blank.view.backgroundColor = .lightGray
                self.navigationController?.pushViewController(blank, animated: false)
                let vc = DemoMessagesViewController.messagesViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            default: break
            }
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueModalDemoVC" {
            let nc = segue.destination as! UINavigationController
            let vc = nc.topViewController as! DemoMessagesViewController
            vc.delegateModal = self
        }
    }

    @IBAction func unwindSegue(_ sender: UIStoryboardSegue) {}

    // MARK: - Demo delegate

    func didDismissJSQDemoViewController(_ vc: DemoMessagesViewController) {
        self.dismiss(animated: true, completion: nil)
    }
}
