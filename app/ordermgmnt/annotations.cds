using MyStoreService as service from '../../srv/store-srv';

annotate service.Orders with @(
    UI.LineItem             : [
        {
            $Type: 'UI.DataField',
            Value: ID,
            Label: 'Order ID',
        },
        {
            $Type: 'UI.DataField',
            Value: netPrice,
            Label: 'Net Price',
        },
        {
            $Type: 'UI.DataField',
            Value: store_name,
            Label: 'Store Name',
        },
        {
            $Type: 'UI.DataField',
            Value: createdBy,
        },
    ],
    UI.SelectionFields      : [
        ID,
        store_name,
    ],
    UI.HeaderInfo           : {
        TypeName      : 'Order',
        TypeNamePlural: 'Orders',
        Title         : {
            $Type: 'UI.DataField',
            Value: ID,
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: netPrice,
        },
        TypeImageUrl  : 'sap-icon://sales-order',
    },
    UI.Facets               : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Order Info',
            ID    : 'OrderInfo',
            Target: '@UI.FieldGroup#OrderInfo',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Order Items',
            ID    : 'OrderItems',
            Target: 'items/@UI.LineItem#OrderItems',
        },
    ],
    UI.FieldGroup #OrderInfo: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: ID,
                Label : 'Order ID',
            },
            {
                $Type: 'UI.DataField',
                Value: netPrice,
                Label: 'Net Price',
            },
            {
                $Type: 'UI.DataField',
                Value: customerName,
                Label: 'Customer Name',
            },
            {
                $Type: 'UI.DataField',
                Value: customerMobile,
                Label: 'Customer Mobile',
            },
            {
                $Type: 'UI.DataField',
                Value: createdBy,
            },
            {
                $Type: 'UI.DataField',
                Value: createdAt,
            },
            {
                $Type: 'UI.DataField',
                Value: store_name,
                Label : 'Store name',
            },
        ],
    },
);

annotate service.Orders with {
    ID @Common.Label: 'ID'
};

annotate service.Orders with {
    store_name @Common.Label: 'Store name'
};

annotate service.OrderItems with @(UI.LineItem #OrderItems: [
    {
        $Type: 'UI.DataField',
        Value: order_ID,
        Label: 'Order ID',
    },
    {
        $Type: 'UI.DataField',
        Value: product_ID,
        Label: 'Product ID',
    },
    {
        $Type: 'UI.DataField',
        Value: quantity,
        Label: 'Quantity',
    },
    {
        $Type: 'UI.DataField',
        Value: unitPrice,
        Label: 'Unit Price',
    },
    {
        $Type: 'UI.DataField',
        Value: totalPrice,
        Label: 'Total Price',
    },
    {
        $Type: 'UI.DataField',
        Value: discount,
        Label: 'Discount',
    },
]);

annotate service.OrderItems with {
    product_ID @(
        Common.ValueList               : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'Products',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    LocalDataProperty: product_ID,
                    ValueListProperty: 'ID',
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name',
                },
            ],
            Label         : 'Select Product',
        },
        Common.ValueListWithFixedValues: false,
    )
};

annotate service.OrderItems with {
    product @(
        Common.ValueList               : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'Products',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterInOut',
                    LocalDataProperty: product_ID,
                    ValueListProperty: 'ID',
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    LocalDataProperty: unitPrice,
                    ValueListProperty: 'price',
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    LocalDataProperty: discount,
                    ValueListProperty: 'discount',
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name',
                },
            ],
            Label         : 'Select Product',
        },
        Common.ValueListWithFixedValues: false,
    )
};

annotate service.OrderItems with @(
    Common.SideEffects  : {
        SourceProperties : ['quantity', 'unitPrice'],
        TargetProperties : ['totalPrice']
    }
);
annotate service.Orders with @(
    Common.SideEffects : {
        SourceEntities   : [items],
        TargetProperties : ['netPrice']
    }
);
annotate service.Orders with {
    netPrice @Common.FieldControl : #ReadOnly
};

annotate service.Orders with {
    store @Common.FieldControl : #ReadOnly
};

