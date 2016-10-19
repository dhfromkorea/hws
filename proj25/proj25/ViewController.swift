//
//  ViewController.swift
//  proj25
//
//  Created by dh on 10/19/16.
//  Copyright © 2016 dh. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate {
    var images = [UIImage]()
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssitant: MCAdvertiserAssistant!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        configureMPC()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - MPC related
    func configureMPC() {
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let image = UIImage(data: data) {
            addImage(image: image)
        }
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    
    func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func startHosting(action: UIAlertAction) {
        mcAdvertiserAssitant = MCAdvertiserAssistant(serviceType: "hws-proj25", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssitant.start()
    }
    
    func joinSession(action: UIAlertAction) {
        let mcBrowser = MCBrowserViewController(serviceType: "hws-proj25", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    func sendImageToPeers(image: UIImage) {
        guard mcSession.connectedPeers.count > 0 else { return }
        guard let data = UIImagePNGRepresentation(image) else { return }
        
        do {
            try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
        } catch {
            let ac = UIAlertController(title: "Error occured while sending", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present(ac, animated: true)
        }
        
    }
    // MARK: - collection view related
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageView", for: indexPath)
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]
        }
        return cell
    }
    
    func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        dismiss(animated: true)
        addImage(image: image)
        sendImageToPeers(image: image)
    }
    
    func addImage(image: UIImage) {
        DispatchQueue.main.async { [unowned self] in
            self.images.insert(image, at: 0)
            self.collectionView?.reloadData()
        }
    }
    
    // MARK: - decorate view
    func configureView() {
        title = "selfie sharing"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))
    }
}

