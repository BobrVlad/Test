CLASS lhc_Task DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Task RESULT result.

    METHODS completeTask FOR MODIFY
      IMPORTING keys FOR ACTION Task~completeTask RESULT result.

    METHODS checkTaskEstimation FOR VALIDATE ON SAVE
      IMPORTING keys FOR Task~checkTaskEstimation.

ENDCLASS.

CLASS lhc_Task IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD completeTask.

    MODIFY ENTITIES OF ZBUV_I_ProjectActive_TP IN LOCAL MODE
      ENTITY Task
        UPDATE
          FIELDS ( TaskStatus )
          WITH VALUE #( FOR key IN keys
                          ( %key = key-%key
                            TaskStatus = 'DN' ) )
    FAILED   failed
    REPORTED reported.

    READ ENTITIES OF ZBUV_I_ProjectActive_TP IN LOCAL MODE
      ENTITY Task
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_tasks).

    result = VALUE #( FOR ls_task IN lt_tasks
                        ( %tky   = ls_task-%tky
                          %param = ls_task ) ).

  ENDMETHOD.

  METHOD checkTaskEstimation.

   READ ENTITIES OF ZBUV_I_ProjectActive_TP IN LOCAL MODE
      ENTITY Task
        FIELDS ( TaskEstimation )
          WITH CORRESPONDING #( keys )
    RESULT DATA(lt_tasks).

    DATA(ls_task) = lt_tasks[ 1 ].

    CHECK ls_task-taskestimation NOT BETWEEN 0 AND 5.

*    APPEND VALUE #( %tky        = ls_task-%tky
*                    %state_area = 'checkTaskEstimation' )
*       TO reported-task.

    APPEND VALUE #( %tky = ls_task-%tky )
       TO failed-task.

    APPEND VALUE #( %tky                    = ls_task-%tky
                    %state_area             = 'checkTaskEstimation'
                    %msg                    = NEW zcm_buv_t100(
                                                  severity = if_abap_behv_message=>severity-error
                                                  textid   = zcm_buv_t100=>incorrect_estimation )
                    %element-TaskEstimation = if_abap_behv=>mk-on )
       TO reported-task.


  ENDMETHOD.

ENDCLASS.
