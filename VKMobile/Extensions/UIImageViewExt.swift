//
//  UIImageViewExt.swift
//  VKMobile
//
//  Created by Grigory on 30.11.2020.
//

import UIKit

extension UIImageView {
    
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            guard
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data)
            else { return }
            
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }
    
    func loadCached(url: URL, directory: String?) {
        let dir: String = directory ?? "images"
        let cleanPath = getPathFromURL(url)
        if let image = getImageFromDisk(url: cleanPath, directory: dir) {
            DispatchQueue.main.async {
                self.image = image
            }
        } else {
            self.loadAndSave(url: url, directory: dir)
        }
    }
    
    private func loadAndSave(url: URL, directory: String) {
        DispatchQueue.global().async { [weak self] in
            guard
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data)
            else { return }
            
            let cleanPath = self?.getPathFromURL(url) ?? ""
            self?.saveImageToDisk(url: cleanPath, image: image, directory: directory)
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }
    
    private func getPathFromURL(_ url: URL) -> String {
        return "\(url.scheme ?? "http")://\(url.host ?? "")\(url.path)"
    }
    
    private func getCacheFolderURL(directory: String) -> URL? {
        guard
            let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        else { return nil }
        
        var dir: String = directory
        if directory == "" {
            dir = "images"
        }
        let url = cachesDirectory.appendingPathComponent(dir, isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
                return nil
            }
        }
        
        return url
    }
    
    private func getImagePath(url: String, directory: String) -> String? {
        guard
            let folderURL = getCacheFolderURL(directory: directory)
        else { return nil }
        
        let fileName = url.split(separator: "/").last ?? "default"
        return folderURL.appendingPathComponent(String(fileName)).path
    }
    
    private func getImageFromDisk(url: String, directory: String) -> UIImage? {
        guard
            let fileName = getImagePath(url: url, directory: directory),
            let info = try? FileManager.default.attributesOfItem(atPath: fileName),
            let modificationDate = info[FileAttributeKey.modificationDate] as? Date
        else { return nil }
        
        let lifeTime = Date().timeIntervalSince(modificationDate)
        guard
            lifeTime <= (30 * 24 * 60 * 60),
            let image = UIImage(contentsOfFile: fileName)
        else { return nil }
        
        return image
    }
    
    private func saveImageToDisk(url: String, image: UIImage, directory: String) {
        guard let fileName = getImagePath(url: url, directory: directory),
              let data = image.pngData()
        else { return }
        
        FileManager.default.createFile(atPath: fileName, contents: data, attributes: nil)
    }
    
}
