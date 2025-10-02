*&---------------------------------------------------------------------*
*& Report ZP_MSAISDKDEMO_MODELS_OAI
*&---------------------------------------------------------------------*
*& Programa de Demonstração: Operações com Modelos do OpenAI
*&---------------------------------------------------------------------*
*& Descrição:
*& Este programa demonstra como utilizar o SDK do Microsoft Azure OpenAI
*& para SAP ABAP para realizar operações relacionadas a modelos de IA.
*&
*& Funcionalidades principais:
*& 1. Listar todos os modelos disponíveis na API do OpenAI
*& 2. Obter informações detalhadas de um modelo específico
*&
*& Pré-requisitos:
*& - URL da API do OpenAI (p_url)
*& - Versão da API (p_ver)
*& - Chave de autenticação da API (p_key)
*&
*& Autor: Microsoft PENGG Team
*& Data: 2023
*&---------------------------------------------------------------------*
REPORT zp_msaisdkdemo_models_oai.

*&---------------------------------------------------------------------*
*& INCLUDES - Arquivos de inclusão
*&---------------------------------------------------------------------*
* Inclui os parâmetros comuns de entrada (URL do endpoint, versão da API, chave de autenticação)
INCLUDE zp_msaisdkdemo_params_top_oai.  "Parâmetros de entrada comuns (AI End Point, Version, Key)

* Inclui as declarações de dados comuns usadas em todos os programas de demonstração
INCLUDE zp_msaisdkdemo_common.      "Declarações de dados comuns (Instância SDK, código de status, razão do status, string JSON de retorno, erro)

*&---------------------------------------------------------------------*
*& DECLARAÇÕES DE DADOS - Variáveis específicas deste programa
*&---------------------------------------------------------------------*
DATA:
  " Estrutura para armazenar a lista completa de modelos disponíveis
  " Esta variável conterá uma tabela interna com informações de todos os modelos
  " que podem ser utilizados através da API do OpenAI
  model_list TYPE zif_peng_azoai_sdk_types=>ty_model_list,

  " Estrutura para armazenar informações detalhadas de um modelo específico
  " Contém dados como ID do modelo, capacidades, status de deprecação,
  " proprietário, data de atualização, e outras propriedades do modelo
  model_get  TYPE zif_peng_azoai_sdk_types=>ty_model_get.


*&---------------------------------------------------------------------*
*& INÍCIO DA SELEÇÃO - Ponto de entrada principal do programa
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  TRY.
*&---------------------------------------------------------------------*
*& ETAPA 1: Inicialização do SDK
*&---------------------------------------------------------------------*
* Cria uma instância do Microsoft AI SDK para SAP ABAP.
* Esta é a primeira etapa obrigatória para qualquer operação com a API do OpenAI.
*
* O Factory Pattern é utilizado para criar a instância apropriada do SDK:
* - zcl_peng_azoai_sdk_factory=>get_instance(): Obtém a instância da fábrica
* - get_sdk(): Cria e retorna uma instância do SDK configurada
*
* Parâmetros de configuração:
* - api_version: Versão da API a ser utilizada (ex: 'v1')
* - api_base: URL base da API do OpenAI (ex: 'https://api.openai.com')
* - api_type: Tipo de API - neste caso, OpenAI (não Azure OpenAI)
* - api_key: Chave de autenticação fornecida pelo OpenAI
*
* A instância criada (sdk_instance) será usada para todas as operações subsequentes.
      sdk_instance = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
                                                            api_version = p_ver
                                                            api_base    = p_url
                                                            api_type    = zif_peng_azoai_sdk_constants=>c_apitype-openai
                                                            api_key     = p_key
                                                          ).
*&---------------------------------------------------------------------*
*& ETAPA 2: Listar Todos os Modelos Disponíveis (Models - List)
*&---------------------------------------------------------------------*
* Esta operação recupera a lista completa de todos os modelos disponíveis
* na API do OpenAI. Os modelos incluem diferentes capacidades como:
* - Modelos de linguagem (GPT-3.5, GPT-4, etc.)
* - Modelos de embeddings (text-embedding-ada-002, etc.)
* - Modelos de chat completion
* - Modelos legados (text-davinci-003, text-curie-001, etc.)
*
* Método utilizado: sdk_instance->model()->list()
*
* Parâmetros de saída (IMPORTING):
* - ov_statuscode: Código de status HTTP da resposta (ex: 200 para sucesso)
* - ov_statusreason: Descrição textual do status HTTP (ex: "OK")
* - ov_json: String JSON completa retornada pela API, útil para análise detalhada
* - ov_model: Lista de modelos convertida para tipo ABAP (model_list)
*              Cada entrada contém: ID, capacidades, proprietário, status, etc.
* - ov_error: Estrutura de erro caso ocorra algum problema na comunicação
*
* Após a execução, examine a variável 'model_list' no debugger para ver
* todos os modelos disponíveis e suas propriedades.
      sdk_instance->model( )->list(
        IMPORTING
          ov_statuscode   = status_code    " Código de status HTTP
          ov_statusreason = status_reason  " Descrição do status HTTP
          ov_json         = returnjson     " String JSON retornada pela API
          ov_model        = model_list     " Lista de modelos (tipo: zif_peng_azoai_sdk_types=>ty_model_list)
          ov_error        = error          " Erro, se ocorrido (tipo: zif_peng_azoai_sdk_types=>ty_error)
      ).
********************************************************************************
      " Ponto de parada para depuração - permite inspecionar os resultados
      " Examine 'model_list' para ver todos os modelos disponíveis
      BREAK-POINT.

*&---------------------------------------------------------------------*
*& ETAPA 3: Obter Detalhes de um Modelo Específico (Models - Get)
*&---------------------------------------------------------------------*
* Esta operação recupera informações detalhadas sobre um modelo específico
* identificado pelo seu ID (model ID).
*
* Neste exemplo, estamos consultando o modelo 'text-davinci-003', que é um
* modelo de linguagem da família GPT-3 da OpenAI, conhecido por:
* - Alta capacidade de compreensão de contexto
* - Geração de texto de alta qualidade
* - Adequado para tarefas de completion (completar textos)
*
* Método utilizado: sdk_instance->model()->get()
*
* Parâmetros de entrada (EXPORTING):
* - iv_modelid: Identificador único do modelo que se deseja consultar
*               Exemplos: 'text-davinci-003', 'gpt-3.5-turbo', 'gpt-4', etc.
*
* Parâmetros de saída (IMPORTING):
* - ov_statuscode: Código de status HTTP (200 = sucesso, 404 = modelo não encontrado)
* - ov_statusreason: Descrição do status HTTP
* - ov_json: String JSON completa com todas as informações do modelo
* - ov_model: Estrutura ABAP contendo detalhes do modelo:
*   * id: Identificador do modelo
*   * object: Tipo de objeto (geralmente "model")
*   * owned_by: Proprietário do modelo (ex: "openai")
*   * status: Status do modelo (active, deprecated, etc.)
*   * created_at/updated_at: Timestamps de criação e atualização
*   * capabilities: Capacidades do modelo (completion, embeddings, etc.)
*   * deprecation: Informações sobre deprecação, se aplicável
* - ov_error: Estrutura de erro caso o modelo não seja encontrado ou ocorra erro
*
* Após a execução, examine 'model_get' para ver todas as propriedades do modelo.
      sdk_instance->model( )->get(
        EXPORTING
          iv_modelid      = 'text-davinci-003'            " ID do modelo a ser consultado
        IMPORTING
          ov_statuscode   = status_code                   " Código de status HTTP
          ov_statusreason = status_reason                 " Descrição do status HTTP
          ov_json         = returnjson                    " String JSON retornada pela API
          ov_model        = model_get                     " Detalhes do modelo (tipo: zif_peng_azoai_sdk_types=>ty_model_get)
          ov_error        = error                         " Erro, se ocorrido
      ).
********************************************************************************
      " Ponto de parada para depuração - permite inspecionar os detalhes do modelo
      " Examine 'model_get' para ver todas as propriedades do modelo consultado
      BREAK-POINT.

*&---------------------------------------------------------------------*
*& TRATAMENTO DE EXCEÇÕES
*&---------------------------------------------------------------------*
* Captura e trata exceções específicas do SDK do Azure OpenAI para ABAP.
*
* A classe de exceção zcx_peng_azoai_sdk_exception é lançada quando:
* - Há problemas de conectividade com a API (timeout, rede indisponível)
* - A chave de autenticação (api_key) é inválida ou expirada
* - A URL do endpoint está incorreta ou inacessível
* - Parâmetros obrigatórios estão faltando ou são inválidos
* - A API retorna erros (limites de taxa excedidos, modelo não encontrado, etc.)
* - Há problemas na serialização/deserialização de dados JSON
*
* Quando uma exceção é capturada:
* - O objeto de exceção é armazenado na variável 'ex'
* - A mensagem de erro é exibida ao usuário através de MESSAGE tipo 'I' (informativo)
* - O programa não é interrompido abruptamente, permitindo tratamento adequado
*
* Boas práticas:
* - Sempre examine o conteúdo de 'error' antes de usar os dados retornados
* - Verifique 'status_code' para confirmar sucesso (200-299)
* - Em produção, considere log de erros em vez de apenas exibir mensagem
    CATCH zcx_peng_azoai_sdk_exception INTO DATA(ex).
      " Exceção do SDK do Azure OpenAI para ABAP
      " Exibe a mensagem de erro para o usuário de forma informativa
      MESSAGE ex TYPE 'I'.
  ENDTRY.
