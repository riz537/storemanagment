const cds = require('@sap/cds')

module.exports = class MyStoreService extends cds.ApplicationService { init() {

  const { Products } = cds.entities('MyStoreService')

  this.before (['CREATE', 'UPDATE'], Products, async (req) => {
    console.log('Before CREATE/UPDATE Products', req.data)
  })
  this.after ('READ', Products, async (products, req) => {
    
  })
  this.on("ApplyDiscount",async req=>{
    const id = req.params[0].ID;   // single selected row
  const discount = req.data.discount;
    await UPDATE(Products)
      .set({ discount: discount })
      .where({ ID: id });

    req.info (`Discount ${discount}% applied successfully`);
   });


  return super.init()
}}
