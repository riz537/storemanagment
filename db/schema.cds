namespace mystore.db;

using {
    cuid,
    managed
} from '@sap/cds/common';


entity Stores  {
    key name     : String(20);
    location : String(20);
}


entity Products : cuid {
    name     : String(20);
    price    : Decimal(9, 2);
    discount : Integer;
    stock    : Integer;
    image    : LargeBinary @Core.MediaType: 'image/jpg';
}

entity Orders : cuid, managed {
    netPrice       : Decimal(9, 2) ;
    customerName   : String(20);
    customerMobile : String @assert.format: '^\+?[1-9]\d{1,14}$';
    store: Association to Stores;
    items: Composition of many OrderItems on items.order=$self;
}

entity OrderItems : cuid {
    order      : Association to Orders;
    product    : Association to Products;
    quantity   : Integer;
    unitPrice  : Decimal(9, 2);
    discount: Integer default 0 ;
    totalPrice : Decimal(9,2);
}




