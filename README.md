# HL_MultiStrategy_BTCUSD

Expert Advisor (EA) modular multi-estratégia para negociação de BTC/USD na plataforma MetaTrader 5.

## Visão Geral

O HL_MultiStrategy_BTCUSD é um Expert Advisor avançado que implementa múltiplas estratégias de negociação em um único robô, permitindo gerenciar diferentes abordagens de forma integrada e eficiente. O EA foi desenvolvido com foco em negociação de BTC/USD, mas pode ser adaptado para outros ativos.

## Características Principais

- **Arquitetura Modular**: Estrutura de código organizada e fácil de manter
- **Múltiplas Estratégias**: Suporte a até 20 estratégias diferentes (A a T)
- **Gerenciamento de Risco Avançado**: Controle de risco por operação e drawdown diário
- **Otimização de Recursos**: Uso eficiente de indicadores e memória
- **Logs Detalhados**: Sistema de log para depuração e análise
- **Horário de Negociação**: Controle flexível de horários de negociação

## Estrutura do Projeto

```
HL_MultiStrategy_BTCUSD/
├── Core/                    # Módulos principais do EA
│   ├── indicators/          # Gerenciador de indicadores
│   ├── market_data.mqh      # Manipulação de dados de mercado
│   ├── parameters.mqh       # Parâmetros e configurações
│   └── trade_manager.mqh    # Gerenciamento de ordens
├── Strategies/              # Estratégias de negociação
│   ├── strategy_a_refactored.mqh
│   ├── strategy_b_refactored.mqh
│   └── ...
├── globals.mqh              # Variáveis globais
├── resource_manager.mqh     # Gerenciamento de recursos
├── risk_manager.mqh         # Gerenciamento de risco
├── strategy_base.mqh        # Classe base para estratégias
├── strategy_initialization.mqh # Inicialização de estratégias
├── utilities.mqh            # Funções utilitárias
└── HL_MultiStrategy_BTCUSD.mq5  # Arquivo principal do EA
```

## Requisitos

- MetaTrader 5
- Acesso a dados de BTC/USD
- Conexão com a internet para atualizações de cotações

## Instalação

1. Copie a pasta `HL_MultiStrategy_BTCUSD` para o diretório `MQL5/Experts/` da sua instalação do MetaTrader 5
2. Abra o MetaEditor (F4 no MetaTrader 5)
3. Navegue até `Experts` > `NovasEstrategias` > `HL_MultiStrategy_BTCUSD`
4. Compile o arquivo `HL_MultiStrategy_BTCUSD.mq5`
5. Adicione o EA a um gráfico BTC/USD no MetaTrader 5

## Configuração

O EA possui diversos parâmetros configuráveis, incluindo:

- Gerenciamento de risco
- Horários de negociação
- Configurações específicas por estratégia
- Parâmetros de notificação

Consulte o arquivo `DOCUMENTACAO.md` para detalhes completos sobre a configuração.

## Uso

1. Configure os parâmetros de acordo com sua estratégia e perfil de risco
2. Habilite/desabilite as estratégias conforme necessário
3. Defina os níveis de alavancagem e margem apropriados
4. Monitore o desempenho através dos logs e notificações

## Licença

Copyright © 2025 Hooligan Lisboa. Todos os direitos reservados.

## Suporte

Para suporte, relatórios de bugs ou contribuições, abra uma issue no repositório do projeto em [GitHub](https://github.com/HooliganLisboa).
