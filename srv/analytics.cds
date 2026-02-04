using { mystore.db as db } from '../db/schema';


service MyStoreAnalyticsService {

    /* -------------------------- */
  /* Store Wise Sales */
  /* -------------------------- */
@requires: ['Owner']
  entity StoreWiseSales as
    select from db.Orders {
     key store.name   as storeName,
     cast (sum(netPrice) as Decimal(15,2)) as totalSales
    }
    group by store.name;


  /* -------------------------- */
  /* Product Wise Sales */
  /* -------------------------- */
@requires: ['Owner']
  entity ProductWiseSales as
    select from db.OrderItems {
     key product.name  as productName,
     cast( sum(quantity)   as Integer )        as totalQuantity,
      cast( sum(totalPrice) as Decimal(15,2) )  as totalSales
    }
    group by product.name;

}

