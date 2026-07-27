import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var addonURL: String = ""
    @State private var apiKey: String = ""
    @State private var showSaved = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("URL Addon")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("https://aiostreams.example.com/...", text: $addonURL)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .keyboardType(.URL)
                            .font(.subheadline)
                    }
                } header: {
                    Text("Addon Stremio")
                } footer: {
                    Text("URL de votre addon AIOStreams. Vous pouvez coller l'URL complète avec ou sans /manifest.json")
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Clé API")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        SecureField("Votre clé API RealDebrid", text: $apiKey)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .font(.subheadline)
                    }
                } header: {
                    Text("RealDebrid")
                } footer: {
                    Text("Disponible sur real-debrid.com > Mon compte > API")
                }

                Section {
                    Button {
                        save()
                    } label: {
                        HStack {
                            Spacer()
                            if showSaved {
                                Label("Sauvegardé", systemImage: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            } else {
                                Text("Sauvegarder")
                                    .foregroundStyle(.purple)
                            }
                            Spacer()
                        }
                    }
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Information")
                }
            }
            .navigationTitle("Réglages")
            .onAppear {
                addonURL = settings.addonURL
                apiKey = settings.realDebridAPIKey
            }
        }
    }

    private func save() {
        settings.addonURL = addonURL
        settings.realDebridAPIKey = apiKey
        showSaved = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showSaved = false
        }
    }
}
