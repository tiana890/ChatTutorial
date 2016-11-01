//
//  ChatViewController.swift
//  ChatTutorial
//
//  Created by Пользователь on 25.10.16.
//  Copyright © 2016 Bookscriptor. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseDatabase

class ChatViewController: JSQMessagesViewController{
    // MARK: Properties
    var messages = [JSQMessage]()

    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    let rootRef = FIRDatabase.database().reference(fromURL: "https://chats-28469.firebaseio.com")
    var chatsRef: FIRDatabaseReference!
    var chatRef: FIRDatabaseReference!
    var messageRef: FIRDatabaseReference!
    var metaRef: FIRDatabaseReference!
    
    var userUID: String?
    var name: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = name ?? ""
        setupBubbles()
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        chatsRef = rootRef.child("chats")
        addChat()
    }
    
    func addChat(){
        chatRef = chatsRef.childByAutoId()
        messageRef = chatRef.child("/messages")
        metaRef = chatRef.child("/meta")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        observeMessages()
    }
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        
        outgoingBubbleImageView = factory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        incomingBubbleImageView = factory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages[indexPath.item]
        
        if message.senderId == senderId{
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    func addMessage(id: NSString, text: NSString) {
        
        let message = JSQMessage(senderId: id as String, displayName: "", text: text as String)
        messages.append(message!)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = self.messages[indexPath.item]
        
        if let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as? JSQMessagesCollectionViewCell{
        
            if message.senderId == senderId{
                cell.textView.textColor = UIColor.white
            } else {
                cell.textView.textColor = UIColor.black
            }
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = messageRef.childByAutoId()
        let messageItem = ["message": NSString(string:text), "sender" : NSString(string:senderId)]
        itemRef.setValue(messageItem)
        finishSendingMessage()
    }
    
    private func observeMessages(){
        let messagesQuery = messageRef.queryLimited(toLast: 25)
        
        messagesQuery.observe(.childAdded, with: { (snapshot) in
            var value = snapshot.value as! [NSString : NSString]
            let id = value["sender"]!
            let text = value["message"]!
            self.addMessage(id: id, text: text)
            self.finishReceivingMessage()
        })
        
    }
}
