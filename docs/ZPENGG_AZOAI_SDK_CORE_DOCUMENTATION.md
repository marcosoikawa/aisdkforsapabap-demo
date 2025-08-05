# Documentação do ZPENGG_AZOAI_SDK_CORE
## Microsoft AI SDK para SAP ABAP - Guia Completo e Didático

### 📋 Índice
1. [Visão Geral](#visão-geral)
2. [Arquitetura do SDK](#arquitetura-do-sdk)
3. [Componentes Principais](#componentes-principais)
4. [Como Usar o SDK](#como-usar-o-sdk)
5. [Exemplos Práticos](#exemplos-práticos)
6. [Configuração](#configuração)
7. [Boas Práticas](#boas-práticas)
8. [Referência da API](#referência-da-api)

---

## 🎯 Visão Geral

O **ZPENGG_AZOAI_SDK_CORE** é um SDK (Software Development Kit) abrangente que permite aos desenvolvedores SAP ABAP integrar facilmente funcionalidades de Inteligência Artificial (IA) em suas aplicações empresariais usando os serviços Azure OpenAI e OpenAI.

### O que você pode fazer com este SDK:
- 🤖 **Chat Completions**: Interagir com modelos GPT-4 para conversas inteligentes
- 📝 **Text Completions**: Gerar texto automático baseado em prompts
- 🧮 **Embeddings**: Criar representações vetoriais de texto para análise semântica
- 📊 **Fine-tuning**: Treinar modelos personalizados com seus próprios dados
- 📁 **Gerenciamento de Arquivos**: Fazer upload e gerenciar arquivos de treinamento
- 🚀 **Deployments**: Gerenciar instâncias de modelos implantados
- 🔍 **Models**: Consultar informações sobre modelos disponíveis

### Benefícios:
- ✅ **Fácil de usar**: Interface ABAP nativa e intuitiva
- ✅ **Flexível**: Suporte a múltiplas versões de API e tipos de autenticação
- ✅ **Seguro**: Controle centralizado de acesso e permissões
- ✅ **Robusto**: Tratamento abrangente de erros e exceções
- ✅ **Bem documentado**: Exemplos práticos e demos incluídos

---

## 🏗️ Arquitetura do SDK

O SDK segue uma arquitetura modular e bem estruturada baseada em padrões de design modernos:

```
┌─────────────────────────────────────────────────────────────┐
│                    APLICAÇÃO ABAP                           │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│               ZCL_PENG_AZOAI_SDK_FACTORY                    │
│                    (Factory Pattern)                        │
└─────────────────────┬───────────────────────────────────────┘
                      │ cria instância
┌─────────────────────▼───────────────────────────────────────┐
│                ZIF_PENG_AZOAI_SDK                           │
│                (Interface Principal)                        │
└─────────────────────┬───────────────────────────────────────┘
                      │ implementado por
┌─────────────────────▼───────────────────────────────────────┐
│              ZCL_PENG_AZOAI_SDK_BASE                        │
│                 (Classe Base Abstrata)                      │
└──┬──────────┬──────────┬──────────┬──────────┬──────────┬───┘
   │          │          │          │          │          │
   ▼          ▼          ▼          ▼          ▼          ▼
┌──────┐ ┌──────┐ ┌─────────┐ ┌──────┐ ┌──────┐ ┌─────────┐
│Models│ │Deploy│ │Complet. │ │Chat  │ │Files │ │Fine-tune│
│      │ │ments │ │         │ │Compl.│ │      │ │         │
└──────┘ └──────┘ └─────────┘ └──────┘ └──────┘ └─────────┘
```

### Componentes da Arquitetura:

#### 1. **Factory (Fábrica)**
- **Classe**: `ZCL_PENG_AZOAI_SDK_FACTORY`
- **Função**: Ponto de entrada único para criar instâncias do SDK
- **Padrão**: Singleton + Factory Method

#### 2. **Central Control (Controle Central)**
- **Classe**: `ZCL_PENG_AZOAI_CENTRALCONTROL`
- **Função**: Controla permissões e acesso aos componentes
- **Responsabilidades**:
  - Validar se o SDK pode ser usado
  - Verificar permissões para componentes específicos
  - Autorizar operações

#### 3. **Configuration (Configuração)**
- **Interface**: `ZIF_PENG_AZOAI_SDK_CONFIG`
- **Função**: Gerenciar configurações de API, autenticação e endpoints
- **Suporte a**:
  - Azure OpenAI
  - OpenAI
  - Múltiplas versões de API
  - Diferentes tipos de autenticação

#### 4. **Helper (Auxiliar)**
- **Classe**: `ZCL_PENG_AZOAI_SDK_HELPER`
- **Função**: Funções utilitárias para comunicação HTTP, processamento JSON
- **Padrão**: Singleton

#### 5. **Components (Componentes)**
Cada funcionalidade é implementada como um componente separado:
- **Models**: Gerenciamento de modelos
- **Deployments**: Gerenciamento de implantações
- **Completions**: Geração de texto
- **Chat Completions**: Conversas com IA
- **Files**: Gerenciamento de arquivos
- **Fine-tuning**: Treinamento personalizado
- **Embeddings**: Representações vetoriais

---

## 🧩 Componentes Principais

### 1. 🤖 **Models (Modelos)**
Permite interagir com os modelos GPT disponíveis.

**Operações disponíveis:**
- `LIST`: Listar todos os modelos disponíveis
- `GET`: Obter detalhes de um modelo específico

**Interface**: `ZIF_PENG_AZOAI_SDK_COMP_MODEL`

### 2. 🚀 **Deployments (Implantações)**
Gerencia instâncias específicas de modelos que podem ser usadas para geração de texto.

**Operações disponíveis:**
- `CREATE`: Criar nova implantação
- `LIST`: Listar todas as implantações
- `GET`: Obter informações de uma implantação
- `DELETE`: Excluir uma implantação

**Interface**: `ZIF_PENG_AZOAI_SDK_COMP_DEPLOY`

### 3. 📝 **Completions (Complementações)**
Para geração de texto usando modelos GPT tradicionais.

**Operações disponíveis:**
- `CREATE`: Gerar completamento de texto

**Interface**: `ZIF_PENG_AZOAI_SDK_COMP_COMPL`

### 4. 💬 **Chat Completions (Conversas)**
Para interações conversacionais com modelos GPT-4.

**Operações disponíveis:**
- `CREATE`: Criar completamento de chat

**Interface**: `ZIF_PENG_AI_SDK_COMP_CHATCOMPL`

### 5. 📁 **Files (Arquivos)**
Gerenciamento de arquivos para treinamento e validação.

**Operações disponíveis:**
- `UPLOAD`: Fazer upload de arquivos
- `IMPORT`: Importar arquivos de URL
- `LIST`: Listar arquivos
- `GET`: Obter detalhes do arquivo
- `GET_CONTENT`: Obter conteúdo do arquivo
- `DELETE`: Excluir arquivo

**Interface**: `ZIF_PENG_AZOAI_SDK_COMP_FILES`

### 6. 🎯 **Fine-tuning (Ajuste Fino)**
Para treinamento de modelos personalizados.

**Operações disponíveis:**
- `CREATE`: Criar job de fine-tuning
- `LIST`: Listar jobs de fine-tuning
- `GET`: Obter detalhes de um job
- `GET_EVENTS`: Obter eventos de um job
- `CANCEL`: Cancelar um job
- `DELETE`: Excluir um job

**Interface**: `ZIF_PENG_AZOAI_SDK_COMP_FINTUN`

### 7. 🧮 **Embeddings (Representações Vetoriais)**
Para criar representações vetoriais de texto.

**Operações disponíveis:**
- `CREATE`: Criar embeddings

**Interface**: `ZIF_PENG_AZOAI_SDK_COMP_EMBED`

---

## 🚀 Como Usar o SDK

### Passo 1: Obter uma Instância do SDK

```abap
DATA: sdk_instance TYPE REF TO zif_peng_azoai_sdk.

TRY.
  " Criar instância do SDK
  sdk_instance = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
    api_version = '2023-05-15'                           " Versão da API
    api_base    = 'https://seu-recurso.openai.azure.com' " URL base
    api_type    = zif_peng_azoai_sdk_constants=>c_apitype-azure " Tipo de API
    api_key     = 'sua-chave-api'                        " Chave de autenticação
  ).

CATCH zcx_peng_azoai_sdk_exception INTO DATA(ex).
  " Tratamento de erro
  MESSAGE ex TYPE 'E'.
ENDTRY.
```

### Passo 2: Usar os Componentes

#### Exemplo 1: Listar Modelos Disponíveis

```abap
DATA: models_output TYPE zif_peng_azoai_sdk_types=>ty_model_list,
      status_code   TYPE i,
      status_reason TYPE string,
      error_info    TYPE zif_peng_azoai_sdk_types=>ty_error.

TRY.
  sdk_instance->model( )->list(
    IMPORTING
      statuscode   = status_code
      statusreason = status_reason
      response     = models_output
      error        = error_info
  ).

  IF status_code = 200.
    " Sucesso - processar lista de modelos
    LOOP AT models_output-data INTO DATA(model).
      WRITE: / 'Modelo:', model-id, 'Status:', model-status.
    ENDLOOP.
  ELSE.
    " Erro na API
    MESSAGE |Erro {status_code}: {status_reason}| TYPE 'E'.
  ENDIF.

CATCH zcx_peng_azoai_sdk_exception INTO DATA(ex).
  MESSAGE ex TYPE 'E'.
ENDTRY.
```

#### Exemplo 2: Chat Completion Simples

```abap
DATA: chatcompl_input  TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_input,
      chatcompl_output TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_output.

" Configurar mensagens do chat
APPEND VALUE #( 
  role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-system
  content = 'Você é um assistente especializado em SAP ABAP.'
) TO chatcompl_input-messages.

APPEND VALUE #( 
  role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-user
  content = 'Explique o que é uma tabela interna em ABAP.'
) TO chatcompl_input-messages.

TRY.
  sdk_instance->chat_completions( )->create(
    EXPORTING
      deploymentid = 'nome-do-seu-deployment'
      prompts      = chatcompl_input
    IMPORTING
      statuscode   = status_code
      response     = chatcompl_output
      error        = error_info
  ).

  IF status_code = 200.
    " Exibir resposta
    DATA(resposta) = chatcompl_output-choices[ 1 ]-message-content.
    cl_demo_output=>display_text( resposta ).
  ENDIF.

CATCH zcx_peng_azoai_sdk_exception INTO DATA(ex).
  MESSAGE ex TYPE 'E'.
ENDTRY.
```

---

## 📚 Exemplos Práticos

### Exemplo 1: Assistente de Código ABAP

```abap
REPORT z_ai_code_assistant.

PARAMETERS: p_prompt TYPE string OBLIGATORY.

DATA: sdk TYPE REF TO zif_peng_azoai_sdk,
      input TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_input,
      output TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_output.

START-OF-SELECTION.
  TRY.
    " Inicializar SDK
    sdk = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
      api_version = '2023-05-15'
      api_base    = 'https://seu-recurso.openai.azure.com'
      api_type    = zif_peng_azoai_sdk_constants=>c_apitype-azure
      api_key     = 'SUA_CHAVE_API'
    ).

    " Configurar prompt para assistente de código
    APPEND VALUE #( 
      role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-system
      content = |Você é um especialista em SAP ABAP. Forneça código limpo, |
             && |bem comentado e seguindo as melhores práticas.|
    ) TO input-messages.

    APPEND VALUE #( 
      role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-user
      content = p_prompt
    ) TO input-messages.

    " Configurar parâmetros
    input-max_tokens = 1000.
    input-temperature = '0.7'.

    " Fazer chamada
    sdk->chat_completions( )->create(
      EXPORTING
        deploymentid = 'gpt-4'
        prompts      = input
      IMPORTING
        response     = output
    ).

    " Exibir resultado
    cl_demo_output=>display_text( 
      text = output-choices[ 1 ]-message-content 
    ).

  CATCH zcx_peng_azoai_sdk_exception INTO DATA(ex).
    MESSAGE ex TYPE 'E'.
  ENDTRY.
```

### Exemplo 2: Análise de Sentimento de Texto

```abap
REPORT z_sentiment_analysis.

PARAMETERS: p_texto TYPE string OBLIGATORY.

DATA: sdk TYPE REF TO zif_peng_azoai_sdk,
      input TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_input,
      output TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_output.

START-OF-SELECTION.
  TRY.
    " Inicializar SDK
    sdk = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
      api_version = '2023-05-15'
      api_base    = 'https://seu-recurso.openai.azure.com'
      api_type    = zif_peng_azoai_sdk_constants=>c_apitype-azure
      api_key     = 'SUA_CHAVE_API'
    ).

    " Configurar prompt para análise de sentimento
    APPEND VALUE #( 
      role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-system
      content = |Analise o sentimento do texto fornecido e classifique como: |
             && |POSITIVO, NEGATIVO ou NEUTRO. Forneça também uma explicação breve.|
    ) TO input-messages.

    APPEND VALUE #( 
      role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-user
      content = |Texto para análise: "{ p_texto }"|
    ) TO input-messages.

    " Fazer chamada
    sdk->chat_completions( )->create(
      EXPORTING
        deploymentid = 'gpt-35-turbo'
        prompts      = input
      IMPORTING
        response     = output
    ).

    " Processar resultado
    DATA(analise) = output-choices[ 1 ]-message-content.
    
    " Exibir análise
    WRITE: / 'Texto Original:', p_texto,
           / 'Análise de Sentimento:', analise.

  CATCH zcx_peng_azoai_sdk_exception INTO DATA(ex).
    MESSAGE ex TYPE 'E'.
  ENDTRY.
```

### Exemplo 3: Gerador de Documentação

```abap
REPORT z_doc_generator.

PARAMETERS: p_codigo TYPE string OBLIGATORY.

START-OF-SELECTION.
  TRY.
    DATA(sdk) = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
      api_version = '2023-05-15'
      api_base    = 'https://seu-recurso.openai.azure.com'
      api_type    = zif_peng_azoai_sdk_constants=>c_apitype-azure
      api_key     = 'SUA_CHAVE_API'
    ).

    DATA(input) = VALUE zif_peng_azoai_sdk_types=>ty_chatcompletion_input( ).

    APPEND VALUE #( 
      role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-system
      content = |Você é um especialista em documentação de código. |
             && |Gere documentação técnica detalhada para o código fornecido.|
    ) TO input-messages.

    APPEND VALUE #( 
      role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-user
      content = |Gere documentação para este código ABAP: { p_codigo }|
    ) TO input-messages.

    DATA(output) = VALUE zif_peng_azoai_sdk_types=>ty_chatcompletion_output( ).

    sdk->chat_completions( )->create(
      EXPORTING
        deploymentid = 'gpt-4'
        prompts      = input
      IMPORTING
        response     = output
    ).

    " Exibir documentação gerada
    cl_demo_output=>display_html( 
      html = output-choices[ 1 ]-message-content 
    ).

  CATCH zcx_peng_azoai_sdk_exception INTO DATA(ex).
    MESSAGE ex TYPE 'E'.
  ENDTRY.
```

---

## ⚙️ Configuração

### Versões de API Suportadas

O SDK suporta múltiplas versões da API Azure OpenAI:

```abap
" Constantes de versão disponíveis
zif_peng_azoai_sdk_constants=>c_versions-v_2022_12_01         " 2022-12-01
zif_peng_azoai_sdk_constants=>c_versions-v_2023_03_15_preview " 2023-03-15-preview
zif_peng_azoai_sdk_constants=>c_versions-v_2023_05_15         " 2023-05-15
zif_peng_azoai_sdk_constants=>c_versions-v_2023_06_01_preview " 2023-06-01-preview
zif_peng_azoai_sdk_constants=>c_versions-v_2023_07_01_preview " 2023-07-01-preview
zif_peng_azoai_sdk_constants=>c_versions-v_2023_08_01_preview " 2023-08-01-preview
```

### Tipos de API

```abap
" Tipos de API suportados
zif_peng_azoai_sdk_constants=>c_apitype-azure     " Azure OpenAI
zif_peng_azoai_sdk_constants=>c_apitype-azure_ad  " Azure AD
zif_peng_azoai_sdk_constants=>c_apitype-openai    " OpenAI
```

### Configuração de Autenticação

#### Azure OpenAI com API Key:
```abap
sdk = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
  api_version = '2023-05-15'
  api_base    = 'https://seu-recurso.openai.azure.com'
  api_type    = zif_peng_azoai_sdk_constants=>c_apitype-azure
  api_key     = 'sua-chave-api'
).
```

#### OpenAI:
```abap
sdk = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
  api_version = 'v1'
  api_base    = 'https://api.openai.com'
  api_type    = zif_peng_azoai_sdk_constants=>c_apitype-openai
  api_key     = 'sk-sua-chave-openai'
).
```

---

## 🎯 Boas Práticas

### 1. **Tratamento de Erros**
Sempre use blocos TRY-CATCH para capturar exceções:

```abap
TRY.
  " Código do SDK
CATCH zcx_peng_azoai_sdk_exception INTO DATA(ex).
  " Log do erro
  MESSAGE ex TYPE 'E'.
CATCH cx_root INTO DATA(root_ex).
  " Tratamento de erros gerais
  MESSAGE |Erro inesperado: { root_ex->get_text( ) }| TYPE 'E'.
ENDTRY.
```

### 2. **Verificação de Status**
Sempre verifique o código de status HTTP:

```abap
sdk->chat_completions( )->create(
  EXPORTING
    deploymentid = deployment_id
    prompts      = input
  IMPORTING
    statuscode   = status_code
    statusreason = status_reason
    response     = output
    error        = error_info
).

CASE status_code.
  WHEN 200.
    " Sucesso
  WHEN 400.
    " Bad Request
  WHEN 401.
    " Unauthorized
  WHEN 429.
    " Rate Limit Exceeded
  WHEN 500.
    " Server Error
  WHEN OTHERS.
    " Outros erros
ENDCASE.
```

### 3. **Configuração de Parâmetros**
Configure parâmetros adequados para sua aplicação:

```abap
" Para código/documentação técnica
input-temperature = '0.1'.  " Menos criativo, mais preciso
input-max_tokens = 2000.

" Para conteúdo criativo
input-temperature = '0.8'.  " Mais criativo
input-max_tokens = 1000.
```

### 4. **Gestão de Recursos**
- Reutilize instâncias do SDK quando possível
- Configure timeouts apropriados
- Monitore uso de tokens

### 5. **Segurança**
- Nunca coloque chaves de API diretamente no código
- Use configurações seguras ou variáveis de ambiente
- Implemente controle de acesso adequado

---

## 📖 Referência da API

### Classes Principais

| Classe | Descrição | Tipo |
|--------|-----------|------|
| `ZCL_PENG_AZOAI_SDK_FACTORY` | Factory para criação de instâncias | Singleton |
| `ZCL_PENG_AZOAI_CENTRALCONTROL` | Controle de acesso e permissões | Normal |
| `ZCL_PENG_AZOAI_SDK_HELPER` | Funções utilitárias | Singleton |
| `ZCL_PENG_AZOAI_SDK_BASE` | Classe base abstrata | Abstract |

### Interfaces Principais

| Interface | Descrição |
|-----------|-----------|
| `ZIF_PENG_AZOAI_SDK` | Interface principal do SDK |
| `ZIF_PENG_AZOAI_SDK_CONFIG` | Configuração do SDK |
| `ZIF_PENG_AZOAI_SDK_TYPES` | Tipos de dados |
| `ZIF_PENG_AZOAI_SDK_CONSTANTS` | Constantes do SDK |

### Tipos de Dados Importantes

#### Chat Completion Input:
```abap
TYPES: BEGIN OF ty_chatcompletion_input,
         messages     TYPE TABLE OF ty_chatmessage,
         max_tokens   TYPE i,
         temperature  TYPE string,
         top_p        TYPE string,
         n            TYPE i,
         stream       TYPE abap_bool,
         stop         TYPE string,
         presence_penalty  TYPE string,
         frequency_penalty TYPE string,
       END OF ty_chatcompletion_input.
```

#### Chat Message:
```abap
TYPES: BEGIN OF ty_chatmessage,
         role    TYPE string,  " user, assistant, system
         content TYPE string,
       END OF ty_chatmessage.
```

### Códigos de Erro Comuns

| Código | Descrição | Ação |
|--------|-----------|-------|
| 400 | Bad Request | Verificar parâmetros de entrada |
| 401 | Unauthorized | Verificar chave de API |
| 403 | Forbidden | Verificar permissões |
| 404 | Not Found | Verificar deployment/modelo |
| 429 | Rate Limit | Implementar retry com backoff |
| 500 | Server Error | Tentar novamente mais tarde |

---

## 📞 Suporte e Recursos Adicionais

### Documentação Oficial
- [Microsoft AI SDK for SAP Documentation](https://microsoft.github.io/aisdkforsapabap/)
- [Azure OpenAI Service](https://azure.microsoft.com/services/cognitive-services/openai-service/)

### Comunidade
- [Discussion Forum](https://github.com/microsoft/aisdkforsapabap/discussions)
- [Issues/Bug reporting](https://github.com/microsoft/aisdkforsapabap/issues)

### Demos Incluídas
O SDK inclui vários programas de demonstração:
- `ZP_AISDKDEMO_CHATCOMPL_SIMPLE` - Chat completion simples
- `ZP_MSAISDKDEMO_MODELS` - Listagem de modelos
- `ZP_MSAISDKDEMO_DEPLOYMENTS` - Gerenciamento de deployments
- `ZP_AISDKDEMO_EMBEDDINGS` - Criação de embeddings

---

**Desenvolvido por**: Microsoft Platform Engineering Team  
**Versão**: 2.0  
**Última atualização**: 2024

*Este SDK é fornecido como parte da iniciativa Microsoft AI SDK for SAP ABAP v2.0*