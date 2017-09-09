//
//  getData.swift
//  Congress
//
//  Created by Li on 11/18/16.
//  Copyright © 2016 Li. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
	func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
		contentMode = mode
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			guard
				let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
				let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
				let data = data, error == nil,
				let image = UIImage(data: data)
				else { return }
			DispatchQueue.main.async() { () -> Void in
				self.image = image
			}
			}.resume()
	}
	func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
		guard let url = URL(string: link) else { return }
		downloadedFrom(url: url, contentMode: mode)
	}
}
extension String {
	
	var length: Int {
		return self.characters.count
	}
	
	subscript (r: Range<Int>) -> String {
		let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
		                                    upper: min(length, max(0, r.upperBound))))
		let start = index(startIndex, offsetBy: range.lowerBound)
		let end = index(start, offsetBy: range.upperBound - range.lowerBound)
		return self[Range(start ..< end)]
	}
	
	subscript (i: Int) -> String {
		return self[Range(i ..< i + 1)]
	}
	
	func substring(from: Int) -> String {
		return self[Range(min(from, length) ..< length)]
	}
	
	func substring(to: Int) -> String {
		return self[Range(0 ..< max(0, to))]
	}
}
