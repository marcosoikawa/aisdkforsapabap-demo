# Exemplos Avançados - ZPENGG_AZOAI_SDK_CORE

## 🎯 Casos de Uso Empresariais Avançados

Esta documentação apresenta exemplos avançados e casos de uso reais para integração de IA em processos SAP.

## 📊 1. Análise Inteligente de Documentos SAP

### Analisador de Ordens de Compra

```abap
REPORT z_ai_purchase_order_analyzer.

TYPES: BEGIN OF ty_po_analysis,
         po_number     TYPE ebeln,
         vendor        TYPE lifnr,
         total_value   TYPE bprei,
         risk_score    TYPE string,
         recommendations TYPE string,
         compliance_status TYPE string,
       END OF ty_po_analysis.

DATA: po_analysis TYPE STANDARD TABLE OF ty_po_analysis.

PARAMETERS: p_ebeln TYPE ebeln OBLIGATORY.

START-OF-SELECTION.
  PERFORM analyze_purchase_order USING p_ebeln.

FORM analyze_purchase_order USING p_po_number TYPE ebeln.
  DATA: sdk TYPE REF TO zif_peng_azoai_sdk,
        po_data TYPE string,
        input TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_input,
        output TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_output.

  " 1. Buscar dados da ordem de compra
  PERFORM get_po_data USING p_po_number CHANGING po_data.

  " 2. Inicializar SDK
  TRY.
    sdk = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
      api_version = '2023-05-15'
      api_base    = 'https://seu-recurso.openai.azure.com'
      api_type    = zif_peng_azoai_sdk_constants=>c_apitype-azure
      api_key     = 'SUA_CHAVE'
    ).

    " 3. Configurar prompt para análise
    APPEND VALUE #( 
      role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-system
      content = |Você é um especialista em análise de compras corporativas. |
             && |Analise a ordem de compra e forneça: |
             && |1. Score de risco (0-100) |
             && |2. Recomendações de melhoria |
             && |3. Status de conformidade |
             && |4. Pontos de atenção |
             && |Formate a resposta em JSON estruturado.|
    ) TO input-messages.

    APPEND VALUE #( 
      role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-user
      content = |Dados da Ordem de Compra: { po_data }|
    ) TO input-messages.

    " 4. Configurar parâmetros
    input-temperature = '0.2'.  " Baixo para análise precisa
    input-max_tokens = 1500.

    " 5. Fazer análise
    sdk->chat_completions( )->create(
      EXPORTING
        deploymentid = 'gpt-4'
        prompts      = input
      IMPORTING
        response     = output
    ).

    " 6. Processar resultado
    DATA(analise_json) = output-choices[ 1 ]-message-content.
    PERFORM process_analysis_result USING analise_json p_po_number.

  CATCH zcx_peng_azoai_sdk_exception INTO DATA(ex).
    MESSAGE ex TYPE 'E'.
  ENDTRY.
ENDFORM.

FORM get_po_data USING p_po_number TYPE ebeln 
                 CHANGING p_data TYPE string.
  " Buscar dados da PO de várias tabelas
  DATA: header TYPE ekko,
        items TYPE STANDARD TABLE OF ekpo,
        vendor TYPE lfa1.

  SELECT SINGLE * FROM ekko INTO header WHERE ebeln = p_po_number.
  SELECT * FROM ekpo INTO TABLE items WHERE ebeln = p_po_number.
  SELECT SINGLE * FROM lfa1 INTO vendor WHERE lifnr = header-lifnr.

  " Converter para JSON estruturado
  p_data = |{{ |
        && |"po_number": "{ header-ebeln }", |
        && |"vendor": "{ vendor-name1 }", |
        && |"total_value": { header-gesamtwert }, |
        && |"currency": "{ header-waers }", |
        && |"creation_date": "{ header-aedat }", |
        && |"items_count": { lines( items ) }, |
        && |"company_code": "{ header-bukrs }" |
        && |}|.
ENDFORM.
```

## 🔍 2. Assistente Inteligente para Debugging ABAP

```abap
REPORT z_ai_debug_assistant.

PARAMETERS: 
  p_code TYPE string OBLIGATORY,
  p_error TYPE string OBLIGATORY.

START-OF-SELECTION.
  PERFORM analyze_error USING p_code p_error.

FORM analyze_error USING p_code TYPE string p_error TYPE string.
  DATA: sdk TYPE REF TO zif_peng_azoai_sdk,
        input TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_input,
        output TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_output.

  TRY.
    sdk = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
      api_version = '2023-05-15'
      api_base    = 'https://seu-recurso.openai.azure.com'
      api_type    = zif_peng_azoai_sdk_constants=>c_apitype-azure
      api_key     = 'SUA_CHAVE'
    ).

    " Sistema especializado em debugging ABAP
    APPEND VALUE #( 
      role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-system
      content = |Você é um especialista em debugging ABAP com 20 anos de experiência. |
             && |Para cada erro, forneça: |
             && |1. Causa raiz provável |
             && |2. Solução específica com código |
             && |3. Prevenção para o futuro |
             && |4. Boas práticas relacionadas |
             && |Use sintaxe ABAP moderna quando possível.|
    ) TO input-messages.

    APPEND VALUE #( 
      role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-user
      content = |CÓDIGO COM ERRO: |
             && |{ p_code } |
             && | |
             && |MENSAGEM DE ERRO: |
             && |{ p_error }|
    ) TO input-messages.

    input-temperature = '0.1'.  " Máxima precisão
    input-max_tokens = 2000.

    sdk->chat_completions( )->create(
      EXPORTING
        deploymentid = 'gpt-4'
        prompts      = input
      IMPORTING
        response     = output
    ).

    " Exibir análise formatada
    cl_demo_output=>display_html( 
      html = |<h2>Análise de Debug - ABAP</h2>|
          && |<pre>{ output-choices[ 1 ]-message-content }</pre>|
    ).

  CATCH zcx_peng_azoai_sdk_exception INTO DATA(ex).
    MESSAGE ex TYPE 'E'.
  ENDTRY.
ENDFORM.
```

## 📈 3. Gerador de Relatórios Executivos

```abap
REPORT z_ai_executive_reports.

TYPES: BEGIN OF ty_sales_data,
         period TYPE string,
         revenue TYPE p LENGTH 16 DECIMALS 2,
         orders TYPE i,
         customers TYPE i,
         top_product TYPE string,
       END OF ty_sales_data.

DATA: sales_data TYPE STANDARD TABLE OF ty_sales_data.

PARAMETERS: 
  p_year TYPE numc4 OBLIGATORY DEFAULT sy-datum(4),
  p_month TYPE numc2 OBLIGATORY DEFAULT sy-datum+4(2).

START-OF-SELECTION.
  PERFORM generate_executive_report USING p_year p_month.

FORM generate_executive_report USING p_year TYPE numc4 p_month TYPE numc2.
  DATA: sdk TYPE REF TO zif_peng_azoai_sdk,
        business_data TYPE string,
        input TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_input,
        output TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_output.

  " 1. Coletar dados do negócio
  PERFORM collect_business_data USING p_year p_month CHANGING business_data.

  TRY.
    " 2. Inicializar SDK
    sdk = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
      api_version = '2023-05-15'
      api_base    = 'https://seu-recurso.openai.azure.com'
      api_type    = zif_peng_azoai_sdk_constants=>c_apitype-azure
      api_key     = 'SUA_CHAVE'
    ).

    " 3. Configurar prompt para relatório executivo
    APPEND VALUE #( 
      role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-system
      content = |Você é um consultor de negócios sênior especializado em análise de dados. |
             && |Crie um relatório executivo profissional com: |
             && |1. Resumo Executivo (principais insights) |
             && |2. Análise de Performance |
             && |3. Tendências Identificadas |
             && |4. Recomendações Estratégicas |
             && |5. Próximos Passos |
             && |Use linguagem executiva e formate em HTML para apresentação.|
    ) TO input-messages.

    APPEND VALUE #( 
      role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-user
      content = |Dados do período { p_month }/{ p_year }: |
             && |{ business_data }|
    ) TO input-messages.

    input-temperature = '0.3'.  " Balanceado para insights criativos
    input-max_tokens = 3000.

    " 4. Gerar relatório
    sdk->chat_completions( )->create(
      EXPORTING
        deploymentid = 'gpt-4'
        prompts      = input
      IMPORTING
        response     = output
    ).

    " 5. Salvar e exibir relatório
    DATA(relatorio_html) = output-choices[ 1 ]-message-content.
    
    " Salvar em arquivo
    PERFORM save_report_to_file USING relatorio_html p_year p_month.
    
    " Exibir na tela
    cl_demo_output=>display_html( html = relatorio_html ).

  CATCH zcx_peng_azoai_sdk_exception INTO DATA(ex).
    MESSAGE ex TYPE 'E'.
  ENDTRY.
ENDFORM.

FORM collect_business_data USING p_year TYPE numc4 p_month TYPE numc2
                          CHANGING p_data TYPE string.
  " Simular coleta de dados de vendas
  DATA: total_revenue TYPE p LENGTH 16 DECIMALS 2 VALUE 1500000,
        total_orders TYPE i VALUE 2500,
        new_customers TYPE i VALUE 150,
        top_product TYPE string VALUE 'Produto Premium X'.

  p_data = |{{ |
        && |"revenue": { total_revenue }, |
        && |"orders": { total_orders }, |
        && |"new_customers": { new_customers }, |
        && |"top_product": "{ top_product }", |
        && |"period": "{ p_month }/{ p_year }", |
        && |"growth_vs_previous": "12.5%", |
        && |"customer_satisfaction": "4.2/5.0" |
        && |}|.
ENDFORM.
```

## 🤖 4. Chatbot Integrado para Suporte SAP

```abap
REPORT z_sap_support_chatbot.

" Tela de chat interativo
SELECTION-SCREEN BEGIN OF SCREEN 1000.
SELECTION-SCREEN BEGIN OF BLOCK chat WITH FRAME TITLE TEXT-001.
PARAMETERS: p_quest TYPE string LOWER CASE.
SELECTION-SCREEN END OF BLOCK chat.
SELECTION-SCREEN END OF SCREEN 1000.

DATA: chat_history TYPE STANDARD TABLE OF string,
      sdk TYPE REF TO zif_peng_azoai_sdk.

INITIALIZATION.
  " Inicializar SDK no início
  TRY.
    sdk = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
      api_version = '2023-05-15'
      api_base    = 'https://seu-recurso.openai.azure.com'
      api_type    = zif_peng_azoai_sdk_constants=>c_apitype-azure
      api_key     = 'SUA_CHAVE'
    ).
  CATCH zcx_peng_azoai_sdk_exception INTO DATA(ex).
    MESSAGE ex TYPE 'E'.
  ENDTRY.

START-OF-SELECTION.
  CALL SCREEN 1000.

MODULE user_command_1000 INPUT.
  CASE sy-ucomm.
    WHEN 'SEND'.
      PERFORM process_chat_message USING p_quest.
      CLEAR p_quest.
    WHEN 'CLEAR'.
      CLEAR: chat_history, p_quest.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.

FORM process_chat_message USING p_message TYPE string.
  DATA: input TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_input,
        output TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_output,
        context TYPE string.

  TRY.
    " Adicionar pergunta ao histórico
    APPEND |Usuário: { p_message }| TO chat_history.

    " Construir contexto da conversa
    LOOP AT chat_history INTO DATA(linha).
      context = |{ context }{ linha }{ cl_abap_char_utilities=>newline }|.
    ENDLOOP.

    " Configurar prompt especializado em SAP
    APPEND VALUE #( 
      role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-system
      content = |Você é um consultor SAP sênior especializado em: |
             && |- Módulos SAP (FI, CO, MM, SD, HR, etc.) |
             && |- Desenvolvimento ABAP |
             && |- Configuração e parametrização |
             && |- Troubleshooting |
             && |- Boas práticas SAP |
             && |Forneça respostas precisas, práticas e sempre indique |
             && |transações relevantes quando aplicável.|
    ) TO input-messages.

    APPEND VALUE #( 
      role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-user
      content = |Histórico da conversa: |
             && |{ context } |
             && | |
             && |Nova pergunta: { p_message }|
    ) TO input-messages.

    input-temperature = '0.4'.
    input-max_tokens = 1000.

    " Processar com IA
    sdk->chat_completions( )->create(
      EXPORTING
        deploymentid = 'gpt-4'
        prompts      = input
      IMPORTING
        response     = output
    ).

    " Adicionar resposta ao histórico
    DATA(resposta) = output-choices[ 1 ]-message-content.
    APPEND |Assistente: { resposta }| TO chat_history.

    " Exibir conversa atualizada
    PERFORM display_chat_history.

  CATCH zcx_peng_azoai_sdk_exception INTO DATA(ex).
    MESSAGE ex TYPE 'E'.
  ENDTRY.
ENDFORM.

FORM display_chat_history.
  DATA: html_content TYPE string.
  
  html_content = |<div style="font-family: Arial; padding: 10px;">|.
  html_content = |{ html_content }<h3>Conversa com Assistente SAP</h3>|.
  
  LOOP AT chat_history INTO DATA(linha).
    IF linha CS 'Usuário:'.
      html_content = |{ html_content }<div style="background: #e3f2fd; padding: 8px; margin: 5px; border-radius: 5px;">|.
      html_content = |{ html_content }<strong>{ linha }</strong></div>|.
    ELSE.
      html_content = |{ html_content }<div style="background: #f3e5f5; padding: 8px; margin: 5px; border-radius: 5px;">|.
      html_content = |{ html_content }{ linha }</div>|.
    ENDIF.
  ENDLOOP.
  
  html_content = |{ html_content }</div>|.
  
  cl_demo_output=>display_html( html = html_content ).
ENDFORM.
```

## 📝 5. Gerador Automático de Código ABAP

```abap
REPORT z_ai_code_generator.

PARAMETERS: 
  p_req TYPE string OBLIGATORY,
  p_type TYPE string OBLIGATORY DEFAULT 'REPORT'.

SELECTION-SCREEN BEGIN OF BLOCK options WITH FRAME TITLE TEXT-002.
PARAMETERS: 
  p_modern AS CHECKBOX DEFAULT 'X',
  p_comment AS CHECKBOX DEFAULT 'X',
  p_error AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK options.

START-OF-SELECTION.
  PERFORM generate_abap_code USING p_req p_type.

FORM generate_abap_code USING p_requirement TYPE string p_type TYPE string.
  DATA: sdk TYPE REF TO zif_peng_azoai_sdk,
        input TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_input,
        output TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_output,
        system_prompt TYPE string.

  " Construir prompt do sistema baseado nas opções
  system_prompt = |Você é um especialista ABAP com mais de 15 anos de experiência. |
               && |Gere código ABAP limpo, eficiente e bem estruturado.|.

  IF p_modern = 'X'.
    system_prompt = |{ system_prompt } Use sintaxe ABAP moderna (7.4+) sempre que possível.|.
  ENDIF.

  IF p_comment = 'X'.
    system_prompt = |{ system_prompt } Inclua comentários detalhados explicando a lógica.|.
  ENDIF.

  IF p_error = 'X'.
    system_prompt = |{ system_prompt } Inclua tratamento robusto de erros.|.
  ENDIF.

  TRY.
    sdk = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
      api_version = '2023-05-15'
      api_base    = 'https://seu-recurso.openai.azure.com'
      api_type    = zif_peng_azoai_sdk_constants=>c_apitype-azure
      api_key     = 'SUA_CHAVE'
    ).

    APPEND VALUE #( 
      role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-system
      content = system_prompt
    ) TO input-messages.

    APPEND VALUE #( 
      role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-user
      content = |Crie um { p_type } ABAP que: { p_requirement }|
    ) TO input-messages.

    input-temperature = '0.2'.  " Código precisa ser consistente
    input-max_tokens = 3000.

    sdk->chat_completions( )->create(
      EXPORTING
        deploymentid = 'gpt-4'
        prompts      = input
      IMPORTING
        response     = output
    ).

    " Extrair e formatar código
    DATA(codigo_gerado) = output-choices[ 1 ]-message-content.
    
    " Salvar código em arquivo
    PERFORM save_generated_code USING codigo_gerado p_type.
    
    " Exibir código formatado
    cl_demo_output=>display_text( 
      text = |Código ABAP Gerado:{ cl_abap_char_utilities=>newline }|
          && |{ cl_abap_char_utilities=>newline }{ codigo_gerado }|
    ).

  CATCH zcx_peng_azoai_sdk_exception INTO DATA(ex).
    MESSAGE ex TYPE 'E'.
  ENDTRY.
ENDFORM.

FORM save_generated_code USING p_code TYPE string p_type TYPE string.
  " Implementar salvamento do código gerado
  " Pode salvar em arquivo local ou no repositório
ENDFORM.
```

## 🔧 6. Utilitários de Suporte

### Classe Helper para Casos Avançados

```abap
CLASS zcl_ai_advanced_helper DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS:
      " Análise de performance de código
      analyze_performance
        IMPORTING code TYPE string
        RETURNING VALUE(analysis) TYPE string,
      
      " Sugestões de otimização
      suggest_optimizations
        IMPORTING code TYPE string
        RETURNING VALUE(suggestions) TYPE string,
      
      " Validação de código
      validate_code_quality
        IMPORTING code TYPE string
        RETURNING VALUE(quality_report) TYPE string,
      
      " Geração de testes unitários
      generate_unit_tests
        IMPORTING code TYPE string
        RETURNING VALUE(test_code) TYPE string.

  PRIVATE SECTION.
    CLASS-DATA: sdk TYPE REF TO zif_peng_azoai_sdk.
    
    CLASS-METHODS:
      get_sdk_instance
        RETURNING VALUE(sdk_ref) TYPE REF TO zif_peng_azoai_sdk.
ENDCLASS.

CLASS zcl_ai_advanced_helper IMPLEMENTATION.
  METHOD get_sdk_instance.
    IF sdk IS INITIAL.
      TRY.
        sdk = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
          api_version = '2023-05-15'
          api_base    = 'https://seu-recurso.openai.azure.com'
          api_type    = zif_peng_azoai_sdk_constants=>c_apitype-azure
          api_key     = 'SUA_CHAVE'
        ).
      CATCH zcx_peng_azoai_sdk_exception.
        " Log error
      ENDTRY.
    ENDIF.
    sdk_ref = sdk.
  ENDMETHOD.

  METHOD analyze_performance.
    DATA: input TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_input,
          output TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_output.

    TRY.
      DATA(sdk_ref) = get_sdk_instance( ).

      APPEND VALUE #( 
        role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-system
        content = |Analise o código ABAP quanto à performance. Identifique: |
               && |1. Gargalos potenciais |
               && |2. Uso ineficiente de recursos |
               && |3. Consultas SQL otimizáveis |
               && |4. Loops que podem ser melhorados |
               && |5. Score de performance (1-10)|
      ) TO input-messages.

      APPEND VALUE #( 
        role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-user
        content = |Código para análise: { code }|
      ) TO input-messages.

      input-temperature = '0.1'.
      input-max_tokens = 1500.

      sdk_ref->chat_completions( )->create(
        EXPORTING
          deploymentid = 'gpt-4'
          prompts      = input
        IMPORTING
          response     = output
      ).

      analysis = output-choices[ 1 ]-message-content.

    CATCH zcx_peng_azoai_sdk_exception.
      analysis = 'Erro na análise de performance'.
    ENDTRY.
  ENDMETHOD.

  METHOD generate_unit_tests.
    " Implementação similar para geração de testes unitários
  ENDMETHOD.
ENDCLASS.
```

## 📋 Checklist para Implementação

### ✅ Antes de Implementar
- [ ] Configurar recurso Azure OpenAI
- [ ] Obter chaves de API e endpoints
- [ ] Configurar conectividade SAP
- [ ] Definir políticas de segurança
- [ ] Estabelecer limites de uso

### ✅ Durante Implementação
- [ ] Implementar tratamento de erros robusto
- [ ] Configurar logs de auditoria
- [ ] Definir timeouts apropriados
- [ ] Implementar retry com backoff
- [ ] Validar entrada do usuário

### ✅ Após Implementação
- [ ] Testar com diferentes cenários
- [ ] Monitorar uso de tokens
- [ ] Validar performance
- [ ] Treinar usuários
- [ ] Documentar processo

---

**Nota**: Todos os exemplos devem ser adaptados para seus requisitos específicos e ambiente SAP. Sempre teste em ambiente de desenvolvimento antes de implementar em produção.

*Exemplos desenvolvidos por Microsoft Platform Engineering Team*