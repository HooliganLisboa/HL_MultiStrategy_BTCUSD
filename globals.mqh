//+------------------------------------------------------------------+
//|                                                globals.mqh     |
//|                  Copyright 2025, Hooligan Lisboa                 |
//|                 https://github.com/HooliganLisboa                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Hooligan Lisboa"
#property link      "https://github.com/HooliganLisboa"
#property strict

#ifndef _GLOBALS_MQH_
#define _GLOBALS_MQH_

// Inclui definições de tipos básicos
#include <Object.mqh>
#include <Arrays/ArrayObj.mqh>
#include <Trade/Trade.mqh>

//+------------------------------------------------------------------+
//| Enumeração de estratégias                                        |
//+------------------------------------------------------------------+
enum ENUM_STRATEGY {
   STRATEGY_NONE = -1,
   STRATEGY_A = 0,
   STRATEGY_B = 1,
   STRATEGY_C = 2,
   STRATEGY_D = 3,
   STRATEGY_E = 4,
   STRATEGY_F = 5,
   STRATEGY_G = 6,
   STRATEGY_H = 7,
   STRATEGY_I = 8,
   STRATEGY_J = 9,
   STRATEGY_K = 10,
   STRATEGY_L = 11,
   STRATEGY_M = 12,
   STRATEGY_N = 13,
   STRATEGY_O = 14,
   STRATEGY_P = 15,
   STRATEGY_Q = 16,
   STRATEGY_R = 17,
   STRATEGY_S = 18,
   STRATEGY_T = 19,
   STRATEGY_TOTAL = 20
};

//+------------------------------------------------------------------+
//| Estrutura para armazenar estatísticas de uma estratégia          |
//+------------------------------------------------------------------+
struct StrategyStats {
   int totalTrades;         // Total de negociações
   int profitableTrades;    // Negociações lucrativas
   int losingTrades;        // Negociações com prejuízo
   double totalProfit;      // Lucro total
   double totalLoss;        // Prejuízo total
   double maxDrawdown;      // Drawdown máximo
   double winRate;          // Taxa de acerto
   double profitFactor;     // Fator de lucro
   double recoveryFactor;   // Fator de recuperação
   double sharpeRatio;      // Índice de Sharpe
   
   // Construtor
   void StrategyStats() {
      ZeroMemory(this);
   }
};

//+------------------------------------------------------------------+
//| Estrutura para gerenciar estatísticas de todas as estratégias    |
//+------------------------------------------------------------------+
struct AllStrategiesStats {
   StrategyStats stats[STRATEGY_TOTAL];  // Array de estatísticas
   
   // Obtém as estatísticas de uma estratégia
   bool GetStats(ENUM_STRATEGY strategy, StrategyStats &result) {
      if(strategy >= 0 && strategy < STRATEGY_TOTAL) {
         result = stats[strategy];
         return true;
      }
      return false;
   }
   
   // Define as estatísticas de uma estratégia
   bool SetStats(ENUM_STRATEGY strategy, const StrategyStats &value) {
      if(strategy >= 0 && strategy < STRATEGY_TOTAL) {
         stats[strategy] = value;
         return true;
      }
      return false;
   }
};

//+------------------------------------------------------------------+
//| Função para obter a estratégia a partir do ticket               |
//+------------------------------------------------------------------+
ENUM_STRATEGY GetStrategyFromTicket(ulong ticket) {
   // Implementação básica - deve ser adaptada conforme necessário
   return STRATEGY_NONE;
}

#endif // _GLOBALS_MQH_
