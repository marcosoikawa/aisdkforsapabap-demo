# Guia de Instalação e Configuração - Microsoft AI SDK para SAP ABAP v2.0

## 🎯 Visão Geral

Este guia fornece instruções detalhadas para instalar e configurar o Microsoft AI SDK para SAP ABAP v2.0 em seu ambiente SAP.

---

## 📋 Pré-requisitos

### 🖥️ Ambiente SAP
- **SAP NetWeaver**: Versão 7.40 ou superior
- **Sistema ABAP**: Com suporte a orientação a objetos
- **Autorização**: Perfil de desenvolvedor com acesso a:
  - Transação SE80 (Workbench ABAP)
  - Transação SM30 (Manutenção de tabelas)
  - Criação de pacotes e objetos ABAP

### 🌐 Conectividade
- **HTTPS**: Conectividade de saída habilitada
- **Portas**: 443 (HTTPS) liberada para:
  - `api.openai.com` (OpenAI)
  - `*.openai.azure.com` (Azure OpenAI)
- **Certificados SSL**: Instalados e atualizados no STRUST
- **Proxy**: Configurado se necessário (SCOT)

### 🔑 Credenciais de API

#### Para Azure OpenAI:
1. **Recurso Azure OpenAI**: Criado no portal do Azure
2. **Chave de API**: Obtida do portal do Azure
3. **Endpoint**: URL do recurso Azure OpenAI
4. **Deployment ID**: Modelo deployado (ex: gpt-35-turbo)

#### Para OpenAI:
1. **Conta OpenAI**: Registrada em platform.openai.com
2. **API Key**: Chave secreta gerada
3. **Organização**: ID da organização (opcional)

### 🛠️ Ferramentas
- **abapGit**: Para importação de código ([download](https://github.com/abapGit/abapGit))
- **Browser**: Para acesso aos portais de configuração

---

## 📥 Processo de Instalação

### Etapa 1: Preparação do Sistema SAP

#### 1.1 Verificar Conectividade
```abap
* Teste de conectividade básica
CALL METHOD cl_http_client=>create_by_url
  EXPORTING
    url    = 'https://api.openai.com/v1/models'
  IMPORTING
    client = DATA(lo_client).

lo_client->send( ).
lo_client->receive( ).

DATA(lv_status) = lo_client->response->get_status( ).
WRITE: / 'Status Code:', lv_status-code.
```

#### 1.2 Configurar Certificados SSL
1. Vá para transação **STRUST**
2. Expanda **SSL Client SSL Client (Anonymous)**
3. Baixe certificados de:
   - api.openai.com
   - *.openai.azure.com
4. Importe os certificados para o certificate store

#### 1.3 Configurar Proxy (se necessário)
1. Transação **SCOT**
2. Configure settings de proxy para conexões HTTPS
3. Teste conectividade

### Etapa 2: Download e Preparação do Código

#### 2.1 Obter o Código-fonte
```bash
# Clone do repositório
git clone https://github.com/marcosoikawa/aisdkforsapabap-demo.git

# Ou download direto
wget https://github.com/marcosoikawa/aisdkforsapabap-demo/archive/main.zip
```

#### 2.2 Examinar Estrutura
```
aisdkforsapabap-demo/
├── .abapgit.xml           # Configuração abapGit
├── src/                   # Código fonte ABAP
│   └── zpengg_ai_openai_main/
└── README.md              # Documentação
```

### Etapa 3: Importação via abapGit

#### 3.1 Instalar abapGit
1. Baixe `zabapgit.abap` do [repositório oficial](https://github.com/abapGit/abapGit)
2. Crie programa ZABAPGIT no SE80
3. Cole o conteúdo e ative

#### 3.2 Importar Repositório
1. Execute ZABAPGIT
2. Clique em **"New Online"**
3. Configure:
   - **URL**: `https://github.com/marcosoikawa/aisdkforsapabap-demo.git`
   - **Package**: `ZPENGG_AI_OPENAI_MAIN`
   - **Folder Logic**: `FULL`
4. Clique **"Clone"**
5. Resolva dependências se necessário
6. Ative todos os objetos

#### 3.3 Verificar Instalação
```abap
* Verificar se classes principais foram instaladas
SELECT SINGLE * FROM tadir 
  WHERE pgmid = 'R3TR'
    AND object = 'CLAS'
    AND obj_name = 'ZCL_PENG_AZOAI_SDK_FACTORY'.
```

---

## ⚙️ Configuração

### Configuração 1: Azure OpenAI

#### 1.1 Criar Recurso no Azure
1. **Portal Azure**: portal.azure.com
2. **Criar Recurso**: Azure OpenAI
3. **Configurar**:
   - Nome do recurso
   - Região (preferencialmente próxima)
   - Pricing tier
4. **Deploy Modelo**:
   - Vá para Azure OpenAI Studio
   - Deploy modelo (ex: gpt-35-turbo, gpt-4)
   - Anote o deployment ID

#### 1.2 Obter Credenciais
```
Endpoint: https://seu-recurso.openai.azure.com/
API Key: da1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d
Deployment ID: gpt-35-turbo
API Version: 2024-02-15-preview
```

#### 1.3 Configurar no SAP
```abap
* Parâmetros de configuração Azure OpenAI
PARAMETERS: 
  p_azurl  TYPE string DEFAULT 'https://seu-recurso.openai.azure.com/',
  p_azver  TYPE string DEFAULT '2024-02-15-preview',
  p_azkey  TYPE string DEFAULT 'sua-chave-api',
  p_azdep  TYPE string DEFAULT 'gpt-35-turbo'.
```

### Configuração 2: OpenAI

#### 2.1 Criar Conta OpenAI
1. **Registrar**: platform.openai.com
2. **API Keys**: Gerar nova chave API
3. **Billing**: Configurar método de pagamento
4. **Usage Limits**: Definir limites (opcional)

#### 2.2 Obter Credenciais
```
Base URL: https://api.openai.com/v1/
API Key: sk-proj-abcd1234efgh5678ijkl9012mnop3456
Organization: org-abc123def456ghi789 (opcional)
```

#### 2.3 Configurar no SAP
```abap
* Parâmetros de configuração OpenAI
PARAMETERS:
  p_oaiurl TYPE string DEFAULT 'https://api.openai.com/v1/',
  p_oaiver TYPE string DEFAULT 'v1',
  p_oaikey TYPE string DEFAULT 'sk-proj-sua-chave-aqui',
  p_model  TYPE string DEFAULT 'gpt-3.5-turbo'.
```

### Configuração 3: Parâmetros de Sistema

#### 3.1 Criar Tabela de Configuração (Opcional)
```abap
* Tabela customizada para configurações
TABLE: ZAISDK_CONFIG.

PARAMETERS:
  p_config TYPE zaisdk_config-config_id DEFAULT 'PROD'.

* SELECT configuração da tabela
SELECT SINGLE * FROM zaisdk_config INTO @DATA(ls_config)
  WHERE config_id = @p_config.
```

#### 3.2 Usar Variantes de Seleção
1. **SE80**: Abra programa de demonstração
2. **Goto → Variants**
3. **Create Variant**:
   - Nome: AZURE_PROD, OPENAI_TEST, etc.
   - Salve configurações específicas
4. **Execute** com variante apropriada

---

## 🧪 Testes de Instalação

### Teste 1: Conectividade Básica

```abap
REPORT ztest_aisdk_connectivity.

PARAMETERS: p_url TYPE string OBLIGATORY.

DATA: lo_client TYPE REF TO if_http_client.

* Criar cliente HTTP
CALL METHOD cl_http_client=>create_by_url
  EXPORTING
    url    = p_url
  IMPORTING
    client = lo_client.

* Configurar headers
lo_client->request->set_header_field( 
  name  = 'User-Agent'
  value = 'SAP-ABAP-AI-SDK/2.0' ).

* Enviar request
lo_client->send( ).
lo_client->receive( ).

* Verificar resposta
DATA(lv_status) = lo_client->response->get_status( ).
WRITE: / 'Status Code:', lv_status-code.
WRITE: / 'Status Text:', lv_status-reason.

IF lv_status-code = 200.
  WRITE: / '✅ Conectividade OK'.
ELSE.
  WRITE: / '❌ Falha na conectividade'.
ENDIF.

lo_client->close( ).
```

### Teste 2: Instanciação do SDK

```abap
REPORT ztest_aisdk_factory.

PARAMETERS: 
  p_url TYPE string OBLIGATORY,
  p_key TYPE string OBLIGATORY,
  p_ver TYPE string OBLIGATORY.

DATA: lo_sdk TYPE REF TO zif_peng_azoai_centralcontrol.

TRY.
  * Criar instância do SDK
  lo_sdk = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
    api_version = p_ver
    api_base    = p_url
    api_type    = zif_peng_azoai_sdk_constants=>c_apitype-azureopenai
    api_key     = p_key
  ).
  
  WRITE: / '✅ SDK instanciado com sucesso'.
  
CATCH zcx_peng_azoai_sdk_exception INTO DATA(lx_error).
  WRITE: / '❌ Erro ao instanciar SDK:', lx_error->get_text( ).
ENDTRY.
```

### Teste 3: Chamada Simples de API

```abap
REPORT ztest_aisdk_simple_call.

INCLUDE zp_msaisdkdemo_params_top_oai.
INCLUDE zp_msaisdkdemo_common.

PARAMETERS: p_depid TYPE string OBLIGATORY DEFAULT 'gpt-35-turbo'.

DATA: ls_input  TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_input,
      ls_output TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_output.

START-OF-SELECTION.

TRY.
  * Instanciar SDK
  sdk_instance = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
    api_version = p_ver
    api_base    = p_url
    api_type    = zif_peng_azoai_sdk_constants=>c_apitype-azureopenai
    api_key     = p_key
  ).

  * Preparar mensagem de teste
  APPEND VALUE #( 
    role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-user 
    content = 'Olá! Este é um teste de conectividade.'
  ) TO ls_input-messages.

  * Executar chamada
  sdk_instance->chat_completions( )->create(
    EXPORTING
      deploymentid = p_depid
      prompts      = ls_input
    IMPORTING
      statuscode   = status_code
      statusreason = status_reason
      response     = ls_output
      json         = returnjson
      error        = error
  ).

  * Verificar resultado
  IF status_code = 200.
    WRITE: / '✅ Teste concluído com sucesso!'.
    WRITE: / 'Resposta:', ls_output-choices[ 1 ]-message-content.
  ELSE.
    WRITE: / '❌ Falha no teste - Status:', status_code.
    WRITE: / 'Reason:', status_reason.
  ENDIF.

CATCH zcx_peng_azoai_sdk_exception INTO DATA(lx_error).
  WRITE: / '❌ Exceção capturada:', lx_error->get_text( ).
ENDTRY.
```

---

## 🔧 Solução de Problemas na Instalação

### ❗ Problemas Comuns

#### 1. Erro de Sintaxe ABAP
```
Sintoma: Objetos não ativam devido a erros de sintaxe
Solução: Verificar versão SAP - requires NW 7.40+
```

#### 2. Dependências Não Encontradas
```
Sintoma: Classe/Interface não encontrada
Solução: Importar objetos na ordem correta via abapGit
```

#### 3. Erro de Conectividade SSL
```
Sintoma: CSSMERR_SSL_HANDSHAKE_FAILED
Solução: 
1. Instalar certificados no STRUST
2. Verificar configurações de proxy
3. Testar conectividade básica
```

#### 4. Erro de Autorização
```
Sintoma: 401 Unauthorized
Solução:
1. Verificar chave API
2. Verificar formato da chave (Azure vs OpenAI)
3. Verificar se o recurso está ativo
```

#### 5. Timeout de Conexão
```
Sintoma: Timeout errors
Solução:
1. Aumentar timeout no profile SAP
2. Verificar conectividade de rede
3. Usar endpoints regionais próximos
```

### 🔍 Debug e Logs

#### Ativar Logging Detalhado
```abap
* No início dos programas de teste
DATA: lv_debug TYPE abap_bool VALUE abap_true.

IF lv_debug = abap_true.
  SET BREAKPOINT.
  BREAK-POINT.
ENDIF.
```

#### Log de Requests HTTP
```abap
* Capturar requests para análise
DATA: lo_client TYPE REF TO if_http_client.

" Após criar cliente HTTP
lo_client->request->get_form_fields( IMPORTING fields = DATA(lt_fields) ).
lo_client->request->get_header_fields( IMPORTING fields = DATA(lt_headers) ).

" Log para debugging
LOOP AT lt_headers INTO DATA(ls_header).
  WRITE: / 'Header:', ls_header-name, '=', ls_header-value.
ENDLOOP.
```

---

## 📊 Validação da Instalação

### ✅ Checklist de Validação

- [ ] **Conectividade HTTPS**: Testada com endpoints de IA
- [ ] **Certificados SSL**: Instalados e funcionando
- [ ] **abapGit**: Objetos importados sem erros
- [ ] **Ativação**: Todos os objetos ativados com sucesso
- [ ] **SDK Factory**: Instanciação bem-sucedida
- [ ] **API Call**: Chamada simples funcionando
- [ ] **Autenticação**: Credenciais válidas e funcionando
- [ ] **Resposta**: Recebendo respostas corretas da IA
- [ ] **Error Handling**: Tratamento de erros funcionando
- [ ] **Documentação**: Exemplos executando corretamente

### 📋 Comando de Status
```abap
REPORT zaisdk_installation_status.

* Verificar objetos principais
DATA: lt_objects TYPE TABLE OF tadir.

SELECT * FROM tadir INTO TABLE lt_objects
  WHERE pgmid = 'R3TR'
    AND devclass = 'ZPENGG_AI_OPENAI_MAIN'
    AND as4local = 'A'.

WRITE: / 'Objetos Ativos:', lines( lt_objects ).

IF lines( lt_objects ) > 50. " Aproximadamente 52 objetos esperados
  WRITE: / '✅ Instalação aparentemente completa'.
ELSE.
  WRITE: / '⚠️  Instalação pode estar incompleta'.
ENDIF.
```

---

## 🚀 Próximos Passos

Após instalação bem-sucedida:

1. **Executar Demonstrações**: Teste programas em `zpengg_oai_demos`
2. **Criar Primeiro Projeto**: Use templates fornecidos
3. **Configurar Produção**: Setup de ambiente produtivo
4. **Treinamento**: Familiarizar equipe com SDK
5. **Monitoramento**: Configurar logs e métricas

### 📚 Recursos Adicionais
- [Guia de Desenvolvimento](DESENVOLVIMENTO.md)
- [Exemplos de Código](EXEMPLOS.md)  
- [API Reference](https://microsoft.github.io/aisdkforsapabap/)
- [Fórum da Comunidade](https://github.com/microsoft/aisdkforsapabap/discussions)

---

*Este guia foi criado para facilitar a instalação e configuração do Microsoft AI SDK para SAP ABAP v2.0. Para suporte adicional, consulte a documentação oficial ou use o fórum da comunidade.*

**[⬆️ Voltar ao Índice Principal](README_PT-BR.md)**