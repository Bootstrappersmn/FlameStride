//
//  ObservableUserDefaults+display.swift
//  
//
//  Created by Jeremy Bannister on 5/4/22.
//

///
import SwiftUI

///
public extension ObservableUserDefaults {
    
    ///
    @MainActor
    func standardDisplay () -> some View {
        self.standardDisplay(
            showHideValueToggle: { isShown in
                if isShown {
                    Text("Hide Value")
                        .font(.system(size: 10).bold())
                        .foregroundColor(.white)
                        .size(Self.sizeOfButtons)
                        .bubblify(color: .purple)
                } else {
                    Text("Show Value")
                        .font(.system(size: 10).bold())
                        .foregroundColor(.white)
                        .size(Self.sizeOfButtons)
                        .bubblify(color: .gray)
                }
            },
            deleteButton:
                Text("Delete")
                    .font(.system(size: 10).bold())
                    .foregroundColor(.white)
                    .size(Self.sizeOfButtons)
                    .bubblify(color: .red),
            valueDisplay: { (value: Any)->Text in
                if let data = value as? Data {
                    return Text("data: \(String(data: data, encoding: .utf8) ?? data.description)").font(.system(size: 12))
                } else if let customStringConvertible = value as? CustomStringConvertible {
                    return Text(customStringConvertible.description).font(.system(size: 12))
                } else {
                    let string = "\(value)"
                    return Text(string).font(.system(size: 12))
                }
            }
        )
    }
    
    ///
    static var sizeOfButtons: CGSize { .init(width: 70, height: 40) }
}

///
public extension ObservableUserDefaults {
    
    ///
    @MainActor
    func standardDisplay
        <ShowHideValueToggleDisplay: View,
         DeleteButtonDisplay: View,
         ValueDisplay: View>
        (keyFont: Font = .system(size: 12),
         @ViewBuilder showHideValueToggle: @escaping (Bool)->ShowHideValueToggleDisplay,
         deleteButton: DeleteButtonDisplay,
         valueDisplay: @escaping (Any)->ValueDisplay)
    -> some View {
        ObservableUserDefaultsStandardDisplay(
            observableUserDefaults: self,
            keyFont: keyFont,
            showHideValueToggle: showHideValueToggle,
            deleteButtonDisplay: deleteButton,
            valueDisplay: valueDisplay
        )
    }
}

///
fileprivate struct ObservableUserDefaultsStandardDisplay
    <ShowHideValueToggle: View,
     DeleteButtonDisplay: View,
     ValueDisplay: View>:
        View {
    
    ///
    @ObservedObject
    private var observableUserDefaults: ObservableUserDefaults
    
    ///
    private let keyFont: Font
    
    ///
    private let showHideValueToggle: (Bool)->ShowHideValueToggle
    
    ///
    private let deleteButtonDisplay: DeleteButtonDisplay
    
    ///
    private let valueDisplayGenerator: (Any)->ValueDisplay
    
    ///
    @State
    private var valueDisplaysByKey: [String: ValueDisplay] = [:]
    
    ///
    @State
    private var searchFilter: String = ""
    
    ///
    init
        (observableUserDefaults: ObservableUserDefaults,
         keyFont: Font,
         showHideValueToggle: @escaping (Bool)->ShowHideValueToggle,
         deleteButtonDisplay: DeleteButtonDisplay,
         valueDisplay: @escaping (Any)->ValueDisplay) {
        
        ///
        self._observableUserDefaults = .init(initialValue: observableUserDefaults)
        self.keyFont = keyFont
        self.showHideValueToggle = showHideValueToggle
        self.deleteButtonDisplay = deleteButtonDisplay
        self.valueDisplayGenerator = valueDisplay
    }
    
    ///
    var body: some View {
        VStack {
            searchBar
            
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(alignment: .center, spacing: 7) {
                    ForEach(
                        observableUserDefaults
                            .latestPublishedKeys
                            .filter { searchFilter.isEmpty ? true : $0.contains(searchFilter) }
                            .sorted(by: { $0 < $1 }),
                        id: \.self) { key in
                            
                            VStack {
                                HStack {
                                    
                                    ///
                                    Text(key)
                                        .font(keyFont)
                                    
                                    ///
                                    Spacer()
                                    
                                    ///
                                    Button(
                                        action: { toggleValueDisplay(forKey: key) },
                                        label: {
                                            showHideValueToggle(valueDisplaysByKey.keys.contains(key))
                                        }
                                    )
                                        .buttonStyle(CustomButtonStyle())
                                    
                                    ///
                                    deleteButton(forKey: key)
                                }
                                    .padding(.horizontal)
                                    .height(80)
                                
                                valueDisplaysByKey[key]
                            }
                                .bubblify()
                                .padding(2)
                        }
                }
            }
        }
        .padding()
    }
}

///
private extension ObservableUserDefaultsStandardDisplay {
    
    ///
    func toggleValueDisplay (forKey key: String) {
        if valueDisplaysByKey.keys.contains(key) {
            valueDisplaysByKey.removeValue(forKey: key)
        } else {
            if let value = observableUserDefaults.userDefaults.value(forKey: key) {
                valueDisplaysByKey[key] = valueDisplayGenerator(value)
            }
        }
    }
}

///
private extension ObservableUserDefaultsStandardDisplay {
    
    ///
    var searchBar: some View {
        TextField("Filter", text: $searchFilter)
            .textFieldStyle(.plain)
            .padding(.horizontal, 50)
            .expand()
            .height(50)
            .bubblify()
    }
}

///
private extension ObservableUserDefaultsStandardDisplay {
    
    ///
    func deleteButton (forKey key: String) -> some View {
        Button(
            action: {
                observableUserDefaults
                    .userDefaults
                    .set(nil, forKey: key)
            },
            label: { deleteButtonDisplay }
        )
            .buttonStyle(CustomButtonStyle())
    }
    
    ///
    var sizeOfButtons: CGSize {
        .init(width: 70, height: 40)
    }
}

///
fileprivate struct CustomButtonStyle: ButtonStyle {
    
    ///
    func makeBody (configuration: Configuration) -> some View {
        configuration
            .label
            .opacity(configuration.isPressed ? 0.75 : 1)
            .contentShape(Rectangle())
    }
}

///
fileprivate extension View {
    
    ///
    func bubblify (color: Color = .white,
                   cornerRadius: CGFloat = 8) -> some View {
        
        ///
        self.bubblify(
            color: color,
            shape: RoundedRectangle(cornerRadius: cornerRadius)
        )
    }
    
    ///
    func bubblify
    <S: Shape>
    (color: Color = .white,
     shape: S)
    -> some View {
        
        ///
        self
            .clipShape(shape)
            .background(
                shape
                    .fill(color)
                    .shadow(radius: 2, y: 1)
            )
    }
}

///
fileprivate extension View {
    
    ///
    func expand () -> some View {
        ZStack {
            Color.clear
            self
        }
    }
}

///
fileprivate extension View {
    
    ///
    func width (_ width: CGFloat?,
                alignment: Alignment = .center)
        -> some View {
        
        self.frame(
            width: width,
            alignment: alignment
        )
    }
    
    ///
    func height (_ height: CGFloat?,
                 alignment: Alignment = .center)
        -> some View {
        
        self.frame(
            height: height,
            alignment: alignment
        )
    }
    
    ///
    func size (_ size: CGSize?,
               alignment: Alignment = .center)
        -> some View {
        
        self.frame(
            width: size?.width,
            height: size?.height,
            alignment: alignment
        )
    }
}
