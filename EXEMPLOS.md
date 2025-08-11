# Guia de Exemplos Práticos - Microsoft AI SDK para SAP ABAP v2.0

## 🎯 Visão Geral

Este documento apresenta exemplos práticos detalhados de como usar o Microsoft AI SDK para SAP ABAP v2.0, com código comentado em português e casos de uso empresariais reais.

---

## 🗨️ Chat Completion - Assistente Inteligente

### 📝 Exemplo 1: Assistente de Desenvolvimento ABAP

Este exemplo mostra como criar um assistente que ajuda desenvolvedores ABAP a escrever código melhor.

```abap
*&---------------------------------------------------------------------*
*& Report ZP_ASSISTENTE_ABAP_EXEMPLO
*&---------------------------------------------------------------------*
*& Demonstração: Assistente inteligente para desenvolvimento ABAP
*&---------------------------------------------------------------------*
REPORT zp_assistente_abap_exemplo.

" Includes necessários para parâmetros comuns
INCLUDE zp_msaisdkdemo_params_top_oai.  " Parâmetros de conexão
INCLUDE zp_msaisdkdemo_common.          " Declarações comuns

" Parâmetros específicos do assistente
PARAMETERS:
  p_depid  TYPE string OBLIGATORY LOWER CASE DEFAULT 'gpt-35-turbo',
  p_prompt TYPE string OBLIGATORY LOWER CASE.

" Estruturas para chat completion
DATA:
  ls_input  TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_input,
  ls_output TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_output.

START-OF-SELECTION.

  TRY.
      " ========================================
      " 1. Criar instância do SDK
      " ========================================
      sdk_instance = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
        api_version = p_ver      " Versão da API (ex: 2024-02-15-preview)
        api_base    = p_url      " Endpoint (ex: https://recurso.openai.azure.com/)
        api_type    = zif_peng_azoai_sdk_constants=>c_apitype-azureopenai
        api_key     = p_key      " Chave de API
      ).

      " ========================================
      " 2. Configurar Sistema (Personalidade da IA)
      " ========================================
      APPEND INITIAL LINE TO ls_input-messages ASSIGNING FIELD-SYMBOL(<fs_message>).
      <fs_message>-role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-system.
      <fs_message>-content = 
        |Você é um especialista em desenvolvimento SAP ABAP com mais de 15 anos de experiência. | &
        |Suas respostas devem ser: | &
        |1. Tecnicamente precisas e seguir melhores práticas ABAP | &
        |2. Incluir comentários em português no código | &
        |3. Considerar performance e manutenibilidade | &
        |4. Usar padrões modernos do ABAP (quando disponível) | &
        |5. Ser didáticas e explicativas|.

      " ========================================
      " 3. Adicionar Pergunta do Usuário
      " ========================================
      APPEND INITIAL LINE TO ls_input-messages ASSIGNING <fs_message>.
      <fs_message>-role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-user.
      <fs_message>-content = p_prompt.

      " ========================================
      " 4. Configurar Parâmetros de Qualidade
      " ========================================
      ls_input-temperature = '0.3'.     " Baixa criatividade, alta consistência
      ls_input-max_tokens = 1500.       " Limite de tokens na resposta
      ls_input-top_p = '0.9'.           " Diversidade controlada

      " ========================================
      " 5. Executar Chat Completion
      " ========================================
      sdk_instance->chat_completions( )->create(
        EXPORTING
          deploymentid = p_depid
          prompts      = ls_input
        IMPORTING
          statuscode   = status_code
          statusreason = status_reason
          json         = returnjson
          response     = ls_output
          error        = error
      ).

      " ========================================
      " 6. Processar Resposta
      " ========================================
      IF status_code = 200.
        " Sucesso - mostrar resposta
        WRITE: / '🤖 Assistente ABAP respondeu:'.
        WRITE: / ''.
        
        LOOP AT ls_output-choices INTO DATA(ls_choice).
          " Quebrar resposta em linhas para melhor visualização
          DATA(lv_response) = ls_choice-message-content.
          
          " Dividir em linhas de até 120 caracteres
          WHILE strlen( lv_response ) > 120.
            DATA(lv_pos) = 120.
            WHILE lv_pos > 0 AND lv_response+lv_pos(1) <> ' '.
              lv_pos = lv_pos - 1.
            ENDWHILE.
            
            IF lv_pos = 0.
              lv_pos = 120.
            ENDIF.
            
            WRITE: / lv_response(lv_pos).
            lv_response = lv_response+lv_pos.
          ENDWHILE.
          
          IF strlen( lv_response ) > 0.
            WRITE: / lv_response.
          ENDIF.
        ENDLOOP.
        
        " Mostrar estatísticas de uso
        WRITE: / ''.
        WRITE: / '📊 Estatísticas:'.
        WRITE: / '   Tokens usados:', ls_output-usage-total_tokens.
        WRITE: / '   Tempo de resposta: ~', ls_output-created, 'ms'.
        
      ELSE.
        " Erro - mostrar detalhes
        WRITE: / '❌ Erro na chamada da API:'.
        WRITE: / '   Status Code:', status_code.
        WRITE: / '   Reason:', status_reason.
        IF error IS NOT INITIAL.
          WRITE: / '   Detalhes:', error-error-message.
        ENDIF.
      ENDIF.

    CATCH zcx_peng_azoai_sdk_exception INTO DATA(lx_exception).
      " Tratamento de exceções do SDK
      WRITE: / '💥 Exceção do SDK capturada:'.
      WRITE: / lx_exception->get_text( ).
      
  ENDTRY.
```

### 🎯 Exemplo de Uso
**Pergunta**: "Como criar uma função que calcule a diferença em dias entre duas datas?"

**Resposta Esperada**: Código ABAP completo com validações, tratamento de erro e comentários em português.

---

## 📊 Embeddings - Análise Semântica

### 📝 Exemplo 2: Classificador de Documentos Empresariais

```abap
*&---------------------------------------------------------------------*
*& Report ZP_CLASSIFICADOR_DOCUMENTOS
*&---------------------------------------------------------------------*
*& Demonstração: Classificação automática usando embeddings
*&---------------------------------------------------------------------*
REPORT zp_classificador_documentos.

INCLUDE zp_msaisdkdemo_params_top_oai.
INCLUDE zp_msaisdkdemo_common.

" Parâmetros específicos
PARAMETERS:
  p_depid TYPE string OBLIGATORY DEFAULT 'text-embedding-ada-002',
  p_texto TYPE string OBLIGATORY LOWER CASE.

" Tipos para embeddings
DATA:
  ls_embed_input  TYPE zif_peng_azoai_sdk_types=>ty_embeddings_input,
  ls_embed_output TYPE zif_peng_azoai_sdk_types=>ty_embeddings_output.

" Categorias predefinidas com seus embeddings (simplificado)
TYPES: BEGIN OF ty_categoria,
         nome        TYPE string,
         descricao   TYPE string,
         similaridade TYPE f,
       END OF ty_categoria.

DATA: lt_categorias TYPE TABLE OF ty_categoria.

START-OF-SELECTION.

  TRY.
      " ========================================
      " 1. Inicializar Categorias de Documentos
      " ========================================
      lt_categorias = VALUE #(
        ( nome = 'FISCAL' descricao = 'Documentos fiscais, notas, impostos' )
        ( nome = 'CONTRATO' descricao = 'Contratos, acordos, termos legais' )
        ( nome = 'RH' descricao = 'Recursos humanos, folha de pagamento' )
        ( nome = 'COMPRAS' descricao = 'Pedidos de compra, fornecedores' )
        ( nome = 'VENDAS' descricao = 'Vendas, clientes, propostas comerciais' )
        ( nome = 'FINANCEIRO' descricao = 'Relatórios financeiros, balanços' )
      ).

      " ========================================
      " 2. Criar instância do SDK
      " ========================================
      sdk_instance = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
        api_version = p_ver
        api_base    = p_url
        api_type    = zif_peng_azoai_sdk_constants=>c_apitype-azureopenai
        api_key     = p_key
      ).

      " ========================================
      " 3. Gerar Embedding do Texto de Entrada
      " ========================================
      ls_embed_input-input = p_texto.

      sdk_instance->embeddings( )->create(
        EXPORTING
          deploymentid = p_depid
          prompts      = ls_embed_input
        IMPORTING
          statuscode   = status_code
          statusreason = status_reason
          response     = ls_embed_output
          json         = returnjson
          error        = error
      ).

      IF status_code <> 200.
        MESSAGE |Erro ao gerar embedding: { status_reason }| TYPE 'E'.
        RETURN.
      ENDIF.

      " ========================================
      " 4. Classificação por Palavras-chave (Simplificado)
      " ========================================
      " Em um cenário real, você compararia os embeddings vetoriais
      " Aqui fazemos uma classificação simples por palavras-chave
      
      DATA(lv_texto_lower) = to_lower( p_texto ).
      
      WRITE: / '📋 Análise do Documento:'.
      WRITE: / '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'.
      WRITE: / 'Texto analisado:', p_texto.
      WRITE: / ''.

      " Análise por palavras-chave para cada categoria
      LOOP AT lt_categorias ASSIGNING FIELD-SYMBOL(<fs_categoria>).
        DATA(lv_score) = 0.
        
        " Lógica simples de pontuação por categoria
        CASE <fs_categoria>-nome.
          WHEN 'FISCAL'.
            IF lv_texto_lower CS 'nota fiscal' OR lv_texto_lower CS 'imposto' 
               OR lv_texto_lower CS 'icms' OR lv_texto_lower CS 'ipi'.
              lv_score = 85.
            ENDIF.
            
          WHEN 'CONTRATO'.
            IF lv_texto_lower CS 'contrato' OR lv_texto_lower CS 'acordo'
               OR lv_texto_lower CS 'cláusula' OR lv_texto_lower CS 'termo'.
              lv_score = 90.
            ENDIF.
            
          WHEN 'RH'.
            IF lv_texto_lower CS 'funcionário' OR lv_texto_lower CS 'salário'
               OR lv_texto_lower CS 'folha' OR lv_texto_lower CS 'férias'.
              lv_score = 80.
            ENDIF.
            
          WHEN 'COMPRAS'.
            IF lv_texto_lower CS 'pedido' OR lv_texto_lower CS 'fornecedor'
               OR lv_texto_lower CS 'compra' OR lv_texto_lower CS 'material'.
              lv_score = 75.
            ENDIF.
            
          WHEN 'VENDAS'.
            IF lv_texto_lower CS 'venda' OR lv_texto_lower CS 'cliente'
               OR lv_texto_lower CS 'proposta' OR lv_texto_lower CS 'faturamento'.
              lv_score = 70.
            ENDIF.
            
          WHEN 'FINANCEIRO'.
            IF lv_texto_lower CS 'balanço' OR lv_texto_lower CS 'resultado'
               OR lv_texto_lower CS 'receita' OR lv_texto_lower CS 'despesa'.
              lv_score = 82.
            ENDIF.
        ENDCASE.
        
        <fs_categoria>-similaridade = lv_score.
      ENDLOOP.

      " ========================================
      " 5. Mostrar Resultados da Classificação
      " ========================================
      SORT lt_categorias BY similaridade DESCENDING.
      
      WRITE: / '🎯 Classificação por Categoria:'.
      WRITE: / ''.
      
      DATA(lv_count) = 0.
      LOOP AT lt_categorias INTO DATA(ls_categoria) WHERE similaridade > 0.
        lv_count = lv_count + 1.
        
        " Emoji baseado na pontuação
        DATA(lv_emoji) = COND string(
          WHEN ls_categoria-similaridade >= 90 THEN '🥇'
          WHEN ls_categoria-similaridade >= 80 THEN '🥈'
          WHEN ls_categoria-similaridade >= 70 THEN '🥉'
          ELSE '📄'
        ).
        
        WRITE: / |{ lv_emoji } { ls_categoria-nome WIDTH = 12 }: { ls_categoria-similaridade WIDTH = 3 }% - { ls_categoria-descricao }|.
        
        " Mostrar apenas top 3
        IF lv_count >= 3.
          EXIT.
        ENDIF.
      ENDLOOP.
      
      " Categoria mais provável
      READ TABLE lt_categorias INTO ls_categoria INDEX 1.
      IF sy-subrc = 0 AND ls_categoria-similaridade > 50.
        WRITE: / ''.
        WRITE: / |✅ Classificação sugerida: { ls_categoria-nome }|.
      ELSE.
        WRITE: / ''.
        WRITE: / '❓ Categoria não identificada com confiança suficiente.'.
      ENDIF.

      " ========================================
      " 6. Informações Técnicas do Embedding
      " ========================================
      WRITE: / ''.
      WRITE: / '🔢 Informações Técnicas:'.
      IF ls_embed_output-data IS NOT INITIAL.
        READ TABLE ls_embed_output-data INTO DATA(ls_embedding_data) INDEX 1.
        IF sy-subrc = 0.
          WRITE: / '   Dimensões do vetor:', lines( ls_embedding_data-embedding ).
          WRITE: / '   Tokens processados:', ls_embed_output-usage-total_tokens.
        ENDIF.
      ENDIF.

    CATCH zcx_peng_azoai_sdk_exception INTO DATA(lx_exception).
      WRITE: / '💥 Erro no SDK:', lx_exception->get_text( ).
  ENDTRY.
```

---

## 🔄 Text Completion - Geração de Conteúdo

### 📝 Exemplo 3: Gerador de Documentação Automática

```abap
*&---------------------------------------------------------------------*
*& Report ZP_GERADOR_DOCUMENTACAO
*&---------------------------------------------------------------------*
*& Demonstração: Geração automática de documentação de código
*&---------------------------------------------------------------------*
REPORT zp_gerador_documentacao.

INCLUDE zp_msaisdkdemo_params_top_oai.
INCLUDE zp_msaisdkdemo_common.

PARAMETERS:
  p_depid TYPE string OBLIGATORY DEFAULT 'text-davinci-003',
  p_prog  TYPE program OBLIGATORY.

DATA:
  ls_input  TYPE zif_peng_azoai_sdk_types=>ty_completion_input,
  ls_output TYPE zif_peng_azoai_sdk_types=>ty_completion_output.

START-OF-SELECTION.

  TRY.
      " ========================================
      " 1. Ler código fonte do programa
      " ========================================
      READ REPORT p_prog INTO DATA(lt_source_code).
      
      IF sy-subrc <> 0.
        MESSAGE |Programa { p_prog } não encontrado| TYPE 'E'.
        RETURN.
      ENDIF.

      " Concatenar código em string única
      DATA(lv_source_code) = ||.
      LOOP AT lt_source_code INTO DATA(lv_line).
        lv_source_code = |{ lv_source_code }{ cl_abap_char_utilities=>newline }{ lv_line }|.
      ENDLOOP.

      " ========================================
      " 2. Criar instância do SDK
      " ========================================
      sdk_instance = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
        api_version = p_ver
        api_base    = p_url
        api_type    = zif_peng_azoai_sdk_constants=>c_apitype-openai
        api_key     = p_key
      ).

      " ========================================
      " 3. Construir Prompt para Documentação
      " ========================================
      ls_input-prompt = 
        |Analise o código ABAP abaixo e crie uma documentação técnica completa em português: | &
        |{ cl_abap_char_utilities=>newline }| &
        |{ cl_abap_char_utilities=>newline }| &
        |Código a documentar:| &
        |{ cl_abap_char_utilities=>newline }| &
        |```abap| &
        |{ lv_source_code }| &
        |```| &
        |{ cl_abap_char_utilities=>newline }| &
        |{ cl_abap_char_utilities=>newline }| &
        |Por favor, inclua:| &
        |{ cl_abap_char_utilities=>newline }| &
        |1. Propósito do programa| &
        |{ cl_abap_char_utilities=>newline }| &
        |2. Parâmetros de entrada| &
        |{ cl_abap_char_utilities=>newline }| &
        |3. Lógica principal| &
        |{ cl_abap_char_utilities=>newline }| &
        |4. Outputs esperados| &
        |{ cl_abap_char_utilities=>newline }| &
        |5. Dependências| &
        |{ cl_abap_char_utilities=>newline }| &
        |{ cl_abap_char_utilities=>newline }| &
        |Documentação:|.

      " ========================================
      " 4. Configurar Parâmetros de Completion
      " ========================================
      ls_input-max_tokens = 2000.      " Documentação pode ser extensa
      ls_input-temperature = '0.3'.     " Baixa criatividade, mais factual
      ls_input-top_p = '0.9'.
      ls_input-frequency_penalty = '0.1'. " Evitar repetições
      ls_input-presence_penalty = '0.1'.  " Encorajar novos tópicos

      " ========================================
      " 5. Executar Text Completion
      " ========================================
      sdk_instance->completions( )->create(
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

      " ========================================
      " 6. Processar e Exibir Documentação
      " ========================================
      IF status_code = 200.
        WRITE: / '📚 Documentação Gerada Automaticamente'.
        WRITE: / '═══════════════════════════════════════════════════════════'.
        WRITE: / 'Programa analisado:', p_prog.
        WRITE: / 'Data/Hora:', sy-datum, sy-uzeit.
        WRITE: / ''.

        " Mostrar documentação gerada
        LOOP AT ls_output-choices INTO DATA(ls_choice).
          DATA(lv_documentation) = ls_choice-text.
          
          " Dividir em linhas para exibição
          SPLIT lv_documentation AT cl_abap_char_utilities=>newline INTO TABLE DATA(lt_doc_lines).
          
          LOOP AT lt_doc_lines INTO DATA(lv_doc_line).
            " Limitar tamanho da linha para exibição
            WHILE strlen( lv_doc_line ) > 100.
              WRITE: / lv_doc_line(100).
              lv_doc_line = lv_doc_line+100.
            ENDWHILE.
            IF strlen( lv_doc_line ) > 0.
              WRITE: / lv_doc_line.
            ENDIF.
          ENDLOOP.
        ENDLOOP.

        " Estatísticas
        WRITE: / ''.
        WRITE: / '═══════════════════════════════════════════════════════════'.
        WRITE: / '📊 Estatísticas de Geração:'.
        WRITE: / 'Tokens utilizados:', ls_output-usage-total_tokens.
        WRITE: / 'Qualidade:', ls_choice-finish_reason.

        " ========================================
        " 7. Opcionalmente, Salvar Documentação
        " ========================================
        " Aqui você poderia salvar a documentação em uma tabela Z
        " ou gerar um arquivo texto, etc.

      ELSE.
        WRITE: / '❌ Erro na geração de documentação:'.
        WRITE: / 'Status:', status_code, status_reason.
      ENDIF.

    CATCH zcx_peng_azoai_sdk_exception INTO DATA(lx_exception).
      WRITE: / '💥 Erro no SDK:', lx_exception->get_text( ).
  ENDTRY.
```

---

## 🎯 Fine-tuning - Modelos Personalizados

### 📝 Exemplo 4: Preparação de Dados para Fine-tuning

```abap
*&---------------------------------------------------------------------*
*& Report ZP_PREPARAR_FINETUNING
*&---------------------------------------------------------------------*
*& Demonstração: Preparação de dados para fine-tuning de modelo
*&---------------------------------------------------------------------*
REPORT zp_preparar_finetuning.

INCLUDE zp_msaisdkdemo_params_top_oai.
INCLUDE zp_msaisdkdemo_common.

PARAMETERS:
  p_depid TYPE string OBLIGATORY DEFAULT 'davinci',
  p_file  TYPE string OBLIGATORY DEFAULT '/tmp/training_data.jsonl'.

" Estruturas para fine-tuning
DATA:
  ls_file_input TYPE zif_peng_azoai_sdk_types=>ty_files_input,
  ls_file_output TYPE zif_peng_azoai_sdk_types=>ty_files_output,
  ls_finetune_input TYPE zif_peng_azoai_sdk_types=>ty_finetunes_input,
  ls_finetune_output TYPE zif_peng_azoai_sdk_types=>ty_finetunes_output.

" Dados de exemplo para treinamento (SAP/ABAP específico)
TYPES: BEGIN OF ty_training_example,
         prompt     TYPE string,
         completion TYPE string,
       END OF ty_training_example.

DATA: lt_training_data TYPE TABLE OF ty_training_example.

START-OF-SELECTION.

  TRY.
      " ========================================
      " 1. Preparar Dados de Treinamento
      " ========================================
      " Exemplos específicos para SAP ABAP
      lt_training_data = VALUE #(
        ( prompt = 'Como declarar uma tabela interna em ABAP?'
          completion = 'DATA: lt_tabela TYPE TABLE OF estrutura. ou DATA: lt_tabela TYPE STANDARD TABLE OF ty_estrutura.' )
        
        ( prompt = 'Como fazer um SELECT em ABAP moderno?'
          completion = 'SELECT campo1, campo2 FROM tabela INTO TABLE @DATA(lt_resultado) WHERE condicao = @valor.' )
        
        ( prompt = 'Como tratar exceções em ABAP?'
          completion = 'TRY. "código que pode gerar exceção" CATCH cx_exception INTO DATA(lo_exc). MESSAGE lo_exc->get_text() TYPE ''E''. ENDTRY.' )
        
        ( prompt = 'Como criar uma classe em ABAP?'
          completion = 'CLASS zcl_minha_classe DEFINITION. PUBLIC SECTION. METHODS: metodo. ENDCLASS. CLASS zcl_minha_classe IMPLEMENTATION. METHOD metodo. ENDMETHOD. ENDCLASS.' )
      ).

      WRITE: / '🎯 Preparação de Fine-tuning para SAP ABAP'.
      WRITE: / '═══════════════════════════════════════════════════════'.
      WRITE: / 'Exemplos de treinamento preparados:', lines( lt_training_data ).

      " ========================================
      " 2. Gerar arquivo JSONL para treinamento
      " ========================================
      DATA: lt_jsonl_lines TYPE TABLE OF string.
      
      LOOP AT lt_training_data INTO DATA(ls_example).
        " Formato JSONL para OpenAI fine-tuning
        DATA(lv_jsonl_line) = 
          |{ "prompt": "{ ls_example-prompt }", "completion": "{ ls_example-completion }" }|.
        APPEND lv_jsonl_line TO lt_jsonl_lines.
      ENDLOOP.

      " ========================================
      " 3. Criar instância do SDK
      " ========================================
      sdk_instance = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
        api_version = p_ver
        api_base    = p_url
        api_type    = zif_peng_azoai_sdk_constants=>c_apitype-openai
        api_key     = p_key
      ).

      " ========================================
      " 4. Upload do arquivo de treinamento
      " ========================================
      " Nota: Em ambiente real, você faria upload via API
      " Aqui mostramos o processo conceitual
      
      WRITE: / ''.
      WRITE: / '📤 Processo de Upload (Conceitual):'.
      WRITE: / 'Arquivo JSONL preparado com', lines( lt_jsonl_lines ), 'exemplos'.
      
      " Mostrar algumas linhas do arquivo
      WRITE: / ''.
      WRITE: / '📋 Amostra dos dados de treinamento:'.
      DATA(lv_count) = 0.
      LOOP AT lt_jsonl_lines INTO DATA(lv_line).
        lv_count = lv_count + 1.
        WRITE: / |Exemplo { lv_count }: { lv_line(80) }...|.
        IF lv_count >= 3.
          EXIT.
        ENDIF.
      ENDLOOP.

      " ========================================
      " 5. Configuração do Fine-tuning
      " ========================================
      ls_finetune_input-training_file = 'file-123456'. " ID do arquivo após upload
      ls_finetune_input-model = p_depid.
      ls_finetune_input-n_epochs = 4.              " Número de épocas
      ls_finetune_input-batch_size = 2.            " Tamanho do batch
      ls_finetune_input-learning_rate_multiplier = '0.1'. " Taxa de aprendizado
      
      WRITE: / ''.
      WRITE: / '🎛️  Configurações de Fine-tuning:'.
      WRITE: / '   Modelo base:', ls_finetune_input-model.
      WRITE: / '   Épocas:', ls_finetune_input-n_epochs.
      WRITE: / '   Batch size:', ls_finetune_input-batch_size.
      WRITE: / '   Learning rate:', ls_finetune_input-learning_rate_multiplier.

      " ========================================
      " 6. Estimativa de Custo e Tempo
      " ========================================
      DATA(lv_estimated_tokens) = 0.
      LOOP AT lt_training_data INTO ls_example.
        " Estimativa simples: ~4 caracteres por token
        lv_estimated_tokens = lv_estimated_tokens + 
                             ( strlen( ls_example-prompt ) + strlen( ls_example-completion ) ) / 4.
      ENDLOOP.
      
      DATA(lv_total_training_tokens) = lv_estimated_tokens * ls_finetune_input-n_epochs.
      
      WRITE: / ''.
      WRITE: / '💰 Estimativas:'.
      WRITE: / '   Tokens por exemplo: ~', lv_estimated_tokens / lines( lt_training_data ).
      WRITE: / '   Total tokens treino:', lv_total_training_tokens.
      WRITE: / '   Tempo estimado: 10-30 minutos'.
      WRITE: / '   Custo estimado: $', ( lv_total_training_tokens * '0.0030' ).

      " ========================================
      " 7. Próximos passos
      " ========================================
      WRITE: / ''.
      WRITE: / '🚀 Próximos Passos:'.
      WRITE: / '1. ✅ Dados preparados'.
      WRITE: / '2. 📤 Upload arquivo (implementar)'.
      WRITE: / '3. ▶️  Iniciar fine-tuning (implementar)'.
      WRITE: / '4. ⏱️  Aguardar conclusão'.
      WRITE: / '5. 🧪 Testar modelo personalizado'.

      " ========================================
      " 8. Código para monitoramento (exemplo)
      " ========================================
      WRITE: / ''.
      WRITE: / '📊 Para monitorar o progresso, use:'.
      WRITE: / 'Endpoint: GET /fine-tunes/{fine_tune_id}'.
      WRITE: / 'Status possíveis: pending, running, succeeded, failed'.

    CATCH zcx_peng_azoai_sdk_exception INTO DATA(lx_exception).
      WRITE: / '💥 Erro no SDK:', lx_exception->get_text( ).
  ENDTRY.
```

---

## 🏢 Casos de Uso Empresariais Avançados

### 📝 Exemplo 5: Analisador de Performance de Código

```abap
*&---------------------------------------------------------------------*
*& Report ZP_ANALISE_PERFORMANCE
*&---------------------------------------------------------------------*
*& Demonstração: Análise de performance usando IA
*&---------------------------------------------------------------------*
REPORT zp_analise_performance.

INCLUDE zp_msaisdkdemo_params_top_oai.
INCLUDE zp_msaisdkdemo_common.

PARAMETERS:
  p_depid TYPE string OBLIGATORY DEFAULT 'gpt-4',
  p_prog  TYPE program OBLIGATORY.

DATA:
  ls_input  TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_input,
  ls_output TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_output.

START-OF-SELECTION.

  TRY.
      " ========================================
      " 1. Ler código fonte
      " ========================================
      READ REPORT p_prog INTO DATA(lt_source).
      CONCATENATE LINES OF lt_source INTO DATA(lv_source_code) SEPARATED BY cl_abap_char_utilities=>newline.

      " ========================================
      " 2. Criar instância do SDK
      " ========================================
      sdk_instance = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
        api_version = p_ver
        api_base    = p_url
        api_type    = zif_peng_azoai_sdk_constants=>c_apitype-azureopenai
        api_key     = p_key
      ).

      " ========================================
      " 3. Configurar Análise Especializada
      " ========================================
      APPEND VALUE #( role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-system 
                     content = 
        |Você é um especialista em performance de código SAP ABAP. | &
        |Analise o código fornecido e identifique: | &
        |1. Possíveis gargalos de performance | &
        |2. Consultas SQL ineficientes | &
        |3. Loops desnecessários ou mal otimizados | &
        |4. Uso inadequado de tabelas internas | &
        |5. Sugestões específicas de melhoria | &
        |6. Impacto estimado das otimizações | &
        |Forneça respostas técnicas e práticas.| ) TO ls_input-messages.

      APPEND VALUE #( role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-user 
                     content = |Analise a performance deste código ABAP:{ cl_abap_char_utilities=>newline }{ cl_abap_char_utilities=>newline }{ lv_source_code }| ) TO ls_input-messages.

      " Configuração para análise técnica precisa
      ls_input-temperature = '0.2'.  " Muito baixa para precisão técnica
      ls_input-max_tokens = 2000.

      " ========================================
      " 4. Executar Análise
      " ========================================
      sdk_instance->chat_completions( )->create(
        EXPORTING
          deploymentid = p_depid
          prompts      = ls_input
        IMPORTING
          statuscode   = status_code
          response     = ls_output
      ).

      " ========================================
      " 5. Apresentar Resultados
      " ========================================
      IF status_code = 200.
        WRITE: / '🔍 Análise de Performance - Programa:', p_prog.
        WRITE: / '═══════════════════════════════════════════════════════════════'.

        LOOP AT ls_output-choices INTO DATA(ls_choice).
          " Dividir resposta em seções
          SPLIT ls_choice-message-content AT cl_abap_char_utilities=>newline INTO TABLE DATA(lt_lines).
          
          LOOP AT lt_lines INTO DATA(lv_line).
            " Destacar seções importantes
            IF lv_line CS '1.' OR lv_line CS '2.' OR lv_line CS '3.' OR 
               lv_line CS '4.' OR lv_line CS '5.' OR lv_line CS '6.'.
              WRITE: / '🎯', lv_line.
            ELSEIF lv_line CS 'CRÍTICO' OR lv_line CS 'ALTA' OR lv_line CS 'URGENTE'.
              WRITE: / '🚨', lv_line.
            ELSEIF lv_line CS 'sugestão' OR lv_line CS 'melhoria' OR lv_line CS 'otimização'.
              WRITE: / '💡', lv_line.
            ELSE.
              WRITE: / lv_line.
            ENDIF.
          ENDLOOP.
        ENDLOOP.

        WRITE: / '═══════════════════════════════════════════════════════════════'.
        WRITE: / '📊 Tokens utilizados:', ls_output-usage-total_tokens.
      ENDIF.

    CATCH zcx_peng_azoai_sdk_exception INTO DATA(lx_exception).
      WRITE: / '💥 Erro na análise:', lx_exception->get_text( ).
  ENDTRY.
```

---

## 🔧 Utilitários e Helpers

### 📝 Exemplo 6: Classe Utilitária para IA

```abap
*&---------------------------------------------------------------------*
*& Classe ZCL_AI_HELPER - Utilitários para IA
*&---------------------------------------------------------------------*
CLASS zcl_ai_helper DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_ai_config,
             provider    TYPE string,
             endpoint    TYPE string,
             api_key     TYPE string,
             api_version TYPE string,
             deployment  TYPE string,
           END OF ty_ai_config.

    CLASS-METHODS:
      " Método factory para configuração
      create_sdk_instance
        IMPORTING
          iv_config        TYPE ty_ai_config
        RETURNING
          VALUE(ro_sdk)    TYPE REF TO zif_peng_azoai_centralcontrol
        RAISING
          zcx_peng_azoai_sdk_exception,

      " Método para chat simples
      simple_chat
        IMPORTING
          iv_config        TYPE ty_ai_config
          iv_system_prompt TYPE string DEFAULT 'Você é um assistente útil'
          iv_user_message  TYPE string
          iv_deployment    TYPE string DEFAULT 'gpt-35-turbo'
        RETURNING
          VALUE(rv_response) TYPE string,

      " Método para análise de sentimento
      analyze_sentiment
        IMPORTING
          iv_config     TYPE ty_ai_config
          iv_text       TYPE string
        RETURNING
          VALUE(rv_sentiment) TYPE string,

      " Método para resumo de texto
      summarize_text
        IMPORTING
          iv_config     TYPE ty_ai_config
          iv_text       TYPE string
          iv_max_words  TYPE i DEFAULT 100
        RETURNING
          VALUE(rv_summary) TYPE string.

  PRIVATE SECTION.
    CLASS-METHODS:
      format_response
        IMPORTING
          iv_response TYPE string
        RETURNING
          VALUE(rv_formatted) TYPE string.

ENDCLASS.

CLASS zcl_ai_helper IMPLEMENTATION.

  METHOD create_sdk_instance.
    " Implementação do factory method
    ro_sdk = zcl_peng_azoai_sdk_factory=>get_instance( )->get_sdk(
      api_version = iv_config-api_version
      api_base    = iv_config-endpoint
      api_type    = COND #( WHEN iv_config-provider = 'AZURE' 
                           THEN zif_peng_azoai_sdk_constants=>c_apitype-azureopenai
                           ELSE zif_peng_azoai_sdk_constants=>c_apitype-openai )
      api_key     = iv_config-api_key
    ).
  ENDMETHOD.

  METHOD simple_chat.
    TRY.
        DATA(lo_sdk) = create_sdk_instance( iv_config ).
        
        DATA: ls_input  TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_input,
              ls_output TYPE zif_peng_azoai_sdk_types=>ty_chatcompletion_output.

        " Configurar mensagens
        APPEND VALUE #( role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-system 
                       content = iv_system_prompt ) TO ls_input-messages.
        
        APPEND VALUE #( role = zif_peng_azoai_sdk_constants=>c_chatcompletion_role-user 
                       content = iv_user_message ) TO ls_input-messages.

        " Executar chat
        lo_sdk->chat_completions( )->create(
          EXPORTING
            deploymentid = iv_deployment
            prompts      = ls_input
          IMPORTING
            response     = ls_output
        ).

        " Extrair resposta
        IF ls_output-choices IS NOT INITIAL.
          READ TABLE ls_output-choices INDEX 1 INTO DATA(ls_choice).
          rv_response = format_response( ls_choice-message-content ).
        ENDIF.

      CATCH zcx_peng_azoai_sdk_exception.
        rv_response = 'Erro na comunicação com IA'.
    ENDTRY.
  ENDMETHOD.

  METHOD analyze_sentiment.
    DATA(lv_prompt) = |Analise o sentimento do seguinte texto e responda apenas com: POSITIVO, NEGATIVO ou NEUTRO.{ cl_abap_char_utilities=>newline }{ cl_abap_char_utilities=>newline }Texto: { iv_text }|.
    
    rv_sentiment = simple_chat( 
      iv_config = iv_config
      iv_system_prompt = 'Você é um especialista em análise de sentimento'
      iv_user_message = lv_prompt
    ).
  ENDMETHOD.

  METHOD summarize_text.
    DATA(lv_prompt) = |Resuma o seguinte texto em no máximo { iv_max_words } palavras:{ cl_abap_char_utilities=>newline }{ cl_abap_char_utilities=>newline }{ iv_text }|.
    
    rv_summary = simple_chat(
      iv_config = iv_config
      iv_system_prompt = 'Você é especialista em criar resumos concisos e informativos'
      iv_user_message = lv_prompt
    ).
  ENDMETHOD.

  METHOD format_response.
    " Limpar resposta removendo espaços extras e formatando
    rv_formatted = iv_response.
    
    " Remover quebras de linha desnecessárias
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline && cl_abap_char_utilities=>newline 
            IN rv_formatted WITH cl_abap_char_utilities=>newline.
    
    " Remover espaços no início e fim
    rv_formatted = condense( rv_formatted ).
  ENDMETHOD.

ENDCLASS.
```

### Programa de Teste da Classe Utilitária

```abap
*&---------------------------------------------------------------------*
*& Report ZP_TESTE_AI_HELPER
*&---------------------------------------------------------------------*
REPORT zp_teste_ai_helper.

PARAMETERS:
  p_url TYPE string OBLIGATORY,
  p_key TYPE string OBLIGATORY,
  p_ver TYPE string OBLIGATORY,
  p_dep TYPE string OBLIGATORY DEFAULT 'gpt-35-turbo'.

START-OF-SELECTION.
  
  " Configuração
  DATA(ls_config) = VALUE zcl_ai_helper=>ty_ai_config(
    provider = 'AZURE'
    endpoint = p_url
    api_key = p_key
    api_version = p_ver
    deployment = p_dep
  ).

  " Teste 1: Chat simples
  WRITE: / '🤖 Teste 1: Chat Simples'.
  DATA(lv_response) = zcl_ai_helper=>simple_chat( 
    iv_config = ls_config
    iv_user_message = 'Explique em poucas palavras o que é SAP ABAP'
  ).
  WRITE: / 'Resposta:', lv_response.

  " Teste 2: Análise de sentimento
  WRITE: / ''.
  WRITE: / '😊 Teste 2: Análise de Sentimento'.
  DATA(lv_sentiment) = zcl_ai_helper=>analyze_sentiment(
    iv_config = ls_config
    iv_text = 'Estou muito satisfeito com o novo sistema SAP!'
  ).
  WRITE: / 'Sentimento:', lv_sentiment.

  " Teste 3: Resumo de texto
  WRITE: / ''.
  WRITE: / '📄 Teste 3: Resumo de Texto'.
  DATA(lv_summary) = zcl_ai_helper=>summarize_text(
    iv_config = ls_config
    iv_text = 'O SAP ABAP é uma linguagem de programação desenvolvida pela SAP para criar aplicações empresariais robustas. É amplamente utilizada em sistemas ERP e oferece recursos avançados para integração com bases de dados e interfaces de usuário.'
    iv_max_words = 20
  ).
  WRITE: / 'Resumo:', lv_summary.
```

---

## 📋 Conclusão e Próximos Passos

### ✅ O que Aprendemos
1. **Chat Completion**: Para conversas e assistentes inteligentes
2. **Embeddings**: Para análise semântica e classificação
3. **Text Completion**: Para geração de conteúdo
4. **Fine-tuning**: Para modelos personalizados
5. **Análise Especializada**: Para casos de uso específicos
6. **Utilitários**: Para simplificar o uso do SDK

### 🚀 Próximos Passos
1. **Adaptar Exemplos**: Modifique os exemplos para seu ambiente
2. **Criar Templates**: Desenvolva templates reutilizáveis
3. **Implementar Logging**: Adicione logs detalhados
4. **Otimizar Performance**: Implemente caching quando apropriado
5. **Desenvolver Monitoramento**: Monitore uso de tokens e custos

### 💡 Dicas Importantes
- **Sempre teste** em ambiente não-produtivo primeiro
- **Monitore custos** de uso da API
- **Implemente retry logic** para chamadas que falharam
- **Use configurações** apropriadas de temperatura e tokens
- **Documente bem** suas implementações

---

**[⬆️ Voltar ao Guia Principal](README_PT-BR.md)**