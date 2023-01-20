CLASS zcl_fill_d_status DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FILL_D_STATUS IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA:it_status TYPE TABLE OF zbuv_d_status.

*   fill internal table (itab)
    it_status = VALUE #(
        ( client  = '100' statusid = 'NW' statusname = 'New'         )
        ( client  = '100' statusid = 'IN' statusname = 'In Progress' )
        ( client  = '100' statusid = 'DN' statusname = 'Done'        ) ).

*   Delete the possible entries in the database table - in case it was already filled
    DELETE FROM zbuv_d_status.
*   insert the new table entries
    INSERT zbuv_d_status FROM TABLE @it_status.

*   check the result
    SELECT * FROM zbuv_d_status INTO TABLE @it_status.
    out->write( sy-dbcnt ).
    out->write( 'data inserted successfully!').

  ENDMETHOD.
ENDCLASS.
