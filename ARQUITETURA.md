# Arquitetura do Microsoft AI SDK para SAP ABAP v2.0

## 🏗️ Visão Geral da Arquitetura

Este documento detalha a arquitetura técnica do Microsoft AI SDK para SAP ABAP v2.0, explicando os componentes, padrões de design e fluxos de dados implementados.

---

## 📊 Diagrama de Arquitetura Geral

```
┌─────────────────────────────────────────────────────────────────┐
│                    APLICAÇÕES ABAP                             │
├─────────────────────────────────────────────────────────────────┤
│  Programas Demo  │  Classes Cliente  │  Relatórios  │  Forms   │
└─────────────────┬───────────────────┬─────────────┬─────────────┘
                  │                   │             │
                  ▼                   ▼             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    CAMADA SDK - INTERFACE                      │
├─────────────────────────────────────────────────────────────────┤
│           zif_peng_azoai_centralcontrol (Interface Principal)   │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Chat           │  │  Completions    │  │  Embeddings     │ │
│  │  Completions    │  │                 │  │                 │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │  Files          │  │  Fine-tunes     │  │  Models         │ │
│  │  Management     │  │                 │  │                 │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                    CAMADA SDK - FACTORY                        │
├─────────────────────────────────────────────────────────────────┤
│              zcl_peng_azoai_sdk_factory                         │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │              Factory Method Pattern                       │ │
│  │                                                           │ │
│  │  get_instance() → get_sdk() → Configuração → Instância   │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                  CAMADA SDK - IMPLEMENTAÇÃO                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐           ┌─────────────────┐             │
│  │   Azure OpenAI  │           │     OpenAI      │             │
│  │   Implementation│           │  Implementation │             │
│  │                 │           │                 │             │
│  │ ┌─────────────┐ │           │ ┌─────────────┐ │             │
│  │ │   Chat      │ │           │ │   Chat      │ │             │
│  │ │ Completion  │ │           │ │ Completion  │ │             │
│  │ └─────────────┘ │           │ └─────────────┘ │             │
│  │                 │           │                 │             │
│  │ ┌─────────────┐ │           │ ┌─────────────┐ │             │
│  │ │ Embeddings  │ │           │ │ Embeddings  │ │             │
│  │ └─────────────┘ │           │ └─────────────┘ │             │
│  │                 │           │                 │             │
│  │ ┌─────────────┐ │           │ ┌─────────────┐ │             │
│  │ │ Fine-tuning │ │           │ │ Fine-tuning │ │             │
│  │ └─────────────┘ │           │ └─────────────┘ │             │
│  └─────────────────┘           └─────────────────┘             │
└─────────────────┬───────────────────┬───────────────────────────┘
                  │                   │
                  ▼                   ▼
┌─────────────────────────────────────────────────────────────────┐
│                   CAMADA COMUNICAÇÃO                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │   URL Provider  │  │  HTTP Client    │  │ Error Handling  │ │
│  │                 │  │                 │  │                 │ │
│  │ ┌─────────────┐ │  │ ┌─────────────┐ │  │ ┌─────────────┐ │ │
│  │ │Azure URLs   │ │  │ │SSL/TLS      │ │  │ │Exceptions   │ │ │
│  │ └─────────────┘ │  │ └─────────────┘ │  │ └─────────────┘ │ │
│  │                 │  │                 │  │                 │ │
│  │ ┌─────────────┐ │  │ ┌─────────────┐ │  │ ┌─────────────┐ │ │
│  │ │OpenAI URLs  │ │  │ │Headers      │ │  │ │Status Codes │ │ │
│  │ └─────────────┘ │  │ └─────────────┘ │  │ └─────────────┘ │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────┬───────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                      APIS EXTERNAS                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────┐         ┌─────────────────────┐       │
│  │    Azure OpenAI     │         │       OpenAI        │       │
│  │                     │         │                     │       │
│  │ api.openai.azure.com│         │  api.openai.com     │       │
│  │                     │         │                     │       │
│  │ ┌─────────────────┐ │         │ ┌─────────────────┐ │       │
│  │ │   Chat/GPT-4    │ │         │ │   Chat/GPT-4    │ │       │
│  │ │   GPT-3.5-turbo │ │         │ │   GPT-3.5-turbo │ │       │
│  │ └─────────────────┘ │         │ └─────────────────┘ │       │
│  │                     │         │                     │       │
│  │ ┌─────────────────┐ │         │ ┌─────────────────┐ │       │
│  │ │   Embeddings    │ │         │ │   Embeddings    │ │       │
│  │ │   ada-002       │ │         │ │   ada-002       │ │       │
│  │ └─────────────────┘ │         │ └─────────────────┘ │       │
│  └─────────────────────┘         └─────────────────────┘       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🧩 Componentes Principais

### 1. 🏭 Factory Layer (Camada de Fábrica)

#### `zcl_peng_azoai_sdk_factory`
- **Responsabilidade**: Criar instâncias do SDK baseado na configuração
- **Padrão**: Singleton + Factory Method
- **Localização**: `/src/zpengg_ai_openai_main/zpengg_ai_openai_azure/zpengg_ai_openai_azure_sdk/`

```abap
" Uso típico do Factory
DATA(lo_sdk) = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
  api_version = '2024-02-15-preview'
  api_base    = 'https://recurso.openai.azure.com/'
  api_type    = zif_peng_azoai_sdk_constants=>c_apitype-azureopenai
  api_key     = 'sua-chave-api'
).
```

**Características**:
- ✅ Singleton pattern para eficiência
- ✅ Configuração flexível para diferentes provedores
- ✅ Validação de parâmetros
- ✅ Tratamento de erros robusto

### 2. 🎯 Interface Central

#### `zif_peng_azoai_centralcontrol`
- **Responsabilidade**: Interface principal para todas as operações de IA
- **Padrão**: Facade Pattern
- **Métodos Principais**:
  - `chat_completions()` - Chat e conversação
  - `completions()` - Completamento de texto
  - `embeddings()` - Representações vetoriais
  - `files()` - Gerenciamento de arquivos
  - `fine_tunes()` - Modelos personalizados

### 3. 🔧 Componentes Especializados

#### Chat Completions
```abap
" Estrutura do componente
INTERFACE zif_peng_azoai_sdk_comp_chtcmpl
  METHODS: create
    IMPORTING
      deploymentid TYPE string
      prompts      TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_input
    IMPORTING
      statuscode   TYPE i
      statusreason TYPE string
      response     TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_output
      json         TYPE string
      error        TYPE zif_peng_azoai_sdk_types=>ty_error_response.
```

#### Embeddings
```abap
" Estrutura do componente
INTERFACE zif_peng_azoai_sdk_comp_embed
  METHODS: create
    IMPORTING
      deploymentid TYPE string
      prompts      TYPE zif_peng_azoai_sdk_types=>ty_embeddings_input
    IMPORTING
      statuscode   TYPE i
      response     TYPE zif_peng_azoai_sdk_types=>ty_embeddings_output.
```

---

## 🔄 Padrões de Design Implementados

### 1. 🏭 Factory Method Pattern
**Implementação**: `zcl_peng_azoai_sdk_factory`
**Benefícios**:
- Criação centralizada de objetos
- Configuração flexível
- Ocultação da complexidade de instanciação

### 2. 🎭 Facade Pattern
**Implementação**: `zif_peng_azoai_centralcontrol`
**Benefícios**:
- Interface simplificada para operações complexas
- Desacoplamento entre cliente e implementação
- Facilita manutenção e evolução

### 3. 🎯 Strategy Pattern
**Implementação**: Diferentes provedores (Azure OpenAI vs OpenAI)
**Benefícios**:
- Algoritmos intercambiáveis
- Extensibilidade para novos provedores
- Isolamento de implementações específicas

### 4. 🏗️ Template Method Pattern
**Implementação**: Classes base para operações comuns
**Benefícios**:
- Reutilização de código
- Estrutura consistente
- Facilita implementação de novos componentes

### 5. 🔗 Dependency Injection
**Implementação**: Configuração via parâmetros
**Benefícios**:
- Baixo acoplamento
- Facilita testes
- Configuração flexível

---

## 📦 Estrutura de Pacotes

### Hierarquia de Pacotes
```
ZPENGG_AI_OPENAI_MAIN (Raiz)
├── ZPENGG_AI_OPENAI (OpenAI Implementation)
│   ├── ZPENGG_OAI_DEMOS (Demonstrações)
│   ├── ZPENGG_OAI_SDK_CORE (Núcleo OpenAI)
│   └── ZPENGG_OAI_SDK_V1 (Implementação v1)
├── ZPENGG_AI_OPENAI_AZURE (Azure OpenAI Implementation)
│   └── ZPENGG_AI_OPENAI_AZURE_SDK
│       └── ZPENGG_AZOAI_SDK_CORE (Núcleo Azure)
└── ZPENGG_AI_OPENAI_UTILS (Utilitários Compartilhados)
```

### Responsabilidades por Pacote

#### 📚 ZPENGG_OAI_DEMOS
- **Conteúdo**: 14 programas de demonstração
- **Responsabilidade**: Exemplos práticos de uso
- **Arquivos Principais**:
  - `zp_aisdkdemo_chtcmpl_smpl_oai` - Chat completion simples
  - `zp_msaisdkdemo_completion_oai` - Text completion com GUI
  - `zp_aisdkdemo_embeddings_oai` - Demonstração de embeddings

#### ⚙️ ZPENGG_AZOAI_SDK_CORE
- **Conteúdo**: 15+ classes principais
- **Responsabilidade**: Implementação core do Azure OpenAI
- **Arquivos Principais**:
  - `zcl_peng_azoai_sdk_factory` - Factory principal
  - `zif_peng_azoai_centralcontrol` - Interface central
  - `zcl_peng_azoai_urlprovider` - Provedor de URLs

#### 🔧 ZPENGG_AI_OPENAI_UTILS
- **Conteúdo**: Utilitários compartilhados
- **Responsabilidade**: Funcionalidades comuns
- **Arquivos Principais**:
  - `zcl_peng_aisdk_templprovider` - Provedor de templates
  - `zif_peng_aisdk_endpt_provider` - Interface para endpoints

---

## 🌐 Fluxo de Dados

### 1. 📤 Fluxo de Request

```
Cliente ABAP
    │
    ▼ (1) Configuração
Factory
    │
    ▼ (2) Criação
SDK Instance
    │
    ▼ (3) Chamada
Component (Chat/Embed/etc)
    │
    ▼ (4) Serialização
JSON Payload
    │
    ▼ (5) HTTP Request
HTTP Client
    │
    ▼ (6) Rede
API Externa (Azure/OpenAI)
```

### 2. 📥 Fluxo de Response

```
API Externa
    │
    ▼ (1) HTTP Response
HTTP Client
    │
    ▼ (2) Validação
Status Code Check
    │
    ▼ (3) Deserialização
JSON Parser
    │
    ▼ (4) Mapeamento
ABAP Structures
    │
    ▼ (5) Entrega
Cliente ABAP
```

### 3. ⚠️ Fluxo de Erro

```
Erro Detectado
    │
    ▼
Exception Handler
    │
    ├─ (HTTP Error) ─▼─ zcx_peng_azoai_sdk_exception
    ├─ (JSON Error) ─▼─ zcx_peng_azoai_sdk_exception  
    └─ (API Error)  ─▼─ ty_error_response
                       │
                       ▼
                   Cliente ABAP
```

---

## 🔒 Segurança e Autenticação

### Mecanismos de Autenticação

#### 1. 🔑 API Key Authentication
```abap
" Configuração de chave API
DATA(lv_api_key) = 'sua-chave-secreta'.

" Headers HTTP configurados automaticamente
Authorization: Bearer {api_key}        " Para OpenAI
api-key: {api_key}                     " Para Azure OpenAI
```

#### 2. 🌐 HTTPS Obrigatório
- Todas as comunicações via SSL/TLS
- Validação de certificados
- Configuração via STRUST (SAP)

#### 3. 🛡️ Validação de Input
```abap
" Validações implementadas
IF lv_api_key IS INITIAL.
  RAISE EXCEPTION TYPE zcx_peng_azoai_sdk_exception
    MESSAGE 'API key é obrigatória'.
ENDIF.

IF lv_endpoint IS INITIAL.
  RAISE EXCEPTION TYPE zcx_peng_azoai_sdk_exception
    MESSAGE 'Endpoint é obrigatório'.
ENDIF.
```

---

## 📊 Tipos de Dados e Estruturas

### Estruturas Principais

#### Chat Completion Input
```abap
TYPES: BEGIN OF ty_chatcompletion_input,
         messages        TYPE TABLE OF ty_message,
         temperature     TYPE string,
         max_tokens      TYPE i,
         top_p          TYPE string,
         frequency_penalty TYPE string,
         presence_penalty  TYPE string,
         stop           TYPE TABLE OF string,
       END OF ty_chatcompletion_input.
```

#### Chat Message
```abap
TYPES: BEGIN OF ty_message,
         role     TYPE string,  " system, user, assistant
         content  TYPE string,  " Conteúdo da mensagem
         name     TYPE string,  " Nome do remetente (opcional)
       END OF ty_message.
```

#### Embeddings Input
```abap
TYPES: BEGIN OF ty_embeddings_input,
         input    TYPE string,  " Texto para embedding
         user     TYPE string,  " ID do usuário (opcional)
       END OF ty_embeddings_input.
```

#### Response Structures
```abap
TYPES: BEGIN OF ty_chatcompletion_output,
         id       TYPE string,
         object   TYPE string,
         created  TYPE i,
         model    TYPE string,
         choices  TYPE TABLE OF ty_choice,
         usage    TYPE ty_usage,
       END OF ty_chatcompletion_output.
```

---

## 🔌 Extensibilidade

### 1. 🆕 Adicionando Novos Provedores

#### Passos para Extensão:
1. **Implementar Interface**: `zif_peng_azoai_centralcontrol`
2. **Criar URL Provider**: Para endpoints específicos
3. **Implementar Componentes**: Chat, Embeddings, etc.
4. **Atualizar Factory**: Para suportar novo provedor
5. **Testes**: Criar programas de demonstração

#### Exemplo de Implementação:
```abap
CLASS zcl_novo_provedor_sdk DEFINITION
  PUBLIC
  CREATE PUBLIC
  GLOBAL FRIENDS zcl_peng_azoai_sdk_factory.

  PUBLIC SECTION.
    INTERFACES: zif_peng_azoai_centralcontrol.
    
  PRIVATE SECTION.
    DATA: mv_api_key    TYPE string,
          mv_endpoint   TYPE string,
          mv_version    TYPE string.
          
ENDCLASS.
```

### 2. 🔧 Customização de Componentes

#### Template Method Pattern:
```abap
CLASS zcl_base_component DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS: execute_request ABSTRACT
      IMPORTING
        iv_payload TYPE string
      RETURNING
        VALUE(rv_response) TYPE string.
        
  PROTECTED SECTION.
    METHODS: 
      validate_input,
      prepare_headers,
      process_response.
ENDCLASS.
```

---

## 📈 Performance e Otimização

### 1. ⚡ Otimizações Implementadas

#### Connection Pooling
- Reutilização de conexões HTTP
- Configuração via `cl_http_client`

#### Caching (Para Implementar)
```abap
" Exemplo de estrutura para cache
TYPES: BEGIN OF ty_cache_entry,
         key        TYPE string,
         response   TYPE string,
         timestamp  TYPE timestamp,
         expires    TYPE timestamp,
       END OF ty_cache_entry.
```

#### Timeout Configuration
```abap
" Configurações de timeout recomendadas
lo_http_client->set_timeout( timeout = 60 ).  " 60 segundos
```

### 2. 📊 Monitoramento

#### Métricas Importantes:
- **Latência**: Tempo de resposta das APIs
- **Tokens**: Uso de tokens por request
- **Rate Limits**: Limites de uso da API
- **Errors**: Taxa de erro e tipos

#### Logging Estruturado:
```abap
" Exemplo de log estruturado
MESSAGE i001(zai_sdk) WITH 
  'Request completed'
  lv_status_code
  lv_tokens_used
  lv_duration_ms.
```

---

## 🧪 Estratégia de Testes

### 1. 🔍 Tipos de Teste

#### Unit Tests
- Testes isolados de componentes
- Mock de APIs externas
- Validação de lógica de negócio

#### Integration Tests
- Testes com APIs reais
- Validação de conectividade
- Testes de configuração

#### Performance Tests
- Teste de carga
- Medição de latência
- Teste de limites

### 2. 🎯 Test Doubles

#### Mock Factory
```abap
CLASS zcl_mock_sdk_factory DEFINITION.
  PUBLIC SECTION.
    INTERFACES: zif_peng_azoai_centralcontrol.
    
    " Métodos para configurar respostas mock
    METHODS: set_mock_response
      IMPORTING
        iv_response TYPE string.
        
ENDCLASS.
```

---

## 🚀 Roadmap de Arquitetura

### Versão Atual (2.0)
- ✅ Suporte Azure OpenAI e OpenAI
- ✅ Chat Completions
- ✅ Text Completions  
- ✅ Embeddings
- ✅ File Management
- ✅ Fine-tuning

### Próximas Versões
- 🔄 **Cache Layer**: Para otimização de performance
- 🔄 **Async Processing**: Para operações longas
- 🔄 **Batch Operations**: Para múltiplos requests
- 🔄 **Monitoring Dashboard**: Para métricas em tempo real
- 🔄 **New Providers**: Hugging Face, Anthropic, etc.

---

## 💡 Considerações Técnicas

### 1. 📝 Limitações Atuais
- Operações síncronas apenas
- Sem cache implementado
- Logging básico
- Configuração manual de certificados

### 2. 🎯 Boas Práticas Recomendadas
- Use o Factory pattern sempre
- Implemente tratamento de erro robusto
- Configure timeouts apropriados
- Monitore uso de tokens
- Teste em ambiente não-produtivo

### 3. 🔧 Configurações Avançadas
```abap
" Configuração avançada do HTTP client
lo_client->propertytype_logon_popup = if_http_client=>co_disabled.
lo_client->propertytype_accept_cookie = if_http_client=>co_enabled.
lo_client->propertytype_accept_compression = if_http_client=>co_enabled.
```

---

## 📚 Recursos Adicionais

### 📖 Documentação Relacionada
- [Guia de Instalação](INSTALACAO.md)
- [Exemplos Práticos](EXEMPLOS.md)
- [README Principal](README_PT-BR.md)

### 🌐 Links Externos
- [Azure OpenAI Documentation](https://docs.microsoft.com/azure/cognitive-services/openai/)
- [OpenAI API Documentation](https://platform.openai.com/docs/api-reference)
- [SAP ABAP Documentation](https://help.sap.com/abap)

---

*Esta documentação de arquitetura foi criada para fornecer uma visão técnica completa do Microsoft AI SDK para SAP ABAP v2.0. Para questões técnicas específicas, consulte o código-fonte ou a documentação oficial.*

**[⬆️ Voltar ao Guia Principal](README_PT-BR.md)**