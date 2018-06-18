//
//  ViewController.swift
//  MyIP
//
//  Created by Joe Vargas on 6/17/18.
//  Copyright © 2018 Joe Vargas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var ipAddressLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMyIP(completion: updateIp);
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func updateIp(result: Result<IpResponse>) -> Void {
        switch result {
        case .success(let resp):
            ipAddressLabel!.text = resp.origin;
        case .failure:
            return ();
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


enum Result<Value> {
    case success(Value)
    case failure(Error)
}

struct IpResponse: Codable {
    let origin: String
}

func getMyIP(completion: ((Result<IpResponse>) -> Void)?) {
    var request = URLRequest(url: URL(string: "https://httpbin.org/ip")!)
    request.httpMethod = "GET"
    
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    let task = session.dataTask(with: request) { (responseData, response, responseError) in
        DispatchQueue.main.async {
            if let error = responseError {
                completion?(.failure(error))
            } else if let jsonData = responseData {
                // Now we have jsonData, Data representation of the JSON returned to us
                // from our URLRequest...
                
                // Create an instance of JSONDecoder to decode the JSON data to our
                // Codable struct
                let decoder = JSONDecoder()
                
                do {
                    // We would use Post.self for JSON representing a single Post
                    // object, and [Post].self for JSON representing an array of
                    // Post objects
                    let ipResp = try decoder.decode(IpResponse.self, from: jsonData)
                    completion?(.success(ipResp))
                } catch {
                    completion?(.failure(error))
                }
            } else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"]) as Error
                completion?(.failure(error))
            }
        }
    }
    
    task.resume()
}
