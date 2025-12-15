import Foundation
import GRDB

@MainActor
class GRDBDataController {
    static let shared = GRDBDataController()
    
    private(set) var dbQueue: DatabaseQueue!
    
    private init() {
        do {
            let fileManager = FileManager.default
            let folderURL = try fileManager
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("VistaVault", isDirectory: true)
            
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
            let dbURL = folderURL.appendingPathComponent("vistavault_v2.sqlite")
            
            dbQueue = try DatabaseQueue(path: dbURL.path)
            try migrator.migrate(dbQueue)
        } catch {
            fatalError("Could not create DatabaseQueue: \(error)")
        }
    }
    
    // MARK: - Database Migration
    
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        // Migration v1: Initial schema following SQLAlchemy structure
        migrator.registerMigration("v1_erp_structure") { db in
            // Users table
            try db.create(table: "users") { t in
                t.column("id", .text).primaryKey()
                t.column("email", .text).notNull().unique()
                t.column("passwordHash", .text).notNull()
                t.column("createdAt", .datetime).notNull()
            }
            
            // Company profiles table
            try db.create(table: "company_profiles") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("mobile", .text).notNull()
                t.column("crNumber", .text).notNull()
                t.column("address", .text).notNull()
                t.column("currencyCode", .text).notNull()
                t.column("currencySymbol", .text).notNull()
                t.column("numberFormat", .text).notNull()
                t.column("isSetupComplete", .boolean).notNull()
                t.column("userId", .text).references("users", onDelete: .cascade)
            }
            
            // Company codes table
            try db.create(table: "company_codes") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("code", .text).notNull()
                t.column("name", .text).notNull()
                t.column("currencyCode", .text).notNull()
                t.column("userId", .text).references("users", onDelete: .cascade)
                t.uniqueKey(["code", "userId"])
            }
            
            // Chart of accounts table
            try db.create(table: "chart_of_accounts") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("code", .text).notNull()
                t.column("name", .text).notNull()
                t.column("description", .text)
                t.column("userId", .text).references("users", onDelete: .cascade)
                t.uniqueKey(["code", "userId"])
            }
            
            // Accounts table (G/L Account Master Data)
            try db.create(table: "accounts") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("code", .text).notNull().indexed()
                t.column("name", .text).notNull().indexed()
                t.column("chartOfAccountsId", .integer).notNull().references("chart_of_accounts", onDelete: .restrict)
                t.column("companyCodeId", .integer).notNull().references("company_codes", onDelete: .restrict)
                t.column("type", .text).notNull() // Asset, Liability, Equity, Income, Expense
                t.column("accountCategory", .text).notNull()
                t.column("debitCreditIndicator", .text).notNull() // 'D' or 'C'
                t.column("isOpenItemManaged", .boolean).notNull().defaults(to: false)
                t.column("reconciliationAccountType", .text) // 'D', 'K', 'A', 'G'
                t.column("isCostElement", .boolean).notNull().defaults(to: false)
                t.column("costElementCategory", .text)
                t.column("postingBlock", .boolean).notNull().defaults(to: false)
                t.column("isOnlyLocalCurrency", .boolean).notNull().defaults(to: true)
                t.column("userId", .text).references("users", onDelete: .cascade)
                t.uniqueKey(["code", "companyCodeId"])
            }
            
            // Posting keys table
            try db.create(table: "posting_keys") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("code", .text).notNull().unique()
                t.column("name", .text).notNull()
                t.column("isDebit", .boolean).notNull()
                t.column("accountType", .text)
            }
            
            // Cost centers table
            try db.create(table: "cost_centers") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("code", .text).notNull()
                t.column("name", .text).notNull()
                t.column("description", .text)
                t.column("isActive", .boolean).notNull().defaults(to: true)
                t.column("userId", .text).references("users", onDelete: .cascade)
                t.uniqueKey(["code", "userId"])
            }
            
            // Profit centers table
            try db.create(table: "profit_centers") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("code", .text).notNull()
                t.column("name", .text).notNull()
                t.column("description", .text)
                t.column("isActive", .boolean).notNull().defaults(to: true)
                t.column("userId", .text).references("users", onDelete: .cascade)
                t.uniqueKey(["code", "userId"])
            }
            
            // Business areas table
            try db.create(table: "business_areas") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("code", .text).notNull()
                t.column("name", .text).notNull()
                t.column("description", .text)
                t.column("isActive", .boolean).notNull().defaults(to: true)
                t.column("userId", .text).references("users", onDelete: .cascade)
                t.uniqueKey(["code", "userId"])
            }
            
            // Business partners table
            try db.create(table: "business_partners") { t in
                t.column("id", .text).primaryKey()
                t.column("partnerCode", .text).notNull()
                t.column("name", .text).notNull()
                t.column("typeRaw", .text).notNull() // Customer/Vendor/Both
                t.column("balance", .double).notNull()
                t.column("lastTransactionDate", .datetime).notNull()
                t.column("reconciliationAccountId", .integer).references("accounts")
                t.column("accountId", .text) // Legacy V1 field for backward compatibility
                t.column("firstName", .text)
                t.column("lastName", .text)
                t.column("email", .text)
                t.column("phone", .text)
                t.column("mobile", .text)
                t.column("website", .text)
                t.column("address", .text)
                t.column("city", .text)
                t.column("state", .text)
                t.column("postalCode", .text)
                t.column("country", .text)
                t.column("taxId", .text)
                t.column("vatNumber", .text)
                t.column("creditLimit", .double)
                t.column("paymentTerms", .integer)
                t.column("discount", .double)
                t.column("isActive", .boolean).notNull()
                t.column("notes", .text)
                t.column("createdAt", .datetime)
                t.column("updatedAt", .datetime)
                t.column("userId", .text).references("users", onDelete: .cascade)
            }
            
            // Transactions table (Financial Document Header - BKPF)
            try db.create(table: "transactions") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("documentNumber", .integer).notNull().indexed()
                t.column("date", .date).notNull().indexed()
                t.column("postingDate", .date).notNull().indexed()
                t.column("companyCodeId", .integer).notNull().indexed().references("company_codes", onDelete: .restrict)
                t.column("transactionType", .text).notNull().indexed() // JE, BILL, PAY, INV, REC, SP
                t.column("currencyCode", .text)
                t.column("exchangeRate", .double).notNull().defaults(to: 1.0)
                t.column("exchangeRateTypeId", .integer)
                t.column("isPosted", .boolean).notNull().defaults(to: true).indexed()
                t.column("postedBy", .integer).references("users")
                t.column("reversesTransactionId", .integer).references("transactions")
                t.column("userId", .text).references("users", onDelete: .cascade)
                t.uniqueKey(["documentNumber", "companyCodeId", "transactionType"])
            }
            try db.create(index: "ix_transactions_company_posting_date", on: "transactions", columns: ["companyCodeId", "postingDate"])
            try db.create(index: "ix_transactions_type_date", on: "transactions", columns: ["transactionType", "postingDate"])
            
            // Journal entries table (G/L Line Items - BSEG)
            try db.create(table: "journal_entries") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("transactionId", .integer).notNull().indexed().references("transactions", onDelete: .cascade)
                t.column("lineItemNumber", .integer).notNull()
                t.column("accountId", .integer).notNull().indexed().references("accounts", onDelete: .restrict)
                t.column("postingKeyId", .integer).notNull().indexed().references("posting_keys", onDelete: .restrict)
                t.column("amountFC", .double).notNull() // Foreign currency amount
                t.column("amountBC", .double).notNull() // Base currency amount
                t.column("costCenterId", .integer).references("cost_centers")
                t.column("profitCenterId", .integer).references("profit_centers")
                t.column("businessAreaId", .integer).references("business_areas")
                t.column("clearsLineItemId", .integer).references("journal_entries")
                t.column("openItemStatus", .text).notNull().indexed() // Open, Cleared, Revalued
                t.uniqueKey(["transactionId", "lineItemNumber"])
            }
            try db.create(index: "ix_journal_entries_account_status", on: "journal_entries", columns: ["accountId", "openItemStatus"])
            try db.create(index: "ix_je_account_transaction", on: "journal_entries", columns: ["accountId", "transactionId"])
            try db.create(index: "ix_je_posting_key", on: "journal_entries", columns: ["postingKeyId"])
            
            // Inventory items table
            try db.create(table: "inventory_items") { t in
                t.column("id", .text).primaryKey()
                t.column("productCode", .text).notNull()
                t.column("name", .text).notNull()
                t.column("itemDescription", .text).notNull()
                t.column("displayName", .text).notNull()
                t.column("unitId", .text).notNull()
                t.column("valuationClassId", .text)
                t.column("salesAccountId", .integer).references("accounts")
                t.column("cogsAccountId", .integer).references("accounts")
                t.column("inventoryAccountId", .integer).references("accounts")
                t.column("salesPrice", .double).notNull()
                t.column("purchasePrice", .double).notNull()
                t.column("availableQuantity", .integer).notNull()
                t.column("timestamp", .datetime).notNull()
                t.column("userId", .text).references("users", onDelete: .cascade)
            }
            
            // Units table
            try db.create(table: "units") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("unitDescription", .text).notNull()
                t.column("created", .datetime)
                t.column("userId", .text).references("users", onDelete: .cascade)
            }
            
            // Valuation classes table
            try db.create(table: "valuation_classes") { t in
                t.column("id", .text).primaryKey()
                t.column("classCode", .text).notNull()
                t.column("name", .text).notNull()
                t.column("classDescription", .text)
                t.column("inventoryAccountId", .integer).notNull().references("accounts")
                t.column("cogsAccountId", .integer).notNull().references("accounts")
                t.column("isActive", .boolean).notNull()
                t.column("createdAt", .datetime)
                t.column("updatedAt", .datetime)
                t.column("userId", .text).references("users", onDelete: .cascade)
            }
            
            // Legacy V1 tables for backward compatibility
            
            // Chart of accounts V1
            try db.create(table: "chart_of_accounts_v1") { t in
                t.column("id", .text).primaryKey()
                t.column("accountCode", .text).notNull()
                t.column("accountName", .text).notNull()
                t.column("accountTypeRaw", .text).notNull()
                t.column("parentAccountId", .text)
                t.column("balance", .double).notNull()
                t.column("isActive", .boolean).notNull()
                t.column("accountDescription", .text)
                t.column("level", .integer).notNull()
                t.column("createdAt", .datetime)
                t.column("updatedAt", .datetime)
                t.column("userId", .text).references("users", onDelete: .cascade)
            }
            
            // Journal entries V1 (flat structure)
            try db.create(table: "journal_entries_v1") { t in
                t.column("id", .text).primaryKey()
                t.column("entryNumber", .text).notNull()
                t.column("date", .datetime).notNull()
                t.column("entryDescription", .text).notNull()
                t.column("createdAt", .datetime)
                t.column("userId", .text).references("users", onDelete: .cascade)
            }
            
            // Journal line items V1
            try db.create(table: "journal_line_items") { t in
                t.column("id", .text).primaryKey()
                t.column("accountId", .text).notNull()
                t.column("accountName", .text).notNull()
                t.column("typeRaw", .text).notNull()
                t.column("amount", .double).notNull()
                t.column("memo", .text)
                t.column("journalEntryId", .text).references("journal_entries_v1", onDelete: .cascade)
            }
            
            // Sales table
            try db.create(table: "sales") { t in
                t.column("id", .text).primaryKey()
                t.column("saleNumber", .text).notNull()
                t.column("customerId", .text).notNull()
                t.column("customerName", .text).notNull()
                t.column("saleDate", .datetime).notNull()
                t.column("dueDate", .datetime)
                t.column("statusRaw", .text).notNull()
                t.column("subtotal", .double).notNull()
                t.column("taxAmount", .double).notNull()
                t.column("discountAmount", .double).notNull()
                t.column("totalAmount", .double).notNull()
                t.column("paidAmount", .double).notNull()
                t.column("notes", .text)
                t.column("paymentMethod", .text)
                t.column("referenceNumber", .text)
                t.column("createdAt", .datetime)
                t.column("updatedAt", .datetime)
                t.column("userId", .text).references("users", onDelete: .cascade)
            }
            
            // Sale items table
            try db.create(table: "sale_items") { t in
                t.column("id", .text).primaryKey()
                t.column("itemId", .text).notNull()
                t.column("itemName", .text).notNull()
                t.column("itemDescription", .text)
                t.column("quantity", .double).notNull()
                t.column("unitPrice", .double).notNull()
                t.column("taxRate", .double).notNull()
                t.column("discountPercent", .double).notNull()
                t.column("saleId", .text).references("sales", onDelete: .cascade)
            }
            
            // Purchases table
            try db.create(table: "purchases") { t in
                t.column("id", .text).primaryKey()
                t.column("purchaseNumber", .text).notNull()
                t.column("vendorId", .text).notNull()
                t.column("vendorName", .text).notNull()
                t.column("purchaseDate", .datetime).notNull()
                t.column("dueDate", .datetime)
                t.column("statusRaw", .text).notNull()
                t.column("subtotal", .double).notNull()
                t.column("taxAmount", .double).notNull()
                t.column("discountAmount", .double).notNull()
                t.column("totalAmount", .double).notNull()
                t.column("paidAmount", .double).notNull()
                t.column("notes", .text)
                t.column("paymentMethod", .text)
                t.column("referenceNumber", .text)
                t.column("createdAt", .datetime)
                t.column("updatedAt", .datetime)
                t.column("userId", .text).references("users", onDelete: .cascade)
            }
            
            // Purchase items table
            try db.create(table: "purchase_items") { t in
                t.column("id", .text).primaryKey()
                t.column("itemId", .text).notNull()
                t.column("itemName", .text).notNull()
                t.column("itemDescription", .text)
                t.column("quantity", .double).notNull()
                t.column("unitPrice", .double).notNull()
                t.column("taxRate", .double).notNull()
                t.column("discountPercent", .double).notNull()
                t.column("purchaseId", .text).references("purchases", onDelete: .cascade)
            }
            
            // Invoices table
            try db.create(table: "invoices") { t in
                t.column("id", .text).primaryKey()
                t.column("invoiceNumber", .text).notNull()
                t.column("customerId", .text).notNull()
                t.column("customerName", .text).notNull()
                t.column("invoiceDate", .datetime).notNull()
                t.column("totalAmount", .double).notNull()
                t.column("createdAt", .datetime)
                t.column("userId", .text).references("users", onDelete: .cascade)
            }
            
            // Invoice items table
            try db.create(table: "invoice_items") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("quantity", .integer).notNull()
                t.column("unitPrice", .double).notNull()
                t.column("invoiceId", .text).references("invoices", onDelete: .cascade)
            }
            
            // Incoming payments table
            try db.create(table: "incoming_payments") { t in
                t.column("id", .text).primaryKey()
                t.column("paymentNumber", .text).notNull()
                t.column("amount", .double).notNull()
                t.column("date", .datetime).notNull()
                t.column("customerId", .text).notNull()
                t.column("customerName", .text).notNull()
                t.column("receivedInAccountId", .text).notNull()
                t.column("notes", .text)
                t.column("referenceNumber", .text)
                t.column("createdAt", .datetime)
                t.column("userId", .text).references("users", onDelete: .cascade)
            }
            
            // Outgoing payments table
            try db.create(table: "outgoing_payments") { t in
                t.column("id", .text).primaryKey()
                t.column("paymentNumber", .text).notNull()
                t.column("amount", .double).notNull()
                t.column("date", .datetime).notNull()
                t.column("vendorId", .text).notNull()
                t.column("vendorName", .text).notNull()
                t.column("paidFromAccountId", .text).notNull()
                t.column("notes", .text)
                t.column("referenceNumber", .text)
                t.column("createdAt", .datetime)
                t.column("userId", .text).references("users", onDelete: .cascade)
            }
        }
        
        return migrator
    }
    
    // MARK: - User Management
    
    func createUser(email: String, passwordHash: String) throws -> User {
        let user = User(id: UUID().uuidString, email: email, passwordHash: passwordHash, createdAt: Date())
        try dbQueue.write { db in
            try user.insert(db)
        }
        return user
    }
    
    func fetchUser(byEmail email: String) throws -> User? {
        try dbQueue.read { db in
            try User.filter(Column("email") == email).fetchOne(db)
        }
    }
    
    func fetchUser(byId id: String) throws -> User? {
        try dbQueue.read { db in
            try User.filter(Column("id") == id).fetchOne(db)
        }
    }
    
    func deleteAllData() throws {
        try dbQueue.write { db in
            try User.deleteAll(db)
        }
    }
    
    // MARK: - Save Context
    
    func save() throws {
        // GRDB auto-saves on write transactions, no explicit save needed
    }
}
