# Guia de Solução de Problemas - Microsoft AI SDK para SAP ABAP v2.0

## 🆘 Visão Geral

Este documento fornece soluções para problemas comuns encontrados ao usar o Microsoft AI SDK para SAP ABAP v2.0, incluindo troubleshooting, FAQ e dicas de otimização.

---

## 🚨 Problemas Mais Comuns

### 1. 🔐 Problemas de Autenticação

#### ❌ **Erro**: "401 Unauthorized"
```
HTTP Status: 401
Reason: Unauthorized
Message: Access denied due to invalid subscription key
```

**🔍 Diagnóstico:**
```abap
WRITE: / 'Chave API:', p_key.
WRITE: / 'Comprimento:', strlen( p_key ).
WRITE: / 'Formato válido:', COND string( 
  WHEN p_key CS 'sk-' THEN 'OpenAI'
  WHEN strlen( p_key ) = 32 THEN 'Azure OpenAI'
  ELSE 'Formato inválido' ).
```

**✅ Soluções:**

1. **Verificar Chave API**
   ```abap
   " Azure OpenAI - 32 caracteres hexadecimais
   p_key = 'a1b2c3d4e5f6789012345678901234ab'.
   
   " OpenAI - Inicia com 'sk-'
   p_key = 'sk-proj-1234567890abcdef...'.
   ```

2. **Verificar Endpoint Correto**
   ```abap
   " Azure OpenAI
   p_url = 'https://seu-recurso.openai.azure.com/'.
   
   " OpenAI
   p_url = 'https://api.openai.com/v1/'.
   ```

3. **Testar Conectividade**
   ```abap
   REPORT z_teste_auth.
   
   DATA: lo_client TYPE REF TO if_http_client.
   
   CALL METHOD cl_http_client=>create_by_url
     EXPORTING url = 'https://api.openai.com/v1/models'
     IMPORTING client = lo_client.
   
   lo_client->request->set_header_field( 
     name = 'Authorization' 
     value = |Bearer { p_key }| ).
   
   lo_client->send( ).
   lo_client->receive( ).
   
   DATA(lv_status) = lo_client->response->get_status( ).
   IF lv_status-code = 200.
     WRITE: / '✅ Autenticação OK'.
   ELSE.
     WRITE: / '❌ Falha:', lv_status-code, lv_status-reason.
   ENDIF.
   ```

---

### 2. 🌐 Problemas de Conectividade

#### ❌ **Erro**: "SSL Handshake Failed"
```
Error: CSSMERR_SSL_HANDSHAKE_FAILED
Message: SSL handshake with server failed
```

**✅ Soluções:**

1. **Instalar Certificados SSL**
   ```
   Transação: STRUST
   
   Passos:
   1. Expandir "SSL Client SSL Client (Anonymous)"
   2. Importar certificados de:
      - api.openai.com
      - *.openai.azure.com
      - DigiCert Global Root CA
   3. Salvar e ativar
   ```

2. **Testar Certificados**
   ```abap
   REPORT z_teste_ssl.
   
   DATA: lo_client TYPE REF TO if_http_client,
         lv_url TYPE string VALUE 'https://api.openai.com/'.
   
   TRY.
     CALL METHOD cl_http_client=>create_by_url
       EXPORTING url = lv_url
       IMPORTING client = lo_client.
       
     lo_client->send( ).
     WRITE: / '✅ SSL OK'.
     
   CATCH cx_http_dest_provider_error INTO DATA(lx_dest).
     WRITE: / '❌ SSL Error:', lx_dest->get_text( ).
   ENDTRY.
   ```

3. **Configurar Proxy (se necessário)**
   ```
   Transação: SCOT
   
   Configurações:
   - Internet mail configuration
   - SMTP settings
   - Proxy settings para HTTPS
   ```

#### ❌ **Erro**: "Timeout"
```
Error: ICM_HTTP_TIMEOUT
Message: Request timeout after 60 seconds
```

**✅ Soluções:**

1. **Aumentar Timeout**
   ```abap
   " Configurar timeout maior
   lo_http_client->set_timeout( timeout = 120 ). " 2 minutos
   ```

2. **Verificar Profile Parameters**
   ```
   Transação: RZ10
   
   Parâmetros:
   - icm/HTTP/timeout_client = 300
   - icm/HTTP/timeout_server = 300
   ```

---

### 3. 📊 Problemas com Dados

#### ❌ **Erro**: "Invalid JSON in Response"
```
Error: Parsing error in JSON response
Message: Unexpected character at position 15
```

**🔍 Diagnóstico:**
```abap
" Debug da resposta JSON
DATA(lv_json_response) = lo_client->response->get_cdata( ).
WRITE: / 'JSON Response (primeiros 200 chars):'.
WRITE: / lv_json_response(200).

" Verificar status code
DATA(lv_status) = lo_client->response->get_status( ).
WRITE: / 'Status Code:', lv_status-code.
WRITE: / 'Content-Type:', lo_client->response->get_header_field( 'content-type' ).
```

**✅ Soluções:**

1. **Verificar Status Code**
   ```abap
   IF lv_status-code <> 200.
     " Não é JSON válido, é mensagem de erro
     MESSAGE |Erro HTTP: { lv_status-code } - { lv_status-reason }| TYPE 'E'.
     RETURN.
   ENDIF.
   ```

2. **Validar Encoding**
   ```abap
   " Verificar se é UTF-8
   DATA(lv_content_type) = lo_client->response->get_header_field( 'content-type' ).
   IF lv_content_type NS 'utf-8'.
     " Pode ter problema de encoding
   ENDIF.
   ```

#### ❌ **Erro**: "Token Limit Exceeded"
```
Error: Token limit exceeded
Message: Maximum context length is 4096 tokens, requested 5000
```

**✅ Soluções:**

1. **Calcular Tokens**
   ```abap
   " Função estimativa de tokens (1 token ≈ 4 caracteres em inglês)
   FUNCTION z_estimate_tokens.
     IMPORTING iv_text TYPE string
     RETURNING VALUE(rv_tokens) TYPE i.
     
     rv_tokens = strlen( iv_text ) / 4.
     " Adicionar margem de segurança
     rv_tokens = rv_tokens * '1.2'.
   ENDFUNCTION.
   ```

2. **Limitar Entrada**
   ```abap
   " Limitar prompt para evitar overflow
   DATA(lv_max_prompt_tokens) = 3000.
   DATA(lv_estimated_tokens) = z_estimate_tokens( lv_prompt ).
   
   IF lv_estimated_tokens > lv_max_prompt_tokens.
     " Truncar prompt
     DATA(lv_max_chars) = lv_max_prompt_tokens * 4.
     lv_prompt = lv_prompt(lv_max_chars).
     MESSAGE 'Prompt foi truncado devido ao limite de tokens' TYPE 'W'.
   ENDIF.
   ```

3. **Configurar max_tokens**
   ```abap
   ls_input-max_tokens = 1000.  " Limitar resposta
   ```

---

### 4. 🎛️ Problemas de Configuração

#### ❌ **Erro**: "Deployment Not Found"
```
Error: 404 Not Found
Message: The deployment 'gpt-4' was not found
```

**🔍 Diagnóstico:**
```abap
" Listar deployments disponíveis
REPORT z_list_deployments.

" Fazer chamada para listar modelos
sdk_instance->models( )->list(
  IMPORTING
    statuscode = DATA(lv_status)
    response   = DATA(ls_models)
).

IF lv_status = 200.
  LOOP AT ls_models-data INTO DATA(ls_model).
    WRITE: / 'Modelo disponível:', ls_model-id.
  ENDLOOP.
ENDIF.
```

**✅ Soluções:**

1. **Verificar Deployment no Azure**
   - Portal Azure → Seu recurso OpenAI
   - Model deployments
   - Verificar nome exato do deployment

2. **Usar Deployment Correto**
   ```abap
   " Azure OpenAI - usar nome do deployment
   p_deployment = 'gpt-35-turbo-meu-deployment'.
   
   " OpenAI - usar nome do modelo
   p_deployment = 'gpt-3.5-turbo'.
   ```

#### ❌ **Erro**: "Rate Limit Exceeded"
```
Error: 429 Too Many Requests
Message: Rate limit exceeded. Please try again later
```

**✅ Soluções:**

1. **Implementar Retry Logic**
   ```abap
   DATA: lv_retry_count TYPE i VALUE 0,
         lv_max_retries TYPE i VALUE 3.
   
   DO.
     " Fazer chamada
     sdk_instance->chat_completions( )->create(
       EXPORTING
         deploymentid = p_deployment
         prompts      = ls_input
       IMPORTING
         statuscode   = lv_status
         response     = ls_output
     ).
     
     IF lv_status = 200.
       " Sucesso
       EXIT.
     ELSEIF lv_status = 429 AND lv_retry_count < lv_max_retries.
       " Rate limit - aguardar e tentar novamente
       lv_retry_count = lv_retry_count + 1.
       DATA(lv_wait_time) = lv_retry_count * 2.  " Backoff exponencial
       WAIT UP TO lv_wait_time SECONDS.
     ELSE.
       " Outro erro ou limite de tentativas
       EXIT.
     ENDIF.
   ENDDO.
   ```

2. **Monitorar Usage**
   ```abap
   " Salvar estatísticas de uso
   INSERT zaisdk_usage FROM VALUE #(
     datum = sy-datum
     uzeit = sy-uzeit
     user = sy-uname
     tokens = ls_output-usage-total_tokens
     status = lv_status
   ).
   ```

---

## ❓ FAQ (Perguntas Frequentes)

### 📋 Configuração e Instalação

**Q: Qual a diferença entre Azure OpenAI e OpenAI?**

A: 
- **Azure OpenAI**: Serviço gerenciado pela Microsoft, mais seguro para empresa
- **OpenAI**: Serviço direto da OpenAI, mais modelos disponíveis

**Q: Como saber se a instalação foi bem-sucedida?**

A:
```abap
" Teste rápido de instalação
REPORT z_teste_instalacao.

TRY.
  DATA(lo_sdk) = zcl_peng_azoai_sdk_factory=>get_instance( ).
  WRITE: / '✅ Factory OK'.
  
  DATA(lo_instance) = lo_sdk->get_sdk(
    api_version = 'test'
    api_base = 'test'  
    api_type = 'test'
    api_key = 'test'
  ).
  WRITE: / '✅ SDK Instance OK'.
  
CATCH zcx_peng_azoai_sdk_exception INTO DATA(lx_error).
  WRITE: / '❌ Erro:', lx_error->get_text( ).
ENDTRY.
```

### 🔒 Segurança

**Q: É seguro armazenar a chave API no código?**

A: **NÃO!** Use sempre:
```abap
" ❌ Não faça isso
p_key = 'sk-minha-chave-secreta'.

" ✅ Faça isso - parâmetro de seleção
PARAMETERS: p_key TYPE string.

" ✅ Ou use tabela de configuração
SELECT SINGLE api_key FROM zconfig_ai 
  INTO @DATA(lv_key)
  WHERE config_id = 'PROD'.
```

**Q: Como proteger dados sensíveis?**

A:
1. Use HTTPS sempre
2. Não registre dados pessoais em logs
3. Implemente data masking para testes
4. Configure timeouts adequados

### 💰 Custos

**Q: Como controlar custos?**

A:
```abap
" Implementar controle de custos
DATA: lv_daily_limit TYPE i VALUE 1000,  " Limite diário de tokens
      lv_used_today  TYPE i.

" Verificar uso do dia
SELECT SUM( tokens ) FROM zaisdk_usage
  INTO lv_used_today
  WHERE datum = sy-datum.

IF lv_used_today > lv_daily_limit.
  MESSAGE 'Limite diário de tokens excedido' TYPE 'E'.
  RETURN.
ENDIF.
```

**Q: Qual modelo é mais barato?**

A:
- **GPT-3.5-turbo**: Mais barato, boa qualidade
- **GPT-4**: Mais caro, melhor qualidade
- **Embeddings**: Muito barato para análise semântica

### ⚡ Performance

**Q: Como acelerar as chamadas?**

A:
1. **Use parâmetros otimizados**
   ```abap
   ls_input-temperature = '0.3'.      " Menos variação = mais rápido
   ls_input-max_tokens = 500.         " Limite resposta
   ```

2. **Implemente cache**
   ```abap
   " Cache simples
   DATA: gt_cache TYPE HASHED TABLE OF ty_cache WITH UNIQUE KEY request.
   
   READ TABLE gt_cache WITH KEY request = lv_request INTO DATA(ls_cached).
   IF sy-subrc = 0.
     " Usar resposta do cache
     RETURN.
   ENDIF.
   ```

3. **Use conexões keep-alive**
   ```abap
   lo_client->propertytype_accept_cookie = if_http_client=>co_enabled.
   ```

---

## 🛠️ Ferramentas de Diagnóstico

### 🔍 Diagnostic Report

```abap
*&---------------------------------------------------------------------*
*& Report Z_AISDK_DIAGNOSTIC
*&---------------------------------------------------------------------*
REPORT z_aisdk_diagnostic.

PARAMETERS:
  p_url TYPE string OBLIGATORY,
  p_key TYPE string OBLIGATORY,
  p_ver TYPE string OBLIGATORY.

START-OF-SELECTION.

  WRITE: / '🔍 Diagnóstico do AI SDK - ', sy-datum, sy-uzeit.
  WRITE: / '═══════════════════════════════════════════════════════'.

  " 1. Teste de Conectividade
  WRITE: / '1. 🌐 Teste de Conectividade'.
  PERFORM test_connectivity USING p_url.

  " 2. Teste de SSL
  WRITE: / '2. 🔒 Teste de SSL/TLS'.
  PERFORM test_ssl USING p_url.

  " 3. Teste de Autenticação
  WRITE: / '3. 🔑 Teste de Autenticação'.
  PERFORM test_authentication USING p_url p_key.

  " 4. Teste de SDK
  WRITE: / '4. 🛠️  Teste de Instanciação do SDK'.
  PERFORM test_sdk_factory USING p_url p_key p_ver.

  " 5. Configurações do Sistema
  WRITE: / '5. ⚙️  Configurações do Sistema SAP'.
  PERFORM check_system_config.

  WRITE: / '═══════════════════════════════════════════════════════'.
  WRITE: / '✅ Diagnóstico concluído'.

*&---------------------------------------------------------------------*
FORM test_connectivity USING iv_url TYPE string.
  
  DATA: lo_client TYPE REF TO if_http_client.
  
  TRY.
    CALL METHOD cl_http_client=>create_by_url
      EXPORTING url = iv_url
      IMPORTING client = lo_client.
      
    lo_client->send( ).
    lo_client->receive( ).
    
    DATA(lv_status) = lo_client->response->get_status( ).
    
    WRITE: / '   Status:', lv_status-code, lv_status-reason.
    
    IF lv_status-code < 500.
      WRITE: / '   ✅ Conectividade OK'.
    ELSE.
      WRITE: / '   ❌ Problema de conectividade'.
    ENDIF.
    
    lo_client->close( ).
    
  CATCH cx_http_dest_provider_error INTO DATA(lx_dest).
    WRITE: / '   ❌ Erro de conectividade:', lx_dest->get_text( ).
  ENDTRY.
  
ENDFORM.

*&---------------------------------------------------------------------*
FORM test_ssl USING iv_url TYPE string.
  
  " Verificar se URL é HTTPS
  IF iv_url CS 'https://'.
    WRITE: / '   ✅ URL usa HTTPS'.
    
    " Testar certificado
    DATA: lo_client TYPE REF TO if_http_client.
    
    TRY.
      CALL METHOD cl_http_client=>create_by_url
        EXPORTING url = iv_url
        IMPORTING client = lo_client.
        
      " Tentar handshake SSL
      lo_client->send( ).
      WRITE: / '   ✅ Handshake SSL OK'.
      
    CATCH cx_http_dest_provider_error INTO DATA(lx_ssl).
      IF lx_ssl->get_text( ) CS 'SSL'.
        WRITE: / '   ❌ Problema SSL:', lx_ssl->get_text( ).
        WRITE: / '   💡 Verifique certificados na STRUST'.
      ENDIF.
    ENDTRY.
    
  ELSE.
    WRITE: / '   ⚠️  URL não usa HTTPS - inseguro!'.
  ENDIF.
  
ENDFORM.

*&---------------------------------------------------------------------*
FORM test_authentication USING iv_url TYPE string iv_key TYPE string.
  
  " Validar formato da chave
  IF strlen( iv_key ) = 32.
    WRITE: / '   ✅ Formato de chave Azure OpenAI'.
  ELSEIF iv_key CS 'sk-'.
    WRITE: / '   ✅ Formato de chave OpenAI'.
  ELSE.
    WRITE: / '   ⚠️  Formato de chave não reconhecido'.
  ENDIF.
  
  " Testar autenticação (se possível)
  DATA: lo_client TYPE REF TO if_http_client,
        lv_test_url TYPE string.
        
  " Construir URL de teste
  IF iv_url CS 'azure.com'.
    lv_test_url = |{ iv_url }openai/deployments?api-version=2023-05-15|.
  ELSE.
    lv_test_url = |{ iv_url }models|.
  ENDIF.
  
  TRY.
    CALL METHOD cl_http_client=>create_by_url
      EXPORTING url = lv_test_url
      IMPORTING client = lo_client.
      
    " Configurar autenticação
    IF iv_url CS 'azure.com'.
      lo_client->request->set_header_field( name = 'api-key' value = iv_key ).
    ELSE.
      lo_client->request->set_header_field( name = 'Authorization' value = |Bearer { iv_key }| ).
    ENDIF.
    
    lo_client->send( ).
    lo_client->receive( ).
    
    DATA(lv_status) = lo_client->response->get_status( ).
    
    CASE lv_status-code.
      WHEN 200.
        WRITE: / '   ✅ Autenticação OK'.
      WHEN 401.
        WRITE: / '   ❌ Chave API inválida'.
      WHEN 403.
        WRITE: / '   ❌ Acesso negado - verificar permissões'.
      WHEN OTHERS.
        WRITE: / '   ⚠️  Status:', lv_status-code, lv_status-reason.
    ENDCASE.
    
    lo_client->close( ).
    
  CATCH cx_http_dest_provider_error INTO DATA(lx_auth).
    WRITE: / '   ❌ Erro de autenticação:', lx_auth->get_text( ).
  ENDTRY.
  
ENDFORM.

*&---------------------------------------------------------------------*
FORM test_sdk_factory USING iv_url TYPE string iv_key TYPE string iv_ver TYPE string.
  
  TRY.
    " Testar factory
    DATA(lo_factory) = zcl_peng_azoai_sdk_factory=>get_instance( ).
    WRITE: / '   ✅ Factory instanciado'.
    
    " Testar SDK
    DATA(lo_sdk) = lo_factory->get_sdk(
      api_version = iv_ver
      api_base = iv_url
      api_type = COND #( WHEN iv_url CS 'azure.com' 
                        THEN zif_peng_azoai_sdk_constants=>c_apitype-azureopenai
                        ELSE zif_peng_azoai_sdk_constants=>c_apitype-openai )
      api_key = iv_key
    ).
    WRITE: / '   ✅ SDK instanciado'.
    
  CATCH zcx_peng_azoai_sdk_exception INTO DATA(lx_sdk).
    WRITE: / '   ❌ Erro no SDK:', lx_sdk->get_text( ).
  ENDTRY.
  
ENDFORM.

*&---------------------------------------------------------------------*
FORM check_system_config.
  
  " Verificar parâmetros do sistema
  DATA: lv_param TYPE string.
  
  " Timeout HTTP
  CALL 'C_SAPGPARAM' ID 'NAME' FIELD 'icm/HTTP/timeout_client' 
                     ID 'VALUE' FIELD lv_param.
  WRITE: / '   HTTP Timeout Client:', lv_param.
  
  " Verificar conectividade HTTPS
  WRITE: / '   Conectividade HTTPS: (verificar manualmente)'.
  
  " User agent
  WRITE: / '   SAP Release:', sy-saprl.
  WRITE: / '   ABAP Version:', sy-abcde.
  
ENDFORM.
```

### 📊 Performance Monitor

```abap
*&---------------------------------------------------------------------*
*& Report Z_AISDK_PERFORMANCE_MONITOR
*&---------------------------------------------------------------------*
REPORT z_aisdk_performance_monitor.

" Tabela para armazenar métricas
TYPES: BEGIN OF ty_metric,
         timestamp    TYPE timestamp,
         user         TYPE sy-uname,
         operation    TYPE string,
         duration_ms  TYPE i,
         tokens       TYPE i,
         status_code  TYPE i,
         error_msg    TYPE string,
       END OF ty_metric.

DATA: gt_metrics TYPE TABLE OF ty_metric.

START-OF-SELECTION.

  " Simulação de métricas
  gt_metrics = VALUE #(
    ( timestamp = '20240101120000' user = 'USER1' operation = 'chat_completion' 
      duration_ms = 1500 tokens = 150 status_code = 200 )
    ( timestamp = '20240101120100' user = 'USER2' operation = 'embeddings' 
      duration_ms = 800 tokens = 50 status_code = 200 )
    ( timestamp = '20240101120200' user = 'USER1' operation = 'chat_completion' 
      duration_ms = 0 tokens = 0 status_code = 429 error_msg = 'Rate limit' )
  ).

  " Análise de performance
  WRITE: / '📊 Relatório de Performance - AI SDK'.
  WRITE: / '═══════════════════════════════════════════════'.

  " Estatísticas gerais
  DATA(lv_total_calls) = lines( gt_metrics ).
  DATA(lv_success_calls) = REDUCE i( INIT sum = 0 
                                     FOR ls_metric IN gt_metrics 
                                     WHERE ( status_code = 200 )
                                     NEXT sum = sum + 1 ).
  
  WRITE: / 'Total de chamadas:', lv_total_calls.
  WRITE: / 'Chamadas bem-sucedidas:', lv_success_calls.
  WRITE: / 'Taxa de sucesso:', ( lv_success_calls * 100 / lv_total_calls ), '%'.

  " Tempo médio de resposta
  DATA(lv_avg_duration) = REDUCE i( INIT sum = 0 
                                    FOR ls_metric IN gt_metrics 
                                    WHERE ( status_code = 200 )
                                    NEXT sum = sum + ls_metric-duration_ms ) / lv_success_calls.
  WRITE: / 'Tempo médio:', lv_avg_duration, 'ms'.

  " Top operações
  WRITE: / ''.
  WRITE: / '🔝 Operações mais utilizadas:'.
  
  DATA: BEGIN OF ls_op_count,
          operation TYPE string,
          count     TYPE i,
        END OF ls_op_count,
        lt_op_counts LIKE HASHED TABLE OF ls_op_count WITH UNIQUE KEY operation.

  LOOP AT gt_metrics INTO DATA(ls_metric).
    READ TABLE lt_op_counts WITH KEY operation = ls_metric-operation INTO ls_op_count.
    IF sy-subrc = 0.
      ls_op_count-count = ls_op_count-count + 1.
      MODIFY TABLE lt_op_counts FROM ls_op_count.
    ELSE.
      ls_op_count-operation = ls_metric-operation.
      ls_op_count-count = 1.
      INSERT ls_op_count INTO TABLE lt_op_counts.
    ENDIF.
  ENDLOOP.

  LOOP AT lt_op_counts INTO ls_op_count.
    WRITE: / '  ', ls_op_count-operation, ':', ls_op_count-count, 'calls'.
  ENDLOOP.

ENDFORM.
```

---

## 📈 Monitoramento Contínuo

### 🎯 KPIs Importantes

1. **Disponibilidade**: % de chamadas bem-sucedidas
2. **Latência**: Tempo médio de resposta
3. **Throughput**: Chamadas por minuto
4. **Custo**: Tokens consumidos por período
5. **Qualidade**: Taxa de erro por tipo

### 📋 Checklist de Manutenção

**Diário:**
- [ ] Verificar logs de erro
- [ ] Monitorar uso de tokens
- [ ] Verificar rate limits

**Semanal:**
- [ ] Revisar performance metrics
- [ ] Verificar certificados SSL
- [ ] Atualizar documentação de issues

**Mensal:**
- [ ] Análise de custos
- [ ] Review de configurações
- [ ] Backup de configurações
- [ ] Treinamento de equipe

---

## 🆘 Quando Buscar Ajuda

### 📞 Canais de Suporte

1. **Documentação Oficial**: [Microsoft AI SDK Documentation](https://microsoft.github.io/aisdkforsapabap/)
2. **GitHub Issues**: [Relatar bugs](https://github.com/microsoft/aisdkforsapabap/issues)
3. **Community Forum**: [Discussions](https://github.com/microsoft/aisdkforsapabap/discussions)
4. **Stack Overflow**: Tag `sap-abap` + `openai`

### 📝 Informações para Suporte

Sempre inclua:
```abap
" Template para reporte de problemas
WRITE: / '🐛 Reporte de Bug - AI SDK'.
WRITE: / '═══════════════════════════════'.
WRITE: / 'Data/Hora:', sy-datum, sy-uzeit.
WRITE: / 'Sistema:', sy-sysid.
WRITE: / 'Release SAP:', sy-saprl.
WRITE: / 'SDK Version: 2.0'.
WRITE: / 'Provider:', 'Azure OpenAI' " ou 'OpenAI'.
WRITE: / 'Erro:', 'Descreva o problema aqui'.
WRITE: / 'Steps to reproduce:', '1. ... 2. ... 3. ...'.
WRITE: / 'Expected:', 'O que esperava que acontecesse'.
WRITE: / 'Actual:', 'O que realmente aconteceu'.
```

---

## 💡 Dicas Finais

### ✅ Boas Práticas
1. **Sempre teste** em ambiente de desenvolvimento primeiro
2. **Monitore custos** regularmente  
3. **Implemente logs** detalhados
4. **Use retry logic** para resiliência
5. **Documente configurações** específicas do seu ambiente

### 🚫 Evite
1. Hardcode de chaves API
2. Chamadas síncronas para operações longas
3. Ignorar rate limits
4. Logs com dados sensíveis
5. Timeouts muito baixos

---

*Este guia de troubleshooting é atualizado regularmente com base no feedback da comunidade. Para contribuir com novas soluções, use o [GitHub Discussions](https://github.com/microsoft/aisdkforsapabap/discussions).*

**[⬆️ Voltar ao Guia Principal](README_PT-BR.md)**