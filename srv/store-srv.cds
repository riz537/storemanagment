using {mystore.db as db} from '../db/schema';

service MyStoreService {
            @odata.draft.enabled
    entity Products @(restrict: [
        {
            grant: ['*'],
            to   : 'Owner'
        },
        {
            grant: ['READ'],
            to   : 'Employee'
        }
    ])                      as
        projection on db.Products {
            *,
            case
                when stock = 0
                     then 'Out of Stock'
                when stock < 5
                     then 'Low Stock'
                else 'In Stock'
            end as status            : String(20),

            case
                when stock = 0
                     then 1
                when stock < 5
                     then 2
                else 3
            end as statusCriticality : Integer

        }

        actions {
            @Common.SideEffects: {TargetProperties: ['discount']}
            @requires          : 'Owner'
            action ApplyDiscount(discount: Integer  @Common.Label: 'Apply Discount'  @assert.range: [
                1,
                100
            ]  ) returns String;


            @Common.SideEffects: {TargetProperties: ['stock','status']}
            @requires          : 'Owner'
            action AddStock(stock: Integer  @Common.Label: 'Add Stock'  @assert.range: [
                1,
                100
            ]
            )    returns String;
        };

    @odata.singleton  @cds.persistence.skip
    entity Configuration {
        key ID      : String;
            isOwner : Boolean;
    }

    @requires: [
        'Owner',
        'Employee'
    ]
    @odata.draft.enabled
    entity Orders           as projection on db.Orders;

    @requires: [
        'Owner',
        'Employee'
    ]
    entity OrderItems       as projection on db.OrderItems;

    @requires: [
        'Owner',
        'Employee'
    ]
    entity Stores           as projection on db.Stores;


   

}
