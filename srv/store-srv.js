const cds = require('@sap/cds')

module.exports = class MyStoreService extends cds.ApplicationService {
  init() {

    const { Products, Configuration, Orders, OrderItems } = cds.entities('MyStoreService')

    //apply discount
    this.on("ApplyDiscount", async req => {
      const id = req.params[0].ID;   // single selected row
      const discount = req.data.discount;
      await UPDATE(Products)
        .set({ discount: discount })
        .where({ ID: id });

      req.info(`Discount ${discount}% applied successfully`);
    });
    // add stock
    this.on("AddStock", async req => {
      const id = req.params[0].ID;   // single selected row
      const newStock = req.data.stock;
      await UPDATE(Products)
        .set({ stock: { '+=': newStock } })
        .where({ ID: id });

      req.info(`Stock ${newStock} added successfully`);
    });
    /* -------------------------------- */
    /* Worker sees only his own store orders */
    /* -------------------------------- */
    this.before('READ', Orders, req => {
      if (req.user.is('Worker')) {
        const store = req.user.attr.store;
        req.query.where({ store_name: store });
      }
    });
    
      this.after('PATCH', OrderItems.drafts, async (data, req) => {
        const { ID } = data;

        // 1. Fetch current draft state (to get both Quantity and UnitPrice)
        const draftItem = await SELECT.one.from(OrderItems.drafts).where({ ID });
        
        if (draftItem) {
            var totalPrice = (draftItem.quantity || 0) * (draftItem.unitPrice || 0);
            if(draftItem.discount>0){
              totalPrice = totalPrice - (totalPrice*draftItem.discount/100);
            }
            

            // 2. Update the Item Total Price in the draft table
            await UPDATE(OrderItems.drafts).set({ totalPrice: totalPrice }).where({ ID });

            // 3. Roll up to Order NetPrice (Header)
            if (draftItem.order_ID) {
                const allDraftItems = await SELECT.from(OrderItems.drafts)
                                            .where({ order_ID: draftItem.order_ID });
                
                const netPrice = allDraftItems.reduce((sum, item) => 
                    sum + Number(item.totalPrice), 0);
                
                // Update the Orders draft table
                await UPDATE(Orders.drafts) // Use your actual draft table name
                        .set({ netPrice: netPrice })
                        .where({ ID: draftItem.order_ID });
            }
        }
    });
    this.before('DELETE', OrderItems.drafts, async (req) => {
            // 1. Get the parent Order ID before the item is deleted
            // req.subject points to the specific record being deleted
            const orderID = req.data.order_ID;
            
            if (orderID) {
                // 2. Register a 'succeeded' hook
                // This ensures the calculation runs AFTER the record is gone from the DB
                req.on('succeeded', async () => {
                    // 3. Aggregate total prices of remaining items
                    const remainingItems = await SELECT.from(OrderItems.drafts)
                        .where({ order_ID: orderID });

                    const newNetPrice = remainingItems.reduce((acc, curr) => {
                        return acc + Number(curr.totalPrice);
                    }, 0);

                    // 4. Update the parent Order draft
                   await UPDATE(Orders.drafts) // Use your actual draft table name
                        .set({ netPrice: newNetPrice })
                        .where({ ID: orderID });
                });
            }
        });

   // this.before('PATCH', Orders.drafts, async (req) => {
     // const store = req.user.attr.store;
      //const items = req.data.items || [];
      //let netPrice = 0;
      // for (const item of items) {
      //   // 1. Read product price
      //   const product = await SELECT.one
      //     .from(Products)
      //     .where({ ID: item.product_ID });

      //   if (!product) {
      //     req.error(400, `Invalid product ${item.product_ID}`);
      //   }

      //   // 2. Calculate item unit price & total
      //   item.unitPrice = product.price;
      //   item.totalPrice = (product.price - (product.price * product.discount / 100)) * item.quantity ;
        

      //   // 3. Add to order net price
      //   netPrice += item.totalPrice;
      // }

      // // 4. Set header net price
      // req.data.netPrice = netPrice;
      // req.data.store_name = store;

    //});



    //read coniguration singleton entity
    this.on('READ', 'Configuration', async req => {
      req.reply({
        isOwner: req.user.is('Owner') //admin is the role, which for example is also used in @requires annotation
      });
    });

    return super.init()
  }
}
