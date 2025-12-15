import SwiftUI

struct UnitEditorView: View {
    @ObservedObject var vm: UnitsViewModel
    @Binding var unit: Unit?
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var descriptionText = ""
    @State private var showError = false

    var isEditing: Bool {
        unit != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Unit Details")) {
                    TextField("Unit Name *", text: $name)
                        .autocapitalization(.words)
                    TextField("Description (Optional)", text: $descriptionText, axis: .vertical)
                        .lineLimit(2...3)
                }
                
                Section {
                    Text("Examples: piece, box, kg, liter, meter, etc.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if isEditing {
                    Section {
                        Button("Delete Unit", role: .destructive) {
                            deleteUnit()
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Unit" : "New Unit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Create") {
                        saveUnit()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { loadExistingData() }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(vm.errorMessage)
            }
        }
    }

    private func loadExistingData() {
        if let unit {
            name = unit.name
            descriptionText = unit.description
        }
    }

    private func saveUnit() {
        if isEditing {
            updateExistingUnit()
        } else {
            createNewUnit()
        }

        if vm.errorMessage.isEmpty {
            dismiss()
        } else {
            showError = true
        }
    }

    private func createNewUnit() {
        let newUnit = Unit(
            name: name.trimmingCharacters(in: .whitespaces),
            description: descriptionText.trimmingCharacters(in: .whitespaces)
        )
        vm.addUnit(newUnit)
    }

    private func updateExistingUnit() {
        guard let existingUnit = unit else { return }
        vm.updateUnit(
            existingUnit,
            name: name.trimmingCharacters(in: .whitespaces),
            description: descriptionText.trimmingCharacters(in: .whitespaces)
        )
    }

    private func deleteUnit() {
        guard let unit else { return }
        vm.deleteUnit(unit)
        dismiss()
    }
}
