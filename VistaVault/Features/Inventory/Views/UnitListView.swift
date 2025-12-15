import SwiftUI

struct UnitListView: View {
    @StateObject var vm = UnitsViewModel()
    @State private var showingEditor = false
    @State private var selectedUnit: Unit?

    var body: some View {
        Group {
            if vm.units.isEmpty {
                emptyStateView
            } else {
                unitsList
            }
        }
        .navigationTitle("Units of Measure")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    selectedUnit = nil
                    showingEditor.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingEditor) {
            UnitEditorView(vm: vm, unit: $selectedUnit)
        }
        .onAppear {
            vm.setupListener()
        }
        .alert("Error", isPresented: .constant(!vm.errorMessage.isEmpty)) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(vm.errorMessage)
        }
    }
    
    private var unitsList: some View {
        List {
            ForEach(vm.units) { unit in
                Button {
                    selectedUnit = unit
                    showingEditor.toggle()
                } label: {
                    UnitRow(unit: unit)
                }
                .buttonStyle(.plain)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        vm.deleteUnit(unit)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Units of Measure",
            systemImage: "ruler.fill",
            description: Text("Add units like pieces, boxes, kg, liters, etc.")
        )
        .overlay(alignment: .bottom) {
            Button("Add Unit") {
                showingEditor = true
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}

struct UnitRow: View {
    let unit: Unit

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "ruler.fill")
                .font(.title3)
                .foregroundColor(AppConstants.Colors.brandPrimary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(unit.name)
                    .font(.headline)
                
                if !unit.description.isEmpty {
                    Text(unit.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
