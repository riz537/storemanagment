sap.ui.define([
    "sap/ui/core/mvc/Controller"
], (Controller) => {
    "use strict";

    return Controller.extend("com.demo.mystoreanalytics.controller.View1", {
        onInit() {
            var oVizFrame = this.getView().byId("idVizFrame");
			oVizFrame.setVizProperties({
				plotArea: {
					dataLabel: {
						visible: true,
						type: "value"
					}
				},
				title: {
					visible: true,
					text: "Store wise sales"
				},
				valueAxis: {
					title: {
						visible: true,
						text: "Sales"
					}
				},
				categoryAxis: {
					title: {
						visible: true,
						text: "Stores"
					}
				}
			});

            var oVizFrame2 = this.getView().byId("idVizFrame2");
			oVizFrame2.setVizProperties({
				plotArea: {
					dataLabel: {
						visible: true,
						type: "value"
					}
				},
				title: {
					visible: true,
					text: "Product wise sales"
				},
				valueAxis: {
					title: {
						visible: true,
						text: "Product wise sales and quantity"
					}
				},
				categoryAxis: {
					title: {
						visible: true,
						text: "Products"
					}
				}
			});
        }
    });
});