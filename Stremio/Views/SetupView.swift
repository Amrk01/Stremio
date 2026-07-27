import SwiftUI

struct SetupView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var addonURL = ""
    @State private var apiKey = ""
    @State private var isValidating = false
    @State private var errorMessage: String?
    @State private var currentStep = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerSection

                TabView(selection: $currentStep) {
                    welcomeStep.tag(0)
                    addonStep.tag(1)
                    debridStep.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
            }
            .background(Color(.systemBackground))
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.purple)
                .padding(.top, 40)

            Text("Stremio")
                .font(.largeTitle.bold())

            HStack(spacing: 8) {
                ForEach(0..<3) { step in
                    Capsule()
                        .fill(step <= currentStep ? Color.purple : Color.gray.opacity(0.3))
                        .frame(width: step == currentStep ? 24 : 8, height: 8)
                }
            }
            .padding(.bottom, 8)
        }
    }

    private var welcomeStep: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                featureRow(icon: "film.stack", title: "Catalogue", subtitle: "Parcourez vos films et séries")
                featureRow(icon: "magnifyingglass", title: "Recherche", subtitle: "Trouvez du contenu facilement")
                featureRow(icon: "bolt.fill", title: "RealDebrid", subtitle: "Streaming haute qualité")
                featureRow(icon: "play.circle.fill", title: "Lecture", subtitle: "Lecteur vidéo intégré")
            }
            .padding(.horizontal, 32)

            Spacer()

            Button {
                withAnimation { currentStep = 1 }
            } label: {
                Text("Commencer")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }

    private var addonStep: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(alignment: .leading, spacing: 12) {
                Text("URL de votre addon")
                    .font(.headline)

                Text("Entrez l'URL de votre addon AIOStreams ou tout autre addon Stremio compatible.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("https://aiostreams.example.com/.../manifest.json", text: $addonURL)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
            }
            .padding(.horizontal, 32)

            Spacer()

            HStack(spacing: 16) {
                Button("Retour") {
                    withAnimation { currentStep = 0 }
                }
                .foregroundColor(.purple)

                Button {
                    withAnimation { currentStep = 2 }
                } label: {
                    Text("Suivant")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(addonURL.isEmpty ? Color.gray : Color.purple)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(addonURL.isEmpty)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }

    private var debridStep: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(alignment: .leading, spacing: 12) {
                Text("Clé API RealDebrid")
                    .font(.headline)

                Text("Disponible sur real-debrid.com dans votre compte > API.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                SecureField("Votre clé API", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()

                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            HStack(spacing: 16) {
                Button("Retour") {
                    withAnimation { currentStep = 1 }
                }
                .foregroundColor(.purple)

                Button {
                    save()
                } label: {
                    HStack {
                        if isValidating {
                            ProgressView()
                                .tint(.white)
                        }
                        Text("Terminer")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(apiKey.isEmpty ? Color.gray : Color.purple)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(apiKey.isEmpty || isValidating)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }

    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.purple)
                .frame(width: 40)

            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private func save() {
        isValidating = true
        errorMessage = nil

        settings.addonURL = addonURL
        settings.realDebridAPIKey = apiKey
        isValidating = false
    }
}
