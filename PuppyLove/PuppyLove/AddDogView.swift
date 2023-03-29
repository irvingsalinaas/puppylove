//
//  AddDogView.swift
//  PuppyLove
//
//  Created by Reagan Green on 3/18/23.
//

import Foundation
import SwiftUI
import PhotosUI

struct AddDogView: View {
    @State private var dogName = ""
    @State private var dogBreed = ""
    @State private var dogAge = "Puppy (0-1 years)"
    @State private var dogWeight: Int = 0
    @State private var dogSex = "Male"
    @State private var dogBio = ""
    @State private var activityLevel: Double = 0
    @State private var vaccinated = false
    @State private var fixed = false
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var dogPhoto: Data? = nil
    
    @State var breeds = [Breed]()
    @State var breedOptionTag: Int = 0

    @State var ageOptionTag: Int = 0
    
    var sexOptions = ["Male", "Female"]
    @State var sexOptionTag: Int = 0
    
    var ageOptions = ["Puppy (0-1 years)", "Young (1-4 years)", "Adult (4-8 years)", "Senior (8+ years)"]
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("Name", text: $dogName)
                }.padding()
                
                Section(header: Text("Profile Picture")) {
                    HStack {
                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            Text("Select a photo")
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    dogPhoto = data
                                }
                            }
                        }
                        Spacer()
                        if let dogPhoto,
                            let image = UIImage(data: dogPhoto) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                        }
                    }
                }.padding()
                
                Section(header: Text("Weight (lbs)")) {
                    Picker("Select weight", selection: $dogWeight) {
                        ForEach(1 ..< 150) { weight in
                            Text("\(weight)")
                        }
                    }
                }
                
                Section(header: Text("Activity Level")) {
                    Slider(
                        value: $activityLevel,
                        in: 0...10,
                        step: 1
                    )
                }.padding()
                
                Section(header: Text("Breed")) {
                    Picker("Select Breed", selection: $breedOptionTag) {
                        ForEach(0 ..< breeds.count, id: \.self) {
                            Text(self.breeds[$0].name)
                        }
                    }
                    .onAppear() {
                        DogAPI().loadData { (breeds) in
                            self.breeds = breeds
                        }
                    }
                }.padding()
                
                Section(header: Text("Sex")) {
                    HStack {
                        Picker("Select Sex", selection: $dogSex) {
                            ForEach(sexOptions, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                }.padding()
                
                Section(header: Text("Age")) {
                    HStack {
                        Picker("Age range", selection: $dogAge){
                            ForEach(ageOptions, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                }.padding()
                
                Section(header: Text("Bio")) {
                    TextField("Tell us about your pup...", text: $dogBio,  axis: .vertical)
                        .lineLimit(5...10)
                }.padding()
                
                Section(header: Text("Vaccination Status")) {
                    Toggle("Up to date on annual vaccinations?", isOn: $vaccinated)
                }.padding()
                
                Section(header: Text("Fixed Status")) {
                    Toggle("Is your dog neutered/spayed?", isOn: $fixed)
                }.padding()
            }
            
            NavigationLink(destination: UserPreferencesView(), label: {
                    Text("Next")
                    .onTapGesture {
                        self.sendRequest()
                    }
            })
        }
        .navigationBarTitle(Text("Dog Information"))
        .navigationBarBackButtonHidden(true)
    }
    
    func sendRequest() {
        let newDog = Dog(
            name: dogName,
            age: dogAge,
            activityLevel: activityLevel,
            bio: dogBio,
            breed: dogBreed,
            weight: dogWeight,
            sex: dogSex,
            //profilePicture: image,
            vaccinated: vaccinated,
            fixed: fixed
        )
        print(newDog)
    }
}

struct AddDogView_Previews: PreviewProvider {
    static var previews: some View {
        AddDogView()
    }
}
