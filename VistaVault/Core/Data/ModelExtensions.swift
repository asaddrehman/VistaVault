import Foundation

// MARK: - CompanyProfile Extensions

extension CompanyProfile {
    init(from data: CompanyProfileData) {
        self.init(
            id: data.id,
            name: data.name,
            mobile: data.mobile,
            crNumber: data.crNumber,
            address: data.address,
            currencyCode: data.currencyCode,
            currencySymbol: data.currencySymbol,
            numberFormat: data.numberFormat,
            isSetupComplete: data.isSetupComplete
        )
    }

    func toData() -> CompanyProfileData {
        CompanyProfileData(
            id: id,
            name: name,
            mobile: mobile,
            crNumber: crNumber,
            address: address,
            currencyCode: currencyCode,
            currencySymbol: currencySymbol,
            numberFormat: numberFormat,
            isSetupComplete: isSetupComplete
        )
    }
}

// MARK: - ChartOfAccount Extensions

extension ChartOfAccount {
    init(from data: ChartOfAccountData, userId: String) {
        self.init(
            id: data.id,
            userId: userId,
            accountCode: data.accountCode,
            accountName: data.accountName,
            accountType: ChartOfAccount.AccountType(rawValue: data.accountTypeRaw) ?? .currentAssets,
            parentAccountId: data.parentAccountId,
            balance: data.balance,
            isActive: data.isActive,
            description: data.accountDescription,
            level: data.level,
            createdAt: data.createdAt,
            updatedAt: data.updatedAt
        )
    }

    func toData() -> ChartOfAccountData {
        ChartOfAccountData(
            id: id ?? UUID().uuidString,
            accountCode: accountCode,
            accountName: accountName,
            accountTypeRaw: accountType.rawValue,
            parentAccountId: parentAccountId,
            balance: balance,
            isActive: isActive,
            accountDescription: description,
            level: level,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - BusinessPartner Extensions

extension BusinessPartner {
    init(from data: BusinessPartnerData, userId: String) {
        self.init(
            id: data.id,
            userId: userId,
            partnerCode: data.partnerCode,
            name: data.name,
            type: BusinessPartner.PartnerType(rawValue: data.typeRaw) ?? .customer,
            balance: data.balance,
            lastTransactionDate: data.lastTransactionDate,
            accountId: data.accountId ?? "",
            firstName: data.firstName,
            lastName: data.lastName,
            email: data.email,
            phone: data.phone,
            mobile: data.mobile,
            website: data.website,
            address: data.address,
            city: data.city,
            state: data.state,
            postalCode: data.postalCode,
            country: data.country,
            taxId: data.taxId,
            vatNumber: data.vatNumber,
            creditLimit: data.creditLimit,
            paymentTerms: data.paymentTerms,
            discount: data.discount,
            isActive: data.isActive,
            notes: data.notes,
            createdAt: data.createdAt,
            updatedAt: data.updatedAt
        )
    }

    func toData() -> BusinessPartnerData {
        BusinessPartnerData(
            id: id ?? UUID().uuidString,
            partnerCode: partnerCode,
            name: name,
            typeRaw: type.rawValue,
            balance: balance,
            lastTransactionDate: lastTransactionDate,
            accountId: accountId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            mobile: mobile,
            website: website,
            address: address,
            city: city,
            state: state,
            postalCode: postalCode,
            country: country,
            taxId: taxId,
            vatNumber: vatNumber,
            creditLimit: creditLimit,
            paymentTerms: paymentTerms,
            discount: discount,
            isActive: isActive,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - Sale Extensions

extension Sale {
    init(from data: SaleData, items itemsData: [SaleItemData], userId: String) {
        let items = itemsData.map { itemData in
            SaleItem(
                id: itemData.id,
                itemId: itemData.itemId,
                itemName: itemData.itemName,
                description: itemData.itemDescription,
                quantity: itemData.quantity,
                unitPrice: itemData.unitPrice,
                taxRate: itemData.taxRate,
                discountPercent: itemData.discountPercent
            )
        }

        self.init(
            id: data.id,
            userId: userId,
            saleNumber: data.saleNumber,
            customerId: data.customerId,
            customerName: data.customerName,
            saleDate: data.saleDate,
            dueDate: data.dueDate,
            status: Sale.SaleStatus(rawValue: data.statusRaw) ?? .draft,
            items: items,
            subtotal: data.subtotal,
            taxAmount: data.taxAmount,
            discountAmount: data.discountAmount,
            totalAmount: data.totalAmount,
            paidAmount: data.paidAmount,
            notes: data.notes,
            paymentMethod: data.paymentMethod,
            referenceNumber: data.referenceNumber,
            createdAt: data.createdAt,
            updatedAt: data.updatedAt
        )
    }

    func toData() -> SaleData {
        let saleData = SaleData(
            id: id ?? UUID().uuidString,
            saleNumber: saleNumber,
            customerId: customerId,
            customerName: customerName,
            saleDate: saleDate,
            dueDate: dueDate,
            statusRaw: status.rawValue,
            subtotal: subtotal,
            taxAmount: taxAmount,
            discountAmount: discountAmount,
            totalAmount: totalAmount,
            paidAmount: paidAmount,
            notes: notes,
            paymentMethod: paymentMethod,
            referenceNumber: referenceNumber,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
        return saleData
    }

    func toDataWithItems() -> (SaleData, [SaleItemData]) {
        let saleData = toData()
        let itemsData = items.map { item in
            SaleItemData(
                id: item.id,
                itemId: item.itemId,
                itemName: item.itemName,
                itemDescription: item.description,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                taxRate: item.taxRate,
                discountPercent: item.discountPercent
            )
        }
        return (saleData, itemsData)
    }
}

// MARK: - Purchase Extensions

extension Purchase {
    init(from data: PurchaseData, items itemsData: [PurchaseItemData], userId: String) {
        let items = itemsData.map { itemData in
            PurchaseItem(
                id: itemData.id,
                itemId: itemData.itemId,
                itemName: itemData.itemName,
                description: itemData.itemDescription,
                quantity: itemData.quantity,
                unitPrice: itemData.unitPrice,
                taxRate: itemData.taxRate,
                discountPercent: itemData.discountPercent
            )
        }

        self.init(
            id: data.id,
            userId: userId,
            purchaseNumber: data.purchaseNumber,
            vendorId: data.vendorId,
            vendorName: data.vendorName,
            purchaseDate: data.purchaseDate,
            dueDate: data.dueDate,
            status: Purchase.PurchaseStatus(rawValue: data.statusRaw) ?? .draft,
            items: items,
            subtotal: data.subtotal,
            taxAmount: data.taxAmount,
            discountAmount: data.discountAmount,
            totalAmount: data.totalAmount,
            paidAmount: data.paidAmount,
            notes: data.notes,
            paymentMethod: data.paymentMethod,
            referenceNumber: data.referenceNumber,
            createdAt: data.createdAt,
            updatedAt: data.updatedAt
        )
    }

    func toData() -> PurchaseData {
        let purchaseData = PurchaseData(
            id: id ?? UUID().uuidString,
            purchaseNumber: purchaseNumber,
            vendorId: vendorId,
            vendorName: vendorName,
            purchaseDate: purchaseDate,
            dueDate: dueDate,
            statusRaw: status.rawValue,
            subtotal: subtotal,
            taxAmount: taxAmount,
            discountAmount: discountAmount,
            totalAmount: totalAmount,
            paidAmount: paidAmount,
            notes: notes,
            paymentMethod: paymentMethod,
            referenceNumber: referenceNumber,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
        return purchaseData
    }

    func toDataWithItems() -> (PurchaseData, [PurchaseItemData]) {
        let purchaseData = toData()
        let itemsData = items.map { item in
            PurchaseItemData(
                id: item.id,
                itemId: item.itemId,
                itemName: item.itemName,
                itemDescription: item.description,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                taxRate: item.taxRate,
                discountPercent: item.discountPercent
            )
        }
        return (purchaseData, itemsData)
    }
}

// MARK: - InventoryItem Extensions

extension InventoryItem {
    init(from data: InventoryItemData) {
        self.init(
            id: data.id,
            productCode: data.productCode,
            name: data.name,
            description: data.itemDescription,
            displayName: data.displayName,
            unitId: data.unitId,
            valuationClassId: data.valuationClassId,
            salesPrice: data.salesPrice,
            purchasePrice: data.purchasePrice,
            availableQuantity: data.availableQuantity,
            timestamp: data.timestamp
        )
    }

    func toData() -> InventoryItemData {
        InventoryItemData(
            id: id ?? UUID().uuidString,
            productCode: productCode,
            name: name,
            itemDescription: description,
            displayName: displayName,
            unitId: unitId,
            valuationClassId: valuationClassId,
            salesPrice: salesPrice,
            purchasePrice: purchasePrice,
            availableQuantity: availableQuantity,
            timestamp: timestamp
        )
    }
}

// MARK: - Unit Extensions

extension Unit {
    init(from data: UnitData) {
        self.init(
            id: data.id,
            name: data.name,
            description: data.unitDescription,
            created: data.created
        )
    }

    func toData() -> UnitData {
        UnitData(
            id: id ?? UUID().uuidString,
            name: name,
            unitDescription: description,
            created: created
        )
    }
}

// MARK: - ValuationClass Extensions

extension ValuationClass {
    init(from data: ValuationClassData, userId: String) {
        self.init(
            id: data.id,
            userId: userId,
            classCode: data.classCode,
            name: data.name,
            description: data.classDescription,
            inventoryAccountId: String(data.inventoryAccountId),
            cogsAccountId: String(data.cogsAccountId),
            isActive: data.isActive,
            createdAt: data.createdAt,
            updatedAt: data.updatedAt
        )
    }
    
    func toData() -> ValuationClassData {
        ValuationClassData(
            id: id ?? UUID().uuidString,
            classCode: classCode,
            name: name,
            classDescription: description,
            inventoryAccountId: Int64(inventoryAccountId) ?? 0,
            cogsAccountId: Int64(cogsAccountId) ?? 0,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - Invoice Extensions

extension Invoice {
    init(from data: InvoiceData, items itemsData: [InvoiceItemData], userId: String) {
        let items = itemsData.map { itemData in
            InvoiceItem(
                id: itemData.id,
                name: itemData.name,
                quantity: itemData.quantity,
                unitPrice: itemData.unitPrice
            )
        }

        self.init(
            invoiceNumber: data.invoiceNumber,
            customerId: data.customerId,
            customerName: data.customerName,
            invoiceDate: data.invoiceDate,
            items: items,
            totalAmount: data.totalAmount,
            userId: userId
        )
    }

    func toData() -> InvoiceData {
        let invoiceData = InvoiceData(
            id: id ?? UUID().uuidString,
            invoiceNumber: invoiceNumber,
            customerId: customerId,
            customerName: customerName,
            invoiceDate: invoiceDate,
            totalAmount: totalAmount,
            createdAt: createdAt
        )
        return invoiceData
    }

    func toDataWithItems() -> (InvoiceData, [InvoiceItemData]) {
        let invoiceData = toData()
        let itemsData = items.map { item in
            InvoiceItemData(
                id: item.id,
                name: item.name,
                quantity: item.quantity,
                unitPrice: item.unitPrice
            )
        }
        return (invoiceData, itemsData)
    }
}

// MARK: - JournalEntry Extensions

extension JournalLineItem {
    func toData() -> JournalLineItemData {
        JournalLineItemData(
            id: id,
            accountId: accountId,
            accountName: accountName,
            typeRaw: type.rawValue,
            amount: amount,
            memo: memo
        )
    }
}

extension JournalEntry {
    init(from data: JournalEntryData, items lineItemsData: [JournalLineItemData], userId: String) {
        let lineItems = lineItemsData.map { lineItemData in
            JournalLineItem(
                id: lineItemData.id,
                accountId: lineItemData.accountId,
                accountName: lineItemData.accountName,
                type: JournalLineItem.EntryType(rawValue: lineItemData.typeRaw) ?? .debit,
                amount: lineItemData.amount,
                memo: lineItemData.memo
            )
        }

        self.init(
            id: data.id,
            entryNumber: data.entryNumber,
            date: data.date,
            description: data.entryDescription,
            userId: userId,
            lineItems: lineItems,
            createdAt: data.createdAt
        )
    }

    func toData() -> JournalEntryData {
        let journalData = JournalEntryData(
            id: id ?? UUID().uuidString,
            entryNumber: entryNumber,
            date: date,
            entryDescription: description,
            createdAt: createdAt
        )
        return journalData
    }

    func toDataWithLineItems() -> (JournalEntryData, [JournalLineItemData]) {
        let journalData = toData()
        let lineItemsData = lineItems.map { lineItem in
            JournalLineItemData(
                id: lineItem.id,
                accountId: lineItem.accountId,
                accountName: lineItem.accountName,
                typeRaw: lineItem.type.rawValue,
                amount: lineItem.amount,
                memo: lineItem.memo
            )
        }
        return (journalData, lineItemsData)
    }
}

// MARK: - IncomingPayment Extensions

extension IncomingPayment {
    init(from data: IncomingPaymentData, userId: String) {
        self.init(
            id: data.id,
            paymentNumber: data.paymentNumber,
            amount: data.amount,
            date: data.date,
            customerId: data.customerId,
            customerName: data.customerName,
            receivedInAccountId: data.receivedInAccountId,
            userId: userId,
            notes: data.notes,
            referenceNumber: data.referenceNumber,
            createdAt: data.createdAt
        )
    }
    
    func toData() -> IncomingPaymentData {
        let paymentId: String = id ?? UUID().uuidString
        return IncomingPaymentData(
            id: paymentId,
            paymentNumber: paymentNumber,
            amount: amount,
            date: date,
            customerId: customerId,
            customerName: customerName,
            receivedInAccountId: receivedInAccountId,
            notes: notes,
            referenceNumber: referenceNumber,
            createdAt: createdAt
        )
    }
}

// MARK: - OutgoingPayment Extensions

extension OutgoingPayment {
    init(from data: OutgoingPaymentData, userId: String) {
        self.init(
            id: data.id,
            paymentNumber: data.paymentNumber,
            amount: data.amount,
            date: data.date,
            vendorId: data.vendorId,
            vendorName: data.vendorName,
            paidFromAccountId: data.paidFromAccountId,
            userId: userId,
            notes: data.notes,
            referenceNumber: data.referenceNumber,
            createdAt: data.createdAt
        )
    }
    
    func toData() -> OutgoingPaymentData {
        let paymentId: String = id ?? UUID().uuidString
        return OutgoingPaymentData(
            id: paymentId,
            paymentNumber: paymentNumber,
            amount: amount,
            date: date,
            vendorId: vendorId,
            vendorName: vendorName,
            paidFromAccountId: paidFromAccountId,
            notes: notes,
            referenceNumber: referenceNumber,
            createdAt: createdAt
        )
    }
}
