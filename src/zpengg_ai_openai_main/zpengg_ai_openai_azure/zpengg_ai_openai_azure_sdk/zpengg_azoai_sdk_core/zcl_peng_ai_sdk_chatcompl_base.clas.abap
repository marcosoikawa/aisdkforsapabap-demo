*****************************************************************************************************************
* Class          : ZCL_PENG_AI_SDK_CHATCOMPL_BASE
* Created by     : GONAIR (Gopal Nair)
* Date           : May 7, 2023
*-------------------------------------------------------------------------------------------------------------
* Description
*-------------------------------------------------------------------------------------------------------------
* Base class for Chat Completion components in AI SDK for SAP ABAP.
* This abstract base class provides the foundation for chat completion operations across different AI engines.
* It inherits from zcl_peng_azoai_sdk_component and implements zif_peng_ai_sdk_comp_chatcompl interface.
* 
* The class provides a default implementation that raises "not implemented" exceptions, allowing subclasses
* to override specific methods as needed for their particular AI engine implementations.
*-------------------------------------------------------------------------------------------------------------
*                       Modification History
*-------------------------------------------------------------------------------------------------------------
* May 7, 2023 // GONAIR // Initial Version
*****************************************************************************************************************
CLASS zcl_peng_ai_sdk_chatcompl_base DEFINITION
  PUBLIC
  INHERITING FROM zcl_peng_azoai_sdk_component
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_peng_ai_sdk_comp_chatcompl.
    METHODS constructor.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



*****************************************************************************************************************
* CLASS IMPLEMENTATION
*****************************************************************************************************************
CLASS zcl_peng_ai_sdk_chatcompl_base IMPLEMENTATION.

  METHOD constructor.
*****************************************************************************************************************
* Class          : ZCL_PENG_AI_SDK_CHATCOMPL_BASE
* Method         : constructor
* Created by     : GONAIR (Gopal Nair)
* Date           : May 7, 2023
*-------------------------------------------------------------------------------------------------------------
* Description
*-------------------------------------------------------------------------------------------------------------
* Constructor method for the Chat Completion base component.
* Initializes the component by calling the parent constructor and setting the component type to 
* chat_completions. This ensures proper initialization of the base SDK component infrastructure.
*-------------------------------------------------------------------------------------------------------------
*                       Modification History
*-------------------------------------------------------------------------------------------------------------
* May 7, 2023 // GONAIR // Initial Version
*****************************************************************************************************************

*   Call parent constructor to initialize base SDK component
    super->constructor( ).
    
*   Set component type to chat completions for this specific component
    _component_type = zif_peng_azoai_sdk_constants=>c_component_type-chat_completions.
  ENDMETHOD.



  METHOD zif_peng_ai_sdk_comp_chatcompl~create.
*****************************************************************************************************************
* Class          : ZCL_PENG_AI_SDK_CHATCOMPL_BASE
* Method         : zif_peng_ai_sdk_comp_chatcompl~create
* Created by     : GONAIR (Gopal Nair)
* Date           : May 7, 2023
*-------------------------------------------------------------------------------------------------------------
* Description
*-------------------------------------------------------------------------------------------------------------
* This method implementation will only be triggered if sub-classes did not override the create method. This
* can happen if the underlying AI engine does not support completion create operation.
*-------------------------------------------------------------------------------------------------------------
*                       Modification History
*-------------------------------------------------------------------------------------------------------------
* May 7, 2023 // GONAIR // Initial Version
*****************************************************************************************************************

*   Raise not implemented exception since this base class should be overridden by subclasses
    _not_implemented( ).
  ENDMETHOD.

ENDCLASS.
