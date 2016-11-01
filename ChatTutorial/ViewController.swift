//
//  ViewController.swift
//  ChatTutorial
//
//  Created by Пользователь on 21.10.16.
//  Copyright © 2016 Bookscriptor. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ViewController: UIViewController {
    
    var ref: FIRDatabaseReference!
    var contactsRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference(fromURL: "https://chats-28469.firebaseio.com")
        contactsRef = ref.child("contacts")
    }
    
    @IBAction func loginDidTouch(sender: UIButton){

//        FIRAuth.auth()?.createUser(withEmail: "agentumios@gmail.com", password: "marina89", completion: { (user, error) in
//            
//            if error == nil{
//                self.addContact(uid: user?.providerData.first?.uid ?? "")
//                self.login()
//            } else {
//                print(error.debugDescription)
//            }
//        })
//        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
//            guard error == nil else { print (error!.localizedDescription); return }
//            self.performSegue(withIdentifier: "loginSegue", sender: user?.providerData)
//        })
        
        login()
    }
    
    func login(){
        FIRAuth.auth()?.signIn(withEmail: "agentumios@gmail.com", password: "marina89", completion: { (user, error) in
            if error == nil{
                self.performSegue(withIdentifier: "loginSegue", sender: user?.providerData)
            } else {
                print(error.debugDescription)
            }
        })

    }
    
    func addContact(uid: String){
        let itemRef = contactsRef.childByAutoId()
        let contactItem = ["name": NSString(string: "Marina"), "uid" : NSString(string:uid)]
        itemRef.setValue(contactItem)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginSegue"{
//            let chatVC = segue.destination as! ChatViewController
//            chatVC.senderId = FIRAuth.auth()?.currentUser?.uid
//            chatVC.senderDisplayName = ""
        }
    }
}

