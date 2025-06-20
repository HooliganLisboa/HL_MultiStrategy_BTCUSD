//+------------------------------------------------------------------+
//|                    HL_MultiStrategy_BTCUSD.mq5                   |
//|                  Copyright 2025, Hooligan Lisboa                 |
//|                 https://github.com/HooliganLisboa                |
//|                                                                  |
//|  Expert Advisor multi-estratégia modular para negociação em      |
//|  BTCUSD com gerenciamento de risco integrado.                    |
//|  Versão Modular 2.0                                              |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Hooligan Lisboa"
#property link      "https://github.com/HooliganLisboa"
#property version   "2.00"
#property description "Expert Advisor modular multi-estratégia para BTCUSD"
#property description "Gerenciamento de risco integrado e seleção dinâmica de estratégias"
#property description "Baseado em análise técnica e condições de mercado"
#property description "Versão Modular 2.0 - Suporte a 20 Estratégias"

//--- Configurações de compilação
#property strict

//--- Incluir bibliotecas do sistema
#include <Trade/Trade.mqh>               // Operações de negociação
#include <Arrays/ArrayObj.mqh>           // Para gerenciar arrays de objetos
#include <Trade/SymbolInfo.mqh>          // Informações do símbolo
#include <Trade/OrderInfo.mqh>           // Informações de ordens
#include <Arrays/List.mqh>               // Estruturas de dados
#include <Object.mqh>                    // Classe base para objetos

//--- Incluir cabeçalhos do Core
#include "Core/parameters.mqh"
#include "Core/market_data.mqh"
#include "Core/trade_manager.mqh"
#include "Core/indicators/indicator_manager.mqh"
#include "risk_manager.mqh"
#include "resource_manager.mqh"
#include "strategy_base.mqh"
#include "globals.mqh"
#include "utilities.mqh"

//--- Incluir o gerenciador de estratégias
#include "strategy_initialization.mqh"

//--- Definições
#define EXPERT_MAGIC 20250619  // Número mágico para identificação do EA

//--- Variáveis globais
CTradeManager* g_tradeManager = NULL;       // Gerenciador de negociações
CMarketData* g_marketData = NULL;           // Dados de mercado
CIndicatorManager* g_indicatorManager = NULL; // Gerenciador de indicadores
CRiskManager* g_riskManager = NULL;         // Gerenciador de risco
CResourceManager* g_resourceManager = NULL;  // Gerenciador de recursos

// Referência para as estratégias ativas (gerenciada pelo strategy_initialization.mqh)
// As estratégias são armazenadas em g_activeStrategies dentro do módulo de inicialização

//--- Parâmetros de entrada (Inputs)
input group "Configurações Gerais"
input string Inp_Comment = "HL_MultiStrategy";  // Comentário nas ordens
input int Inp_MagicNumber = 123456;             // Número mágico
input group "Gerenciamento de Risco"
input double Inp_RiskPerTrade = 1.0;            // Risco por operação (%)
input double Inp_MaxDailyLoss = 5.0;            // Perda diária máxima (%)
input double Inp_MaxDrawdown = 20.0;            // Drawdown máximo (%)
input int Inp_MaxOpenPositions = 5;            // Máximo de posições abertas
input group "Configurações de Negociação"
input double Inp_LotSize = 0.01;                // Tamanho do lote
input int Inp_Slippage = 3;                     // Slippage máximo (pontos)
input int Inp_StopLoss = 100;                   // Stop Loss (pontos)
input int Inp_TakeProfit = 200;                 // Take Profit (pontos)
input bool Inp_UseTrailingStop = false;         // Usar Trailing Stop
input int Inp_TrailingStop = 50;                // Trailing Stop (pontos)
input int Inp_TrailingStep = 10;               // Passo do Trailing (pontos)
input group "Configurações de Tempo"
input bool Inp_UseTradingHours = true;          // Respeitar horário de negociação
input int Inp_StartHour = 9;                    // Hora de início
input int Inp_StartMinute = 0;                  // Minuto de início
input int Inp_EndHour = 17;                     // Hora de término
input int Inp_EndMinute = 0;                   // Minuto de término
input bool Inp_CloseOnFriday = true;            // Fechar posições na sexta-feira
input int Inp_CloseHour = 16;                   // Hora de fechamento (sexta)
input int Inp_CloseMinute = 30;                // Minuto de fechamento (sexta)
input group "Notificações"
input bool Inp_EnableNotifications = true;      // Ativar notificações
input bool Inp_NotifyOnTrade = true;            // Notificar operações
input bool Inp_NotifyOnError = true;            // Notificar erros

//+------------------------------------------------------------------+
//| Função de inicialização do EA                                    |
//+------------------------------------------------------------------+
int OnInit() {
   // Inicializa o gerenciador de estratégias
   if(!InitializeStrategyManager()) {
      Print("Falha ao inicializar o gerenciador de estratégias");
      return INIT_FAILED;
   }
   
   // Inicializa o gerenciador de dados de mercado
   g_marketData = new CMarketData(_Symbol, _Period);
   if(!g_marketData.Initialize()) {
      Print("Falha ao inicializar o gerenciador de dados de mercado");
      return INIT_FAILED;
   }
   
   // Inicializa o gerenciador de negociações
   g_tradeManager = new CTradeManager(_Symbol);
   if(!g_tradeManager.Initialize()) {
      Print("Falha ao inicializar o gerenciador de negociações");
      return INIT_FAILED;
   }
   
   // Configura o gerenciador de negociações
   g_tradeManager.SetExpertMagicNumber(Inp_MagicNumber);
   g_tradeManager.SetDeviationInPoints(Inp_Slippage);
   g_tradeManager.SetTypeFilling(ORDER_FILLING_FOK);
   
   // Inicializa o gerenciador de indicadores
   g_indicatorManager = new CIndicatorManager(_Symbol, _Period);
   if(!g_indicatorManager.Initialize()) {
      Print("Falha ao inicializar o gerenciador de indicadores");
      return INIT_FAILED;
   }
   
   // Inicializa o gerenciador de risco
   g_riskManager = new CRiskManager();
   g_riskManager.SetRiskParameters(
      Inp_MaxDrawdown,    // Drawdown máximo
      Inp_MaxDailyLoss,   // Perda diária máxima
      Inp_RiskPerTrade,   // Risco por operação
      Inp_MaxDailyLoss,   // Risco diário máximo (mesmo que perda diária)
      Inp_MaxOpenPositions, // Máximo de posições abertas
      100.0               // Exposição máxima (100% por padrão)
   );
   
   // Inicializa a lista de estratégias ativas
   g_activeStrategies = new CArrayObj();
   
   // Inicializa as estratégias ativas (exemplo com as primeiras 5 estratégias)
   bool strategiesInitialized = true;
   
   // Inicializa a Estratégia A
   if(!InitializeStrategy(STRATEGY_A)) {
      Print("Aviso: Falha ao inicializar a Estratégia A");
      strategiesInitialized = false;
   }
   
   // Inicializa a Estratégia B
   if(!InitializeStrategy(STRATEGY_B)) {
      Print("Aviso: Falha ao inicializar a Estratégia B");
      strategiesInitialized = false;
   }
   
   // Inicializa a Estratégia Q
   if(!InitializeStrategy(STRATEGY_Q)) {
      Print("Aviso: Falha ao inicializar a Estratégia Q - Advanced Swing with Trend Lines");
      strategiesInitialized = false;
   } else {
      Print("Estratégia Q - Advanced Swing with Trend Lines inicializada com sucesso");
   }
   // ...
   
   if(!strategiesInitialized) {
      Print("Aviso: Uma ou mais estratégias não foram inicializadas corretamente");
   }
   
   // Verifica se há pelo menos uma estratégia ativa
   if(g_activeStrategies.Total() == 0) {
      Print("Erro: Nenhuma estratégia ativa. Verifique as configurações.");
      return INIT_FAILED;
   }
   
   Print("EA inicializado com ", g_activeStrategies.Total(), " estratégias ativas");
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Função de desinicialização do EA                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   // Libera a memória alocada para as estratégias
   DeinitializeStrategyManager();
   
   // Finaliza as estratégias ativas
   if(g_activeStrategies != NULL) {
      for(int i = g_activeStrategies.Total() - 1; i >= 0; i--) {
         CStrategyBase* strategy = g_activeStrategies.At(i);
         if(strategy != NULL) {
            strategy.OnDeinit();
            delete strategy;
         }
      }
      delete g_activeStrategies;
      g_activeStrategies = NULL;
   }
   
   // Finaliza os gerenciadores
   if(g_indicatorManager != NULL) {
      g_indicatorManager.Deinitialize();
      delete g_indicatorManager;
      g_indicatorManager = NULL;
   }
   
   if(g_tradeManager != NULL) {
      g_tradeManager.Deinitialize();
      delete g_tradeManager;
      g_tradeManager = NULL;
   }
   
   if(g_marketData != NULL) {
      g_marketData.Deinitialize();
      delete g_marketData;
      g_marketData = NULL;
   }
   
   if(g_riskManager != NULL) {
      delete g_riskManager;
      g_riskManager = NULL;
   }
   
   if(g_resourceManager != NULL) {
      g_resourceManager.ReleaseAll();
      delete g_resourceManager;
      g_resourceManager = NULL;
   }
   
   Print("EA finalizado");
}

//+------------------------------------------------------------------+
//| Função de atualização do EA (a cada tick)                       |
//+------------------------------------------------------------------+
void OnTick() {
   // Atualiza os dados de mercado
   if(!g_marketData.Update()) {
      Print("Erro ao atualizar dados de mercado");
      return;
   }
   
   // Atualiza o gerenciador de risco
   g_riskManager.Update();
   
   // Verifica se está dentro do horário de negociação
   if(!IsTradeAllowed()) {
      return;
   }
   
   // Processa cada estratégia ativa
   for(int i = 0; i < g_activeStrategies.Total(); i++) {
      CStrategyBase* strategy = g_activeStrategies.At(i);
      if(strategy != NULL && strategy.IsActive()) {
         strategy.OnTick();
      }
   }
}

//+------------------------------------------------------------------+
//| Verifica se a negociação é permitida no momento atual           |
//+------------------------------------------------------------------+
bool IsTradeAllowed() {
   if(!Inp_UseTradingHours) {
      return true;  // Negociação permitida a qualquer momento
   }
   
   MqlDateTime dt;
   TimeCurrent(dt);
   
   // Verifica se é dia útil (segunda a sexta)
   if(dt.day_of_week == 0 || dt.day_of_week == 6) {
      return false;  // Fim de semana
   }
   
   // Verifica o horário de negociação
   int currentMinutes = dt.hour * 60 + dt.min;
   int startMinutes = Inp_StartHour * 60 + Inp_StartMinute;
   int endMinutes = Inp_EndHour * 60 + Inp_EndMinute;
   
   if(currentMinutes < startMinutes || currentMinutes >= endMinutes) {
      return false;  // Fora do horário de negociação
   }
   
   // Verifica se é sexta-feira e se deve fechar posições
   if(Inp_CloseOnFriday && dt.day_of_week == 5) {
      int closeMinutes = Inp_CloseHour * 60 + Inp_CloseMinute;
      if(currentMinutes >= closeMinutes) {
         // Fecha todas as posições abertas
         if(g_tradeManager != NULL) {
            g_tradeManager.CloseAllPositions();
         }
         return false;
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Função para inicializar todas as estratégias                    |
//+------------------------------------------------------------------+
bool InitializeAllStrategies() {
   if(g_activeStrategies == NULL) {
      return false;
   }
   
   bool atLeastOneStrategy = false;
   CStrategyBase* strategy = NULL;
   
   // Inicializa as estratégias
   
   // Estratégia A
   strategy = InitializeStrategy("A");
   if(strategy != NULL) {
      g_activeStrategies.Add(strategy);
      atLeastOneStrategy = true;
      Print("Estratégia A inicializada com sucesso");
   } else {
      Print("Falha ao inicializar a Estratégia A");
   }
   
   // Estratégia B (descomente e implemente quando estiver pronta)
   /*
   strategy = InitializeStrategy("B");
   if(strategy != NULL) {
      g_activeStrategies.Add(strategy);
      atLeastOneStrategy = true;
      Print("Estratégia B inicializada com sucesso");
   } else {
      Print("Falha ao inicializar a Estratégia B");
   }
   */
   
   return atLeastOneStrategy;
}

//+------------------------------------------------------------------+
//| Função para obter o gerenciador de negociações                  |
//+------------------------------------------------------------------+
CTradeManager* GetTradeManager() {
   return g_tradeManager;
}

//+------------------------------------------------------------------+
//| Função para obter o gerenciador de indicadores                  |
//+------------------------------------------------------------------+
CIndicatorManager* GetIndicatorManager() {
   return g_indicatorManager;
}

//+------------------------------------------------------------------+
//| Função para obter o gerenciador de dados de mercado             |
//+------------------------------------------------------------------+
CMarketData* GetMarketData() {
   return g_marketData;
}

//+------------------------------------------------------------------+
//| Função para obter o gerenciador de risco                        |
//+------------------------------------------------------------------+
CRiskManager* GetRiskManager() {
   return g_riskManager;
}

//+------------------------------------------------------------------+
//| Função para obter o gerenciador de recursos                     |
//+------------------------------------------------------------------+
CResourceManager* GetResourceManager() {
   return g_resourceManager;
}
