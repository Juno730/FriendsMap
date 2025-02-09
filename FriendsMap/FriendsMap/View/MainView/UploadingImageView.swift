//
//  UploadImageView.swift
//  FriendsMap
//
//  Created by 박준영 on 10/14/24.
//

import SwiftUI
import MapKit
import PhotosUI
import ImageIO

struct UploadingImageView: View {
    @EnvironmentObject private var authStore: AuthenticationStore
    @Environment(\.dismiss) var dismiss
    @Binding var selectedLatitude: Double?
    @Binding var selectedLongitude: Double?
    @Binding var annotations: [IdentifiableLocation]
    @Binding var position: MapCameraPosition
    
    @State var imageSelection: PhotosPickerItem? = nil
    @State var uiImage: UIImage? = nil
    @State var selectedImageData: Data? = nil
    @State var text: String = ""
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center) {
                HStack {
                    Button {
                        dismiss()
                    } label : {
                        Text("취소")
                            .foregroundStyle(.blue)
                    }
                    
                    Spacer()
                    
                    
                    Text("새 게시글")
                        .fontWeight(.bold)
                        .font(.system(size: screenWidth * 0.05))
                        .padding()
                    
                    Spacer()
                    
                    Button {
                        if uiImage != nil {
                            
                            Task {
                                var content = Content(id: UUID().uuidString, uiImage: uiImage, text: text, contentDate: authStore.imageDate ?? Date(), latitude: authStore.imagelatitude, longitude: authStore.imagelongitude)
                                
                                await authStore.addContent(content, selectedImageData, authStore.user.email)
                                
                                // 이미지를 업로드한 후, 사용자 데이터를 다시 로드
                                try await authStore.fetchContents(from: authStore.user.email)
                                // 새로운 게시물 데이터를 기반으로 어노테이션을 업데이트
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    annotations.append(IdentifiableLocation (contentId: content.id, coordinate: CLLocationCoordinate2D(latitude: content.latitude, longitude: content.longitude), image: content.image, email: authStore.user.email, date: content.contentDate,text: content.text ,profileImage: authStore.user.profile.uiimage!, nickname: authStore.user.profile.nickname))
                                }
                            }
                            // 업로드 후 지도 위치를 등록된 이미지의 위치로 이동
                            dismiss()
                        }
                        
                    } label : {
                        Text("추가")
                            .foregroundStyle(.blue)
                    }
                }
                .padding(.horizontal)
                
                if let uiImage = uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: screenHeight * 0.2)
                } else {
                    Text("No Image")
                        .frame(width: screenWidth * 0.9, height: screenHeight * 0.2)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(.gray, style: StrokeStyle(lineWidth:1, dash: [20]))
                        }
                }
                
                PhotosPicker(
                    selection: $imageSelection,
                    matching: .images,
                    photoLibrary: .shared()) {
                        if imageSelection == nil {
                            HStack{
                                Image(systemName: "photo.on.rectangle.angled")
                                Text("사진앱에서 가져오기")
                            }
                            .frame(width: screenWidth * 0.9, height: screenHeight * 0.06)
                            .background(Color(hex: "52A690"))
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                        } else {
                            HStack{
                                Image(systemName: "photo.on.rectangle.angled")
                                Text("사진 교체")
                            }
                            .frame(width: screenWidth * 0.9, height: screenHeight * 0.06)
                            .background(Color(hex: "52A690"))
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                        }
                    }
                    .onChange(of: imageSelection) { _ , _  in
                        Task {
                            if let newSelection = imageSelection,
                               let data = try? await newSelection.loadTransferable(type: Data.self) {
                                uiImage = UIImage(data: data)
                                authStore.extractMetadata(from: data)
                                selectedImageData = data
                                position = MapCameraPosition.region(
                                    MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(
                                            latitude: authStore.imagelatitude,
                                            longitude: authStore.imagelongitude
                                        ),
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    )
                                )
                            }
                        }
                    }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: screenWidth * 0.9, height: screenHeight * 0.1)
                        .foregroundStyle(.gray.opacity(0.2))
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("\(text.count) / 50")
                                .foregroundStyle(text.count >= 50 ? .red : .gray)
                        }
                        .padding()
                    }
                    .frame(width: screenWidth * 0.9, height: screenHeight * 0.1)
                    
                    VStack(alignment : .center) {
                        TextField("내용을 입력해주세요", text: $text, axis: .vertical)
                            .frame(width: screenWidth * 0.85)
                            .padding()
                            .onChange(of: text) {
                                text = String(text.prefix(50))
                            }
                        Spacer()
                    }
                    .frame(width: screenWidth * 0.9, height: screenHeight * 0.1)
                }
                
                Spacer()
            }
            .frame(width: screenWidth, height: screenHeight)
            .background(.white)
        }
    }
}

//#Preview {
//    UploadingImageView(selectedLatitude: .constant(nil), selectedLongitude: .constant(nil), annotations: .constant([]), position: .constant(MapCameraPosition.region(<#T##MKCoordinateRegion#>)))
//        .environmentObject(AuthenticationStore())
//}
