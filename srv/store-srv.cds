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
    ]) as
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
        };

    @odata.singleton  @cds.persistence.skip
    @Common.SideEffects: {TargetProperties: ['isOwner']}
    entity Configuration {
        key ID      : String;
            isOwner : Boolean;
    }


}
