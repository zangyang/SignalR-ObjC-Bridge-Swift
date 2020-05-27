//
//  SignalRSwift.swift
//  SignalR-ObjC-Bridge-Swift
//
//  Created by yangz on 2020/5/27.
//  Copyright © 2020 CoderZY. All rights reserved.
//

import UIKit
import SwiftSignalRClient

//返回值是一个函数指针，入参为String 返回值也是String
typealias funcBlock = (String) -> ()
@objc class SignalRSwift: NSObject {
    
    private let dispatchQueue = DispatchQueue(label: "hubsamplephone.queue.dispatcheueuq")
    
    private var chatHubConnection: HubConnection?
    private var chatHubConnectionDelegate: HubConnectionDelegate?
    private var name = ""
    private var messages: [String] = []
    
    @objc public func signalROpen(url:String,headers: [String: String]?,hubName:String,blockfunc:funcBlock!){
        name=hubName
        self.chatHubConnectionDelegate = ChatHubConnectionDelegate(signalrswift: self)
        self.chatHubConnection = HubConnectionBuilder(url: URL(string: url)!)
            .withLogging(minLogLevel: .debug)
            .withHubConnectionDelegate(delegate: self.chatHubConnectionDelegate!)
            .withHttpConnectionOptions(configureHttpOptions: { (httpConnectionOptions) in
                if let header = headers {
                    for (key, value) in header {
                        httpConnectionOptions.headers[key] = value
                    }
                }
            })
            .build()
        
        self.chatHubConnection!.on(method: "Message", callback: {(message: String) in
            //            self.appendMessage(message: "\(message)")
             blockfunc(message)
        })
        self.chatHubConnection!.start()
    }
    @objc public func signalRClose(){
        chatHubConnection?.stop()
    }
    @objc public func sendMessage(message:String) {
        if message != "" {
            chatHubConnection?.invoke(method:"SendMessage", name,message) { error in
//                if let e = error {
//                    self.appendMessage(message: "Error: \(e)")
//                }
            }
        }
    }
    
    fileprivate func connectionDidOpen() {
        chatHubConnection?.invoke(method:"Join", name) { error in
//            if let e = error {
//                self.appendMessage(message: "Error: \(e)";
//            }
        }
    }
    
    fileprivate func connectionDidFailToOpen(error: Error) {
        blockUI(message: "Connection failed to start.", error: error)
    }
    
    fileprivate func connectionDidClose(error: Error?) {
        
        blockUI(message: "Connection is closed.", error: error)
    }
    
    fileprivate func connectionWillReconnect(error: Error?) {
        
    }
    
    fileprivate func connectionDidReconnect() {
    }
    
    func blockUI(message: String, error: Error?) {
        var message = message
        if let e = error {
            message.append(" Error: \(e)")
        }
        //        appendMessage(message: message)
        //        toggleUI(isEnabled: false)
    }
}

class ChatHubConnectionDelegate: HubConnectionDelegate {
    
    weak var signalrswift: SignalRSwift?
    
    init(signalrswift: SignalRSwift) {
        self.signalrswift = signalrswift
    }
    
    func connectionDidOpen(hubConnection: HubConnection) {
        signalrswift?.connectionDidOpen()
    }
    
    func connectionDidFailToOpen(error: Error) {
        signalrswift?.connectionDidFailToOpen(error: error)
    }
    
    func connectionDidClose(error: Error?) {
        signalrswift?.connectionDidClose(error: error)
    }
    
    func connectionWillReconnect(error: Error) {
        signalrswift?.connectionWillReconnect(error: error)
    }
    
    func connectionDidReconnect() {
        signalrswift?.connectionDidReconnect()
    }
}
