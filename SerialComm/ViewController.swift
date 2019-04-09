//
//  ViewController.swift
//  SerialComm
//
//  Created by Michel Henrique Hoekstra on 07/04/19.
//  Copyright © 2019 Michel Henrique Hoekstra. All rights reserved.
//

import Cocoa
import ORSSerial

class ViewController: NSViewController, ORSSerialPortDelegate {
    

    var speed: Int32 = 50
    var serialPortManager =  ORSSerialPortManager.shared()
    var connected = false
    var calibrated = false
    
    @objc dynamic var serialPort: ORSSerialPort? {
        didSet {
            oldValue?.close()
            oldValue?.delegate = nil
            serialPort?.delegate = self
        }
    }
    
    @IBOutlet weak var distanceField: NSTextField!
    
    @IBOutlet weak var portSelector: NSPopUpButton!
    @IBOutlet weak var portSelectorButton: NSButton!
    @IBOutlet weak var portSelectorField: NSTextField!
    
    @IBOutlet weak var speedSlider: NSSlider!
    
    @IBAction func speedSliderAction(_ sender: NSSliderCell) {
        speed = sender.intValue
        if(serialPort!.isOpen){
            serialPort?.send(("v"+String(speed)).data(using: .utf8)!)
        }
        print("Speed set to: " + String(speed) )
    }
    override func viewWillDisappear() {
        NotificationCenter.default.removeObserver(self)

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        serialPortManager = ORSSerialPortManager.shared()
        for availablePort in serialPortManager.availablePorts {
            portSelector.addItem(withTitle: availablePort.name);
        }
        distanceSelector.addItem(withTitle: "steps")
        serialPort = serialPortManager.availablePorts[0];

    }
    @IBAction func refreshPortSelector(_ sender: Any) {
        portSelector.removeAllItems()
        for availablePort in serialPortManager.availablePorts {
            portSelector.addItem(withTitle: availablePort.name)
        }
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    @IBAction func portSelectorButtonClick(_ sender: Any) {
        if(!connected){
        let portNumber  = portSelector.indexOfSelectedItem
        print("Trying to connect to port number: " + String(portNumber))
        serialPort = serialPortManager.availablePorts[portNumber]
        serialPort!.baudRate = 9600
        serialPort!.open()
        if (serialPort!.isOpen) {
            portSelectorField.stringValue = "Connected"
            portSelectorField.textColor = NSColor.blue
            portSelectorButton.title = "Disconnect"
            portSelector.isEnabled = false
            connected = true
        }
        else{
            portSelectorField.stringValue = "Error connecting"
        }
        }
        else{
            let portNumber  = portSelector.indexOfSelectedItem
            print("Trying to disconnect from port number: " + String(portNumber))
            serialPort!.cancelAllQueuedRequests()
            if(serialPort!.isOpen){
                print("Disconnected")
                connected = false
                portSelector.isEnabled = true
                portSelectorButton.title = "Connect"
                portSelectorField.stringValue = "Disconnected"
                portSelectorField.textColor = NSColor.red
                serialPort!.close()
            }
            else{
                print("Error trying to disconnect")
            }
        }
    }
    
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        portSelector.removeItem(withTitle: serialPort.name);
        print("Port " + serialPort.name + " was removed")
        if (serialPort.isOpen) {
            serialPort.close()
            connected = false
            portSelector.isEnabled = true
            portSelectorButton.title = "Connect"
            portSelectorField.stringValue = "Disconnected"
            portSelectorField.textColor = NSColor.red
        }
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            print(string);
        }
    }
    @IBOutlet weak var distanceSelector: NSPopUpButton!
    
    @IBAction func moveRightButtonClick(_ sender: Any) {
        let distance = distanceField.stringValue
        if(serialPort!.isOpen){
            if(distanceSelector.titleOfSelectedItem == "steps") {
                serialPort!.send(("x"+distance).data(using: .utf8)!)
                
            }
        }
    }
    
    @IBAction func moveLeftButtonClick(_ sender: Any) {
        let distance = distanceField.stringValue
        if(serialPort!.isOpen){
            if(distanceSelector.titleOfSelectedItem == "steps"){serialPort!.send(("x-"+distance).data(using: .utf8)!)}
        }
    }
}

