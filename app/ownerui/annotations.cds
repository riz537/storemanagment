using MyStoreService as service from '../../srv/store-srv';


annotate service.Products with @(
    UI.CreateHidden                           : {$edmJson: {$Not: {$Path: '/Configuration/isOwner'}}},
    UI.UpdateHidden                           : {$edmJson: {$Not: {$Path: '/Configuration/isOwner'}}},
    UI.DeleteHidden                           : {$edmJson: {$Not: {$Path: '/Configuration/isOwner'}}},
    UI.SelectionFields                        : [
        ID,
        name,
        price,
        store_ID,
    ],
    UI.LineItem                               : [
        {
            $Type: 'UI.DataField',
            Value: ID,
            Label: 'Product Id',
        },
        {
            $Type: 'UI.DataField',
            Value: name,
        },
        {
            $Type: 'UI.DataField',
            Value: price,
        },
        {
            $Type: 'UI.DataField',
            Value: discount,
            Label: 'discount',
        },
        {
            $Type: 'UI.DataField',
            Value: stock,
            Label: 'Stock',
        },
        {
            $Type      : 'UI.DataField',
            Value      : status,
            Label      : 'Status',
            Criticality: statusCriticality,
        },
        {
            $Type     : 'UI.DataFieldForAction',
            Action    : 'MyStoreService.ApplyDiscount',
            Label     : 'ApplyDiscount',
            @UI.Hidden: {$edmJson: {$Not: {$Path: '/Configuration/isOwner'}}}
        },


    ],
    UI.HeaderInfo                             : {
        TypeName      : 'Product',
        TypeNamePlural: 'Products',
        Title         : {
            $Type: 'UI.DataField',
            Value: name,
        },
        Description   : {
            $Type: 'UI.DataField',
            Value: ID,
        },
        ImageUrl      : image,
        TypeImageUrl  : 'Di',
    },
    UI.Facets                                 : [
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Product Information',
            ID    : 'ProductInformation',
            Target: '@UI.FieldGroup#ProductInformation',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Price and Discount Information',
            ID    : 'PriceandDiscountInformation',
            Target: '@UI.FieldGroup#PriceandDiscountInformation',
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Upload Product Image ',
            ID    : 'UploadProductImage',
            Target: '@UI.FieldGroup#UploadProductImage',
        },
    ],
    UI.FieldGroup #ProductInformation         : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: ID,
            },
            {
                $Type: 'UI.DataField',
                Value: name,
            },
            {
                $Type: 'UI.DataField',
                Value: stock
            },

        ],
    },
    UI.DataPoint #price                       : {
        $Type: 'UI.DataPointType',
        Value: price,
        Title: 'Price',
    },

    UI.HeaderFacets                           : [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'price',
            Target: '@UI.DataPoint#price',
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'status',
            Target: '@UI.DataPoint#status',
        },
    ],
    UI.DataPoint #stock                       : {
        $Type: 'UI.DataPointType',
        Value: stock,
        Title: 'stock',
    },
    UI.DataPoint #status                      : {
        $Type      : 'UI.DataPointType',
        Value      : status,
        Title      : 'Status',
        Criticality: statusCriticality,
    },
    UI.FieldGroup #UploadProductImage         : {
        $Type: 'UI.FieldGroupType',
        Data : [{
            $Type: 'UI.DataField',
            Value: image,
            Label: 'image',
        }, ],
    },
    UI.FieldGroup #PriceandDiscountInformation: {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: price,
            },
            {
                $Type: 'UI.DataField',
                Value: discount,
            },
        ],
    },

);

annotate service.Products with {
    ID       @Common.Label: 'Product Id';
    name     @Common.Label: 'Name';
    price    @Common.Label: 'Price';
    discount @Common.Label: 'Discount';
    stock    @Common.Label: 'Stock';
    status   @(
        Common.Label       : 'Status',
        Common.FieldControl: #ReadOnly,
    )
};
