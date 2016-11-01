//
//  ContactsViewController.swift
//  ChatTutorial
//
//  Created by Пользователь on 31.10.16.
//  Copyright © 2016 Bookscriptor. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let rootRef = FIRDatabase.database().reference(fromURL: "https://chats-28469.firebaseio.com")
    var contactsRef :FIRDatabaseReference!
    
    var contacts = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactsRef = rootRef.child("contacts")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        observeContacts()
    }
    
    private func observeContacts(){
        
        let messagesQuery = contactsRef.queryOrderedByKey()
        
        messagesQuery.observe(.value, with: { (snapshot) in
            
            let value = snapshot.value as! [NSString : [NSString : NSString]]
            
            self.contacts.removeAll()
            
            for (key, val) in value{
                let contact = Contact(_name: val["name"] as! String, _uid: val["uid"] as! String)
                self.contacts.append(contact)
                
                self.tableView.reloadData()
            }
        })
        
    }

    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            cell.textLabel?.text = contacts[indexPath.row].name
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }

    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = self.contacts[indexPath.row]
        self.performSegue(withIdentifier: "chatSegue", sender: contact)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatSegue" {
            if let destVC = segue.destination as? ChatViewController, let contact = sender as? Contact{
                destVC.userUID = contact.uid
                destVC.senderId = FIRAuth.auth()?.currentUser?.uid
                destVC.senderDisplayName = ""
            }
        }
    }
    
}
