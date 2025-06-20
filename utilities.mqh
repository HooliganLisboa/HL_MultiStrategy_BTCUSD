//+------------------------------------------------------------------+
//|                                    utilities_consolidated.mqh |
//|                  Copyright 2025, Hooligan Lisboa                  |
//|                 https://github.com/HooliganLisboa                 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Hooligan Lisboa"
#property link      "https://github.com/HooliganLisboa"

// Este arquivo é uma versão consolidada e reorganizada do utilities.mqh
// Contém funções utilitárias gerais, estatísticas e sistema de logging

#ifndef UTILITIES_MQH
#define UTILITIES_MQH

// Incluir definições globais
#include "globals.mqh"

//+------------------------------------------------------------------+
//| Estrutura para configuração de horário de negociação              |
//+------------------------------------------------------------------+
struct TradingHours
{
   int start_hour;      // Hora de início (0-23)
   int start_minute;    // Minuto de início (0-59)
   int end_hour;        // Hora de término (0-23)
   int end_minute;      // Minuto de término (0-59)
   bool enabled;        // Se o horário de negociação está ativo
   
   // Construtor com valores padrão (9h às 17h)
   TradingHours() : start_hour(9), start_minute(0), end_hour(17), end_minute(0), enabled(true) {}
   
   // Define o horário de negociação
   void SetTradingHours(int sh, int sm, int eh, int em, bool enable=true)
   {
      start_hour = sh;
      start_minute = sm;
      end_hour = eh;
      end_minute = em;
      enabled = enable;
   }
};

// Variável global para configuração do horário de negociação
TradingHours g_trading_hours;

//+------------------------------------------------------------------+
//| Verifica se a negociação é permitida no horário atual            |
//+------------------------------------------------------------------+
bool IsTradingAllowed()
{
   // Se o horário de negociação estiver desativado, sempre permite
   if(!g_trading_hours.enabled)
      return true;
      
   // Obtém a hora atual
   MqlDateTime time_struct;
   TimeCurrent(time_struct);
   
   // Converte horas e minutos para minutos desde a meia-noite para facilitar a comparação
   int current_minutes = time_struct.hour * 60 + time_struct.min;
   int start_minutes = g_trading_hours.start_hour * 60 + g_trading_hours.start_minute;
   int end_minutes = g_trading_hours.end_hour * 60 + g_trading_hours.end_minute;
   
   // Verifica se o horário atual está dentro do período de negociação
   return (current_minutes >= start_minutes && current_minutes < end_minutes);
}

// Funções de logging
enum LogLevel {
    LOG_ERROR = 0,
    LOG_WARNING,
    LOG_INFO,
    LOG_DEBUG
};

// Função principal de logging
void LogMessage(const string message, LogLevel level = LOG_INFO) {
    string prefix = "";
    switch(level) {
        case LOG_ERROR:   prefix = "ERRO: ";   break;
        case LOG_WARNING: prefix = "AVISO: ";  break;
        case LOG_INFO:    prefix = "INFO: ";   break;
        case LOG_DEBUG:   prefix = "DEBUG: ";  break;
    }
    Print(prefix, message);
}

// Funções de logging específicas
void LogError(const string message) {
    LogMessage(message, LOG_ERROR);
}

void LogWarning(const string message) {
    LogMessage(message, LOG_WARNING);
}

void LogInfo(const string message) {
    LogMessage(message, LOG_INFO);
}

void LogDebug(const string message) {
    LogMessage(message, LOG_DEBUG);
}

//+------------------------------------------------------------------+
//| Converte timeframe de ENUM_TIMEFRAMES para string                |
//+------------------------------------------------------------------+
string TimeframeToString(ENUM_TIMEFRAMES timeframe)
{
   switch(timeframe)
   {
      case PERIOD_M1:  return "M1";
      case PERIOD_M5:  return "M5";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1:  return "H1";
      case PERIOD_H4:  return "H4";
      case PERIOD_D1:  return "D1";
      case PERIOD_W1:  return "W1";
      case PERIOD_MN1: return "MN1";
      default:         return "Unknown";
   }
}

//+------------------------------------------------------------------+
//| Converte tipo de posição para string                             |
//+------------------------------------------------------------------+
string PositionTypeToString(ENUM_POSITION_TYPE positionType)
{
   switch(positionType)
   {
      case POSITION_TYPE_BUY:  return "BUY";
      case POSITION_TYPE_SELL: return "SELL";
      default:                 return "Unknown";
   }
}

//+------------------------------------------------------------------+
//| Gera nome único para ordem/posição baseado em timestamp          |
//+------------------------------------------------------------------+
string GenerateUniqueComment(string prefix = "")
{
   return StringFormat("%s_%d_%d", prefix, TimeCurrent(), MathRand());
}

//+------------------------------------------------------------------+
//| Normaliza preço com base nos dígitos do símbolo                  |
//+------------------------------------------------------------------+
double NormalizePrice(double price)
{
   return NormalizeDouble(price, _Digits);
}

//+------------------------------------------------------------------+
//| Calcula valor do lote baseado em percentual de risco             |
//+------------------------------------------------------------------+
double CalculateLotSize(double riskPercent, double stopLossPoints)
{
   double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double pointValue = tickValue / tickSize;
   
   double riskAmount = accountBalance * (riskPercent / 100.0);
   double lotSize = riskAmount / (stopLossPoints * pointValue);
   
   // Normalizar para tamanho de lote permitido
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   
   lotSize = MathFloor(lotSize / lotStep) * lotStep;
   
   // Certificar-se que está dentro dos limites
   lotSize = MathMax(minLot, lotSize);
   lotSize = MathMin(maxLot, lotSize);
   
   return lotSize;
}

//+------------------------------------------------------------------+
//| Atualiza a barra de status com informações do EA                 |
//+------------------------------------------------------------------+
void UpdateStatusBar(ENUM_STRATEGY currentStrategy, double dailyProfit)
{
   // Obter dados relevantes
   string strategyName = EnumToString(currentStrategy);
   string marketCondition = EnumToString(g_current_market_condition);
   
   if(!SymbolInfoTick(_Symbol, g_last_tick))
   {
      Print("Erro ao obter último tick");
      return;
   }
   
   // Formatar texto para barra de status
   string statusText = StringFormat("Estratégia: %s | Condição: %s | Lucro diário: %.2f | Preço atual: %.5f",
                                   strategyName, marketCondition, dailyProfit, g_last_tick.last);
                                   
   Comment(statusText);
}

//+------------------------------------------------------------------+
//| PARTE 2: ESTATÍSTICAS DE ESTRATÉGIA                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Calcula a performance da estratégia a partir do histórico         |
//+------------------------------------------------------------------+
void CalculateStrategyPerformance(ENUM_STRATEGY strategy, StrategyStats &stats)
{
   // Resetar estatísticas
   stats.totalTrades = 0;
   stats.winTrades = 0;
   stats.lossTrades = 0;
   stats.totalProfit = 0.0;
   stats.totalLoss = 0.0;
   stats.consecutiveWins = 0;
   stats.consecutiveLosses = 0;
   
   // Variáveis auxiliares
   int consecutiveWinsTemp = 0;
   int consecutiveLossesTemp = 0;
   
   // Buscar histórico de trades
   HistorySelect(stats.startTime, TimeCurrent());
   int totalDeals = HistoryDealsTotal();
   
   for(int i = 0; i < totalDeals; i++)
   {
      ulong dealTicket = HistoryDealGetTicket(i);
      if(dealTicket <= 0)
         continue;
         
      // Verificar se a negociação pertence à estratégia
      if(HistoryDealGetString(dealTicket, DEAL_COMMENT) != EnumToString(strategy))
         continue;
      
      // Processar o resultado da negociação
      stats.totalTrades++;
      double dealProfit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
      
      // Contabilizar vitórias e derrotas
      if(dealProfit > 0)
      {
         stats.winTrades++;
         stats.totalProfit += dealProfit;
         consecutiveWinsTemp++;
         consecutiveLossesTemp = 0;
      }
      else
      {
         stats.lossTrades++;
         stats.totalLoss += dealProfit;
         consecutiveLossesTemp++;
         consecutiveWinsTemp = 0;
      }
      
      // Atualizar consecutivas
      if(consecutiveWinsTemp > stats.consecutiveWins)
         stats.consecutiveWins = consecutiveWinsTemp;
         
      if(consecutiveLossesTemp > stats.consecutiveLosses)
         stats.consecutiveLosses = consecutiveLossesTemp;
         
      // Registrar última negociação
      stats.lastTradeTime = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);
   }
   
   // Calcular métricas derivadas
   if(stats.totalTrades > 0)
   {
      stats.winRate = (double)stats.winTrades / stats.totalTrades * 100.0;
   }
   
   if(stats.totalLoss != 0)
   {
      stats.profitFactor = MathAbs(stats.totalProfit / stats.totalLoss);
   }
   
   if(stats.winTrades > 0)
   {
      stats.averageWin = stats.totalProfit / stats.winTrades;
   }
   
   if(stats.lossTrades > 0)
   {
      stats.averageLoss = stats.totalLoss / stats.lossTrades;
   }
}

//+------------------------------------------------------------------+
//| PARTE 3: SISTEMA DE LOGGING                                      |
//+------------------------------------------------------------------+

// Níveis de logging
enum ENUM_LOG_LEVEL {
   LOG_LEVEL_ERROR,
   LOG_LEVEL_WARNING,
   LOG_LEVEL_INFO,
   LOG_LEVEL_DEBUG
};

// Nível atual de logging
GLOBAL ENUM_LOG_LEVEL g_log_level = LOG_LEVEL_INFO;
GLOBAL bool g_log_to_file = false;
GLOBAL string g_log_filename = "EA_MultiStrategy_Log.txt";
GLOBAL int g_log_file_handle = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Inicializa o sistema de logging                                  |
//+------------------------------------------------------------------+
bool InitializeLogging()
{
   if(g_log_to_file)
   {
      // Abrir ou criar arquivo de log
      g_log_file_handle = FileOpen(g_log_filename, FILE_WRITE|FILE_TXT);
      if(g_log_file_handle == INVALID_HANDLE)
      {
         Print("Erro ao abrir arquivo de log: ", GetLastError());
         g_log_to_file = false;
         return false;
      }
      
      // Escrever cabeçalho do log
      FileWrite(g_log_file_handle, "=== Log iniciado em ", TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS), " ===");
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Finaliza o sistema de logging                                    |
//+------------------------------------------------------------------+
void FinalizeLogging()
{
   if(g_log_to_file && g_log_file_handle != INVALID_HANDLE)
   {
      FileWrite(g_log_file_handle, "=== Log finalizado em ", TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS), " ===");
      FileClose(g_log_file_handle);
      g_log_file_handle = INVALID_HANDLE;
   }
}

//+------------------------------------------------------------------+
//| Registra uma mensagem de log com nível de severidade             |
//+------------------------------------------------------------------+
void LogMessage(ENUM_LOG_LEVEL level, string message)
{
   // Verificar se o nível de log está habilitado
   if(level > g_log_level)
      return;
      
   // Formatar a mensagem com timestamp e nível
   string levelText = "";
   switch(level)
   {
      case LOG_LEVEL_ERROR:   levelText = "ERROR"; break;
      case LOG_LEVEL_WARNING: levelText = "WARNING"; break;
      case LOG_LEVEL_INFO:    levelText = "INFO"; break;
      case LOG_LEVEL_DEBUG:   levelText = "DEBUG"; break;
   }
   
   string logMessage = StringFormat("[%s] [%s] %s", 
                                   TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS),
                                   levelText,
                                   message);
   
   // Registrar no console
   Print(logMessage);
   
   // Registrar no arquivo se habilitado
   if(g_log_to_file && g_log_file_handle != INVALID_HANDLE)
   {
      FileWrite(g_log_file_handle, logMessage);
   }
}

// Funções de conveniência para diferentes níveis de log
void LogError(string message) { LogMessage(LOG_LEVEL_ERROR, message); }
void LogWarning(string message) { LogMessage(LOG_LEVEL_WARNING, message); }
void LogInfo(string message) { LogMessage(LOG_LEVEL_INFO, message); }
void LogDebug(string message) { LogMessage(LOG_LEVEL_DEBUG, message); }

#endif // UTILITIES_MQH
