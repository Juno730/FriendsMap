//
//  UserViewModel.swift
//  FriendsMap
//
//  Created by Soom on 10/17/24.
//

import SwiftUI
import PhotosUI
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage


extension AuthenticationStore {
    
    func fetchContents(from email: String) async throws {
        do {
            let contents = try await db.collection("User").document(email).collection("Contents").getDocuments().documents
            for document in contents {
                let docData = document.data()
                let contentDate = docData["contentDate"] as? Date
                let imagePath = docData["image"] as? String
                let text = docData["text"] as? String
                let lati = docData["latitude"] as? Double
                let longti = docData["longitude"] as? Double
                
                if let imagePath, let text, let lati, let longti {
                    let imageUrl = try await makeUrltoImage(email: email, imagePath: imagePath)
                    let uiImage = await loadImageFromUrl(imageUrl: imageUrl)
                    if !self.user.contents.contains(where: { $0.id == document.documentID }) {
                        DispatchQueue.main.async {
                            self.user.contents.append(
                                Content(id: document.documentID, uiImage: uiImage, text: text, contentDate: .now, latitude: lati, longitude: longti)
                            )
                        }
                    }
                }
            }
        } catch {
            print("fetch date error: \(error.localizedDescription)")
        }
    }
    
    func fetchFriendContents(from email: String) async throws {
        friendContents = []
        do {
            let profileDoc = try await db.collection("User").document(email).collection("Profile").document("profileDoc").getDocument().data()
            guard let profileDoc, let nickname = profileDoc["nickname"] as? String, let imagePath = profileDoc["image"] as? String else {
                print("profileDoc: 값이 존재하지 않음")
                return
            }
            let imageUrl = try await makeUrltoImage(email: email, imagePath: imagePath )
            
            let uiImage =  await loadImageFromUrl(imageUrl: imageUrl)
            let contents = try await db.collection("User").document(email).collection("Contents").getDocuments().documents
            for document in contents {
                let docData = document.data()
                let contentDate = docData["contentDate"] as? Date
                let imagePath = docData["image"] as? String
                let text = docData["text"] as? String
                let lati = docData["latitude"] as? Double
                let longti = docData["longitude"] as? Double
                
                if let imagePath, let text, let lati, let longti {
                    let imageUrl = try await makeUrltoImage(email: email, imagePath: imagePath)
                    let image = await loadImageFromUrl(imageUrl: imageUrl)
                    if !self.friendContents.contains(where: { $0.id == document.documentID }) {
                        DispatchQueue.main.async {
                            self.friendContents.append(
                                Content(id: document.documentID, uiImage: image, text: text, contentDate: .now, latitude: lati, longitude: longti)
                            )
                        }
                    }
                }
            }
        }catch {
            print("fetch date error: \(error.localizedDescription)")
        }
    }
    
    func deleteContentImage(documentID: String, email: String) async throws {
        let storageRef = storage.reference()
        let fbDB = db.collection("User").document(email).collection("Contents")
        do {
            let imagePath = try await fbDB.document(documentID).getDocument().get("image")
            try await fbDB.document(documentID).delete()
            
            
            if let index = user.contents.firstIndex(where: { $0.id == documentID }) {
                DispatchQueue.main.async {
                    self.user.contents.remove(at: index)
                }
            }
            if let imagePath = imagePath as? String {
                try await storageRef.child("\(email)/\(imagePath)").delete()
            }
        } catch {
            print("Delete Error: \(error.localizedDescription)")
        }
    }
    
    
    // 게시글 생성
    func addContent(_ content: Content, _ image: Data?, _ email: String) async {
        let id = "\(UUID().uuidString)"
        let storageRef = storage.reference().child("\(email)/\(id)")
        
        // 원하는 이미지 크기 (예: 300x300으로 크기 조정)
        let targetSize = CGSize(width: 720, height: 1080)
        
        if let imageData = image,
           let originalImage = UIImage(data: imageData),
           let resizedImage = originalImage.resize(to: targetSize),
           let resizedImageData = resizedImage.jpegData(compressionQuality: 0.5) { // 압축 퀄리티 조정
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            do {
                let _ = try await storageRef.putDataAsync(resizedImageData, metadata: metadata)
            } catch {
                print("addImage Error\(error.localizedDescription)")
            }
        } else {
            print("이미지 리사이징에 실패했습니다.")
        }
        
        do {
            let db = Firestore.firestore()
            
            let userCollection = db.collection("User").document(email)
            
            let userContents = userCollection.collection("Contents").document()
            
            let body: [String: Any] = [
                "contentDate" : content.contentDate,
                "image" : id,
                "likeCount" : content.likeCount,
                "text" : content.text ?? "",
                "latitude" : content.latitude,
                "longitude" : content.longitude,
            ]
            
            try await userContents.setData(body)
            
        } catch {
            print("게시글 생성에 실패했습니다. \(error)")
        }
    }
    
    // Metadata extraction
    func extractMetadata(from data: Data) {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return }
        
        if let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] {
            if let gpsData = properties["{GPS}"] as? [String: Any] {
                if let latitude = gpsData["Latitude"] as? Double,
                   let latitudeRef = gpsData["LatitudeRef"] as? String,
                   let longitude = gpsData["Longitude"] as? Double,
                   let longitudeRef = gpsData["LongitudeRef"] as? String {
                    
                    imagelatitude = latitudeRef == "N" ? latitude : -latitude
                    imagelongitude = longitudeRef == "E" ? longitude : -longitude
                }
            }
            
            if let exifData = properties["{Exif}"] as? [String: Any],
               let dateString = exifData["DateTimeOriginal"] as? String {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
                imageDate = formatter.date(from: dateString)
            }
        }
    }
    func makeUrltoImage(email: String, imagePath: String) async throws -> URL {
        do {
            let storageRef = storage.reference(withPath: "\(email)/\(imagePath)")
            let url = try await storageRef.downloadURL()
            
            return url
        } catch let makeUrlError {
            print("Make Url Error!!: \(makeUrlError.localizedDescription)")
        }
        return URL.applicationDirectory
    }
    
    func loadImageFromUrl(imageUrl: URL) async -> UIImage {
        do {
            let (data, _ ) = try await URLSession.shared.data(from: imageUrl)
            return UIImage(data: data)!
        } catch {
            print("loadImaage Error: \(error.localizedDescription)")
            return UIImage(systemName: "xmark.circle.fill")!
        }
    }
    
    func updateLikeCount(for contentId: String, newLikeCount: Int, email: String) async {
        do {
            let contentRef = db.collection("User").document(email).collection("Contents").document(contentId)
            try await contentRef.updateData(["likeCount": newLikeCount])
        } catch {
            print("Failed to update like count: \(error.localizedDescription)")
        }
    }
}
