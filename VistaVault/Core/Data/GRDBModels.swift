import Foundation
import GRDB

// MARK: - Enums

enum TransactionType: String, Codable {
    case bill = "BILL"              // Vendor Invoice (Accounts Payable)
    case billPayment = "PAY"        // Vendor Payment (Accounts Payable)
    case invoice = "INV"            // Customer Invoice (Accounts Receivable)
    case receipt = "REC"            // Customer Payment (Accounts Receivable)
    case generalJournal = "JE"      // G/L Account Document
    case systemPosting = "SP"       // System Generated
}

enum OpenItemStatus: String, Codable {
    case open = "Open"
    case cleared = "Cleared"
    case revalued = "Revalued"
}

enum BusinessPartnerType: String, Codable {
    case organization = "ORG"
    case person = "PER"
    case group = "GRP"
}

enum AccountType: String, Codable {
    case asset = "Asset"
    case liability = "Liability"
    case equity = "Equity"
    case income = "Income"
    case expense = "Expense"
}

enum DebitCreditIndicator: String, Codable {
    case debit = "D"
    case credit = "C"
}

enum ReconciliationAccountType: String, Codable {
    case customer = "D"     // Debtor
    case vendor = "K"       // Kreditor
    case asset = "A"
    case general = "G"
}

// MARK: - User Model

struct User: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var email: String
    var passwordHash: String
    var createdAt: Date
    
    static let databaseTableName = "users"
    
    // Define relationships
    static let companyProfile = hasOne(CompanyProfileData.self)
    static let businessPartners = hasMany(BusinessPartnerData.self)
    static let transactions = hasMany(TransactionData.self)
}

// MARK: - Company Profile

struct CompanyProfileData: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var name: String
    var mobile: String
    var crNumber: String
    var address: String
    var currencyCode: String
    var currencySymbol: String
    var numberFormat: String
    var isSetupComplete: Bool
    var userId: String?
    
    static let databaseTableName = "company_profiles"
    static let user = belongsTo(User.self)
}

// MARK: - Company Code

struct CompanyCode: Codable, FetchableRecord, PersistableRecord {
    var id: Int64?
    var code: String
    var name: String
    var currencyCode: String
    var userId: String?
    
    static let databaseTableName = "company_codes"
    static let user = belongsTo(User.self)
    static let accounts = hasMany(Account.self)
}

// MARK: - Chart of Accounts

struct ChartOfAccounts: Codable, FetchableRecord, PersistableRecord {
    var id: Int64?
    var code: String
    var name: String
    var description: String?
    var userId: String?
    
    static let databaseTableName = "chart_of_accounts"
    static let user = belongsTo(User.self)
    static let accounts = hasMany(Account.self)
}

// MARK: - Account (G/L Account Master Data)

struct Account: Codable, FetchableRecord, PersistableRecord {
    var id: Int64?
    var code: String
    var name: String
    var chartOfAccountsId: Int64
    var companyCodeId: Int64
    var type: String                        // AccountType enum stored as string
    var accountCategory: String             // User-defined category
    var debitCreditIndicator: String        // 'D' or 'C' for normal balance
    var isOpenItemManaged: Bool
    var reconciliationAccountType: String?  // 'D', 'K', 'A', 'G'
    var isCostElement: Bool
    var costElementCategory: String?
    var postingBlock: Bool
    var isOnlyLocalCurrency: Bool
    var userId: String?
    
    static let databaseTableName = "accounts"
    
    static let chartOfAccounts = belongsTo(ChartOfAccounts.self)
    static let companyCode = belongsTo(CompanyCode.self)
    static let user = belongsTo(User.self)
    static let transactions = hasMany(TransactionData.self)
}

// MARK: - Business Partner

struct BusinessPartnerData: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var partnerCode: String
    var name: String
    var typeRaw: String                     // BusinessPartnerType enum
    var balance: Double
    var lastTransactionDate: Date
    var reconciliationAccountId: Int64?     // Link to G/L Account (V2) - can be nil for V1 compatibility
    var accountId: String?                  // Legacy V1 field for backward compatibility
    var firstName: String?
    var lastName: String?
    var email: String?
    var phone: String?
    var mobile: String?
    var website: String?
    var address: String?
    var city: String?
    var state: String?
    var postalCode: String?
    var country: String?
    var taxId: String?
    var vatNumber: String?
    var creditLimit: Double?
    var paymentTerms: Int?
    var discount: Double?
    var isActive: Bool
    var notes: String?
    var createdAt: Date?
    var updatedAt: Date?
    var userId: String?
    
    static let databaseTableName = "business_partners"
    static let user = belongsTo(User.self)
    static let reconciliationAccount = belongsTo(Account.self)
}

// MARK: - Transaction (Financial Document Header - BKPF)

struct TransactionData: Codable, FetchableRecord, PersistableRecord {
    var id: Int64?
    var documentNumber: Int
    var date: Date                          // Document date
    var postingDate: Date                   // Posting date
    var companyCodeId: Int64
    var transactionType: String             // TransactionType enum (JE, BILL, PAY, INV, REC, SP)
    var currencyCode: String?
    var exchangeRate: Double
    var exchangeRateTypeId: Int64?
    var isPosted: Bool
    var postedBy: Int64?                    // User who posted
    var reversesTransactionId: Int64?       // ID of transaction this reverses
    var userId: String?
    
    static let databaseTableName = "transactions"
    
    static let user = belongsTo(User.self)
    static let companyCode = belongsTo(CompanyCode.self)
    static let journalEntries = hasMany(JournalEntryLineItemData.self)
    static let postedByUser = belongsTo(User.self, key: "postedBy")
    static let reversedTransaction = belongsTo(TransactionData.self, key: "reversesTransactionId")
}

// MARK: - Posting Key

struct PostingKey: Codable, FetchableRecord, PersistableRecord {
    var id: Int64?
    var code: String
    var name: String
    var isDebit: Bool                       // True = Debit, False = Credit
    var accountType: String?                // For validation
    
    static let databaseTableName = "posting_keys"
}

// MARK: - Cost Center

struct CostCenter: Codable, FetchableRecord, PersistableRecord {
    var id: Int64?
    var code: String
    var name: String
    var description: String?
    var isActive: Bool
    var userId: String?
    
    static let databaseTableName = "cost_centers"
    static let user = belongsTo(User.self)
}

// MARK: - Profit Center

struct ProfitCenter: Codable, FetchableRecord, PersistableRecord {
    var id: Int64?
    var code: String
    var name: String
    var description: String?
    var isActive: Bool
    var userId: String?
    
    static let databaseTableName = "profit_centers"
    static let user = belongsTo(User.self)
}

// MARK: - Business Area

struct BusinessArea: Codable, FetchableRecord, PersistableRecord {
    var id: Int64?
    var code: String
    var name: String
    var description: String?
    var isActive: Bool
    var userId: String?
    
    static let databaseTableName = "business_areas"
    static let user = belongsTo(User.self)
}

// MARK: - Journal Entry Line Item (G/L Line Item - BSEG)
// This is the V2 ERP structure for journal entries

struct JournalEntryLineItemData: Codable, FetchableRecord, PersistableRecord {
    var id: Int64?
    var transactionId: Int64                // Link to Transaction (header)
    var lineItemNumber: Int
    var accountId: Int64                    // G/L Account
    var postingKeyId: Int64                 // Posting key determines debit/credit
    var amountFC: Double                    // Amount in foreign/transaction currency
    var amountBC: Double                    // Amount in base/local currency
    var costCenterId: Int64?
    var profitCenterId: Int64?
    var businessAreaId: Int64?
    var clearsLineItemId: Int64?            // Reference to line item this clears
    var openItemStatus: String              // OpenItemStatus enum
    
    static let databaseTableName = "journal_entry_line_items"
    
    static let transaction = belongsTo(TransactionData.self)
    static let account = belongsTo(Account.self)
    static let postingKey = belongsTo(PostingKey.self)
    static let costCenter = belongsTo(CostCenter.self)
    static let profitCenter = belongsTo(ProfitCenter.self)
    static let businessArea = belongsTo(BusinessArea.self)
    static let clearedByLine = belongsTo(JournalEntryLineItemData.self, key: "clearsLineItemId")
}

// MARK: - Journal Entry (Legacy V1 Structure for backward compatibility)
// This maintains the old flat structure that services expect

struct JournalEntryData: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var entryNumber: String
    var date: Date
    var entryDescription: String
    var createdAt: Date?
    var userId: String?
    
    static let databaseTableName = "journal_entries_v1"
    
    static let user = belongsTo(User.self)
    static let lineItems = hasMany(JournalLineItemData.self)
}

struct JournalLineItemData: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var accountId: String
    var accountName: String
    var typeRaw: String
    var amount: Double
    var memo: String?
    var journalEntryId: String?
    
    static let databaseTableName = "journal_line_items"
    
    static let journalEntry = belongsTo(JournalEntryData.self)
}

// MARK: - Inventory Item

struct InventoryItemData: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var productCode: String
    var name: String
    var itemDescription: String
    var displayName: String
    var unitId: String
    var valuationClassId: String?
    var salesAccountId: Int64?              // G/L Account for sales (V2)
    var cogsAccountId: Int64?               // G/L Account for COGS (V2)
    var inventoryAccountId: Int64?          // G/L Account for inventory (V2)
    var salesPrice: Double
    var purchasePrice: Double
    var availableQuantity: Int
    var timestamp: Date
    var userId: String?
    
    static let databaseTableName = "inventory_items"
    
    static let user = belongsTo(User.self)
    static let salesAccount = belongsTo(Account.self)
    static let cogsAccount = belongsTo(Account.self)
    static let inventoryAccount = belongsTo(Account.self)
}

// MARK: - Unit

struct UnitData: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var name: String
    var unitDescription: String
    var created: Date?
    var userId: String?
    
    static let databaseTableName = "units"
    static let user = belongsTo(User.self)
}

// MARK: - Valuation Class

struct ValuationClassData: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var classCode: String
    var name: String
    var classDescription: String?
    var inventoryAccountId: Int64           // Changed to Int64 for V2 Account reference
    var cogsAccountId: Int64                // Changed to Int64 for V2 Account reference
    var isActive: Bool
    var createdAt: Date?
    var updatedAt: Date?
    var userId: String?
    
    static let databaseTableName = "valuation_classes"
    
    static let user = belongsTo(User.self)
    static let inventoryAccount = belongsTo(Account.self)
    static let cogsAccount = belongsTo(Account.self)
}

// MARK: - V1 Legacy Models (No V2 equivalent yet)

// MARK: - Chart of Account (V1)

struct ChartOfAccountData: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var accountCode: String
    var accountName: String
    var accountTypeRaw: String
    var parentAccountId: String?
    var balance: Double
    var isActive: Bool
    var accountDescription: String?
    var level: Int
    var createdAt: Date?
    var updatedAt: Date?
    var userId: String?
    
    static let databaseTableName = "chart_of_accounts_v1"
    
    static let user = belongsTo(User.self)
}

// MARK: - Sale

struct SaleData: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var saleNumber: String
    var customerId: String
    var customerName: String
    var saleDate: Date
    var dueDate: Date?
    var statusRaw: String
    var subtotal: Double
    var taxAmount: Double
    var discountAmount: Double
    var totalAmount: Double
    var paidAmount: Double
    var notes: String?
    var paymentMethod: String?
    var referenceNumber: String?
    var createdAt: Date?
    var updatedAt: Date?
    var userId: String?
    
    static let databaseTableName = "sales"
    
    static let user = belongsTo(User.self)
    static let items = hasMany(SaleItemData.self)
}

struct SaleItemData: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var itemId: String
    var itemName: String
    var itemDescription: String?
    var quantity: Double
    var unitPrice: Double
    var taxRate: Double
    var discountPercent: Double
    var saleId: String?
    
    static let databaseTableName = "sale_items"
    
    static let sale = belongsTo(SaleData.self)
}

// MARK: - Purchase

struct PurchaseData: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var purchaseNumber: String
    var vendorId: String
    var vendorName: String
    var purchaseDate: Date
    var dueDate: Date?
    var statusRaw: String
    var subtotal: Double
    var taxAmount: Double
    var discountAmount: Double
    var totalAmount: Double
    var paidAmount: Double
    var notes: String?
    var paymentMethod: String?
    var referenceNumber: String?
    var createdAt: Date?
    var updatedAt: Date?
    var userId: String?
    
    static let databaseTableName = "purchases"
    
    static let user = belongsTo(User.self)
    static let items = hasMany(PurchaseItemData.self)
}

struct PurchaseItemData: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var itemId: String
    var itemName: String
    var itemDescription: String?
    var quantity: Double
    var unitPrice: Double
    var taxRate: Double
    var discountPercent: Double
    var purchaseId: String?
    
    static let databaseTableName = "purchase_items"
    
    static let purchase = belongsTo(PurchaseData.self)
}

// MARK: - Invoice

struct InvoiceData: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var invoiceNumber: String
    var customerId: String
    var customerName: String
    var invoiceDate: Date
    var totalAmount: Double
    var createdAt: Date?
    var userId: String?
    
    static let databaseTableName = "invoices"
    
    static let user = belongsTo(User.self)
    static let items = hasMany(InvoiceItemData.self)
}

struct InvoiceItemData: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var name: String
    var quantity: Int
    var unitPrice: Double
    var invoiceId: String?
    
    static let databaseTableName = "invoice_items"
    
    static let invoice = belongsTo(InvoiceData.self)
}

// MARK: - Incoming Payment

struct IncomingPaymentData: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var paymentNumber: String
    var amount: Double
    var date: Date
    var customerId: String
    var customerName: String
    var receivedInAccountId: String
    var notes: String?
    var referenceNumber: String?
    var createdAt: Date?
    var userId: String?
    
    static let databaseTableName = "incoming_payments"
    
    static let user = belongsTo(User.self)
}

// MARK: - Outgoing Payment

struct OutgoingPaymentData: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var paymentNumber: String
    var amount: Double
    var date: Date
    var vendorId: String
    var vendorName: String
    var paidFromAccountId: String
    var notes: String?
    var referenceNumber: String?
    var createdAt: Date?
    var userId: String?
    
    static let databaseTableName = "outgoing_payments"
    
    static let user = belongsTo(User.self)
}
