# Documentação Técnica - HL_MultiStrategy_BTCUSD

## Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura do Sistema](#arquitetura-do-sistema)
3. [Estratégias Implementadas](#estratégias-implementadas)
4. [Gerenciamento de Risco](#gerenciamento-de-risco)
5. [Configuração](#configuração)
6. [Compilação e Implantação](#compilação-e-implantação)
7. [Solução de Problemas](#solução-de-problemas)
8. [Boas Práticas](#boas-práticas)
9. [FAQ](#faq)

## Visão Geral

O HL_MultiStrategy_BTCUSD é um Expert Advisor avançado para MetaTrader 5 projetado para operar no par BTC/USD. Este documento fornece informações técnicas detalhadas sobre a arquitetura, configuração e operação do EA.

## Arquitetura do Sistema

### Módulos Principais

1. **Core**
   - `indicator_manager.mqh`: Gerencia todos os indicadores técnicos
   - `market_data.mqh`: Processa e armazena dados de mercado
   - `parameters.mqh`: Define parâmetros e estruturas de dados
   - `trade_manager.mqh`: Gerencia operações de negociação

2. **Estratégias**
   - 20 estratégias implementadas (A a T)
   - Cada estratégia é uma classe que herda de `CStrategyBase`
   - Processamento independente com compartilhamento de recursos

3. **Gerenciamento**
   - `risk_manager.mqh`: Controle de risco e exposição
   - `resource_manager.mqh`: Gerenciamento de recursos do sistema
   - `utilities.mqh`: Funções auxiliares e utilitários

### Fluxo de Execução

1. Inicialização do EA
2. Carregamento das configurações
3. Inicialização das estratégias
4. Loop principal (OnTick/OnTimer)
   - Atualização de dados de mercado
   - Execução das estratégias ativas
   - Gerenciamento de ordens
   - Atualização de métricas

## Estratégias Implementadas

Cada estratégia segue a estrutura base definida em `strategy_base.mqh` e implementa os seguintes métodos:

- `OnInit()`: Inicialização
- `OnDeinit()`: Limpeza
- `OnTick()`: Lógica de negociação
- `OnTrade()`: Tratamento de eventos de negociação

### Lista de Estratégias

1. **Estratégia A**: [Breve descrição]
2. **Estratégia B**: [Breve descrição]
...
20. **Estratégia T**: [Breve descrição]

## Gerenciamento de Risco

### Parâmetros de Risco

- **Risco por Operação**: Percentual do capital arriscado por trade
- **Drawdown Diário Máximo**: Limite de perda diária
- **Tamanho Máximo de Posição**: Limite de tamanho por operação
- **Stop Loss/Take Profit**: Níveis de proteção

### Mecanismos de Proteção

- Validação de margem disponível
- Verificação de spread máximo
- Limites de horário de negociação
- Monitoramento de execução de ordens

## Configuração

### Parâmetros do EA

#### Parâmetros Gerais
- **Lote Inicial**: Tamanho do lote inicial
- **Magic Number**: Identificador único para as ordens
- **Comentário**: Comentário para as ordens

#### Horário de Negociação
- **Hora de Início**: Hora de início das operações
- **Hora de Término**: Hora de encerramento das operações
- **Dias da Semana**: Dias em que o EA está ativo

#### Notificações
- **Ativar Notificações**: Habilita/desabilita notificações
- **Notificação por E-mail**: Envia alertas por e-mail
- **Notificação por Push**: Envia notificações push

## Compilação e Implantação

### Requisitos
- MetaTrader 5 Build 2000+
- Acesso a dados de BTC/USD
- Conexão com a internet

### Passos para Compilação

1. Abra o arquivo `HL_MultiStrategy_BTCUSD.mq5` no MetaEditor
2. Pressione F7 ou clique em "Compilar"
3. Verifique se não há erros na janela "Experts"

### Implantação

1. Feche todas as posições abertas manualmente
2. Adicione o EA ao gráfico BTC/USD M5
3. Configure os parâmetros conforme necessário
4. Habilite o "Algoritmic Trading" no MetaTrader 5

## Solução de Problemas

### Problemas Comuns

1. **Erro ao carregar a DLL**
   - Verifique se o arquivo .dll está na pasta correta
   - Habilite a importação de DLLs nas configurações do MT5

2. **EA não abre ordens**
   - Verifique se a conta está conectada
   - Confira se há margem disponível
   - Verifique os logs de erro

3. **Estratégias não estão sendo executadas**
   - Confira se as estratégias estão habilitadas
   - Verifique o horário de negociação
   - Confira os logs para mensagens de erro

### Logs

O EA gera logs detalhados que podem ser acessados em:
`Terminal\[ID]\MQL5\Logs\[Nome da Conta]\HL_MultiStrategy_BTCUSD.log`

## Boas Práticas

1. **Teste em Conta Demo**
   - Sempre teste em conta demo antes de usar em conta real
   - Monitore o desempenho por pelo menos 2 semanas

2. **Gerenciamento de Capital**
   - Nunca arrisque mais de 1-2% do capital por operação
   - Ajuste o tamanho do lote conforme o saldo da conta

3. **Atualizações**
   - Mantenha o EA atualizado com as versões mais recentes
   - Verifique as notas de atualização para mudanças importantes

## FAQ

### Posso usar este EA em outros pares além de BTC/USD?
Sim, mas foi otimizado especificamente para BTC/USD. Ajustes podem ser necessários para outros ativos.

### Como adiciono uma nova estratégia?
1. Crie um novo arquivo na pasta `Strategies` seguindo o padrão `strategy_x.mqh`
2. Implemente a classe herdando de `CStrategyBase`
3. Adicione a inicialização no `strategy_initialization.mqh`

### O EA funciona em timeframes diferentes?
Sim, mas foi otimizado para o timeframe M5. Teste adequadamente antes de usar em outros timeframes.

### Como configuro o gerenciamento de risco?
Ajuste os parâmetros na aba "Gerenciamento de Risco" nas configurações do EA.

### Onde posso obter suporte?
Para suporte, abra uma issue no repositório oficial do projeto.

---
*Documentação atualizada em 20/06/2025*
