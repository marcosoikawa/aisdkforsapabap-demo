# ZPENGG_AZOAI_SDK_CORE - Guia de Início Rápido

## 🚀 Primeiros Passos

Este guia irá ajudá-lo a começar rapidamente com o Azure OpenAI SDK para SAP ABAP.

### Pré-requisitos

1. **Acesso ao Azure OpenAI Service**
   - Recurso Azure OpenAI provisionado
   - Chave de API ou autenticação Azure AD
   - Endpoint do serviço

2. **Ambiente SAP**
   - Sistema SAP ABAP (ECC 6.0+ ou S/4HANA)
   - Authorização para criar/executar programas ABAP
   - Conectividade HTTP habilitada

3. **Modelo Implantado**
   - Pelo menos um modelo implantado no Azure OpenAI (ex: gpt-35-turbo, gpt-4)

### Passo 1: Verificar Instalação

Execute este código para verificar se o SDK está instalado:

```abap
REPORT z_test_sdk_installation.

TRY.
  DATA(factory) = zcl_peng_azoai_sdk_factory=>get_instance( ).
  MESSAGE 'SDK instalado com sucesso!' TYPE 'S'.
CATCH cx_root INTO DATA(ex).
  MESSAGE |Erro na instalação: { ex->get_text( ) }| TYPE 'E'.
ENDTRY.
```

### Passo 2: Primeiro Chat Completion

```abap
REPORT z_meu_primeiro_chat.

" Parâmetros de entrada
PARAMETERS: 
  p_url   TYPE string OBLIGATORY DEFAULT 'https://seu-recurso.openai.azure.com',
  p_key   TYPE string OBLIGATORY,
  p_depl  TYPE string OBLIGATORY DEFAULT 'gpt-35-turbo',
  p_quest TYPE string OBLIGATORY DEFAULT 'Olá! Como você pode me ajudar?'.

START-OF-SELECTION.
  TRY.
    " 1. Criar instância do SDK
    DATA(sdk) = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
      api_version = '2023-05-15'
      api_base    = p_url
      api_type    = zif_peng_azoai_sdk_constants=>c_apitype-azure
      api_key     = p_key
    ).

    " 2. Preparar entrada para chat
    DATA(input) = VALUE zif_peng_azoai_sdk_types=>ty_chatcompletion_input( ).
    
    APPEND VALUE #( 
      role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-user
      content = p_quest 
    ) TO input-messages.

    " 3. Fazer chamada
    DATA(output) = VALUE zif_peng_azoai_sdk_types=>ty_chatcompletion_output( ).
    DATA: status_code TYPE i.

    sdk->chat_completions( )->create(
      EXPORTING
        deploymentid = p_depl
        prompts      = input
      IMPORTING
        statuscode   = status_code
        response     = output
    ).

    " 4. Verificar resultado
    IF status_code = 200.
      MESSAGE |Resposta: { output-choices[ 1 ]-message-content }| TYPE 'S'.
    ELSE.
      MESSAGE |Erro HTTP: { status_code }| TYPE 'E'.
    ENDIF.

  CATCH zcx_peng_azoai_sdk_exception INTO DATA(ex).
    MESSAGE ex TYPE 'E'.
  ENDTRY.
```

### Passo 3: Listar Modelos Disponíveis

```abap
REPORT z_listar_modelos.

PARAMETERS: 
  p_url TYPE string OBLIGATORY,
  p_key TYPE string OBLIGATORY.

START-OF-SELECTION.
  TRY.
    DATA(sdk) = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
      api_version = '2023-05-15'
      api_base    = p_url
      api_type    = zif_peng_azoai_sdk_constants=>c_apitype-azure
      api_key     = p_key
    ).

    DATA: models TYPE zif_peng_azoai_sdk_types=>ty_model_list,
          status TYPE i.

    sdk->model( )->list(
      IMPORTING
        statuscode = status
        response   = models
    ).

    IF status = 200.
      WRITE: / 'Modelos disponíveis:'.
      LOOP AT models-data INTO DATA(model).
        WRITE: / '- ID:', model-id, 'Status:', model-status.
      ENDLOOP.
    ENDIF.

  CATCH zcx_peng_azoai_sdk_exception INTO DATA(ex).
    MESSAGE ex TYPE 'E'.
  ENDTRY.
```

## 🎯 Casos de Uso Rápidos

### 1. Tradutor de Texto

```abap
DATA(input) = VALUE zif_peng_azoai_sdk_types=>ty_chatcompletion_input( ).

APPEND VALUE #( 
  role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-system
  content = 'Você é um tradutor profissional. Traduza o texto para o português.'
) TO input-messages.

APPEND VALUE #( 
  role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-user
  content = |Traduza: "{ texto_original }"|
) TO input-messages.
```

### 2. Validador de Código ABAP

```abap
APPEND VALUE #( 
  role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-system
  content = 'Você é um especialista em ABAP. Analise o código e sugira melhorias.'
) TO input-messages.

APPEND VALUE #( 
  role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-user
  content = |Analise este código ABAP: { codigo_abap }|
) TO input-messages.
```

### 3. Gerador de Comentários

```abap
APPEND VALUE #( 
  role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-system
  content = 'Gere comentários detalhados para código ABAP seguindo as melhores práticas.'
) TO input-messages.

APPEND VALUE #( 
  role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-user
  content = |Comente este código: { codigo_sem_comentarios }|
) TO input-messages.
```

## ⚙️ Configurações Importantes

### Parâmetros de Temperature

```abap
" Para respostas mais precisas (código, documentação)
input-temperature = '0.1'.

" Para respostas balanceadas
input-temperature = '0.5'.

" Para respostas mais criativas
input-temperature = '0.9'.
```

### Limitação de Tokens

```abap
" Para respostas curtas
input-max_tokens = 150.

" Para respostas médias
input-max_tokens = 500.

" Para respostas longas
input-max_tokens = 2000.
```

## 🛠️ Solução de Problemas

### Erro 401 - Unauthorized
- Verifique se a chave de API está correta
- Confirme se o endpoint está correto
- Verifique se o recurso Azure OpenAI está ativo

### Erro 404 - Not Found
- Confirme se o nome do deployment está correto
- Verifique se o modelo foi implantado corretamente

### Erro 429 - Rate Limit
- Implemente retry com backoff
- Considere usar multiple deployments
- Monitore uso de tokens

### Erro de Conexão
- Verifique conectividade HTTP do SAP
- Confirme configurações de proxy se necessário
- Teste conectividade com CURL ou similar

## 📝 Próximos Passos

1. **Explore os Exemplos**: Execute os programas demo incluídos
2. **Leia a Documentação Completa**: Consulte o documento principal
3. **Experimente Diferentes Modelos**: Teste GPT-3.5, GPT-4, etc.
4. **Integre com Seus Processos**: Incorpore IA em suas aplicações SAP
5. **Monitore Uso**: Acompanhe consumo de tokens e custos

## 🔗 Recursos Úteis

- [Documentação Completa](./ZPENGG_AZOAI_SDK_CORE_DOCUMENTATION.md)
- [Azure OpenAI Documentation](https://docs.microsoft.com/azure/cognitive-services/openai/)
- [SAP Connectivity Guide](https://help.sap.com/connectivity)

---

*Desenvolvido por Microsoft Platform Engineering Team*