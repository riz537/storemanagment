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
    // this.before('READ', Orders, req => {
    //   console.log("inside before read on order");
    //   console.log("printing the user store" + req.user.attr.store[0]);
    //   console.log(req.user.is('Employee') + "<---- is emloyee");
    //   if (req.user.is('Employee')) {
    //     const store = req.user.attr.store[0];

    //     req.query.where({ store_name: store });
    //   }
    // });
    
    this.before('CREATE', Orders.drafts, async req => {
      const stores = Array.isArray(req.user.attr.store)? req.user.attr.store: [req.user.attr.store];
      console.log("inside before create on order in draft");
      console.log("printing the user stores" + stores);
      req.data.store_name = stores[0];
    });
    //calculate totalprice, netprice
    this.after('PATCH', OrderItems.drafts, async (data, req) => {
      const { ID } = data;

      // 1. Fetch current draft state (to get both Quantity and UnitPrice)
      const draftItem = await SELECT.one.from(OrderItems.drafts).where({ ID });

      if (draftItem) {
        var totalPrice = (draftItem.quantity || 0) * (draftItem.unitPrice || 0);
        if (draftItem.discount > 0) {
          totalPrice = totalPrice - (totalPrice * draftItem.discount / 100);
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
    //calculate totalprice, netprice on delete of items
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

    // reduce stock when an order is placed
    this.before('CREATE', Orders, async (req) => {
      const items = req.data.items || [];
      if (!items.length) return;
      for (const item of items) {
        const productID = item.product_ID;
        // Read product
        const product = await SELECT.one.from(Products).where({ ID: productID });
        if (!product) {
          return req.error(400, `Product not found: ${productID}`);
        }
        const currentStock = product.stock;
        const orderQty = item.quantity;
        // Validate stock
        if (currentStock < orderQty) {
          return req.error(
            400,
            `Insufficient stock for product ${productID}. Available: ${currentStock}`
          );
        }
        // Reduce stock
        await UPDATE(Products).set({ stock: currentStock - orderQty }).where({ ID: productID })
      }
    });
    //read coniguration singleton entity
    this.on('READ', 'Configuration', async req => {
      req.reply({
        isOwner: req.user.is('Owner') //admin is the role, which for example is also used in @requires annotation
      });
    });

    return super.init()
  }
}
