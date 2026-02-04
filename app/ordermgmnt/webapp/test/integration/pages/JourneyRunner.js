sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"com/demo/ordermgmnt/test/integration/pages/OrdersList",
	"com/demo/ordermgmnt/test/integration/pages/OrdersObjectPage",
	"com/demo/ordermgmnt/test/integration/pages/OrderItemsObjectPage"
], function (JourneyRunner, OrdersList, OrdersObjectPage, OrderItemsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('com/demo/ordermgmnt') + '/test/flp.html#app-preview',
        pages: {
			onTheOrdersList: OrdersList,
			onTheOrdersObjectPage: OrdersObjectPage,
			onTheOrderItemsObjectPage: OrderItemsObjectPage
        },
        async: true
    });

    return runner;
});

