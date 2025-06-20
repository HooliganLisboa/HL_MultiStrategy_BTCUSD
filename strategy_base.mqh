//+------------------------------------------------------------------+
//|                                           strategy_base.mqh       |
//|                  Copyright 2025, Hooligan Lisboa                 |
//|                 https://github.com/HooliganLisboa                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Hooligan Lisboa"
#property link      "https://github.com/HooliganLisboa"
#property strict

#ifndef _STRATEGY_BASE_MQH_
#define _STRATEGY_BASE_MQH_

// Inclui os arquivos necessários
#include "Core/parameters.mqh"
#include "Core/market_data.mqh"
#include "Core/indicators/indicator_manager.mqh"
#include "Core/trade_manager.mqh"
#include "risk_manager.mqh"
#include "resource_manager.mqh"
#include "globals.mqh"
#include "utilities.mqh"

//+------------------------------------------------------------------+
//| Enumeração de estados da estratégia                               |
//+------------------------------------------------------------------+
enum ENUM_STRATEGY_STATE {
   STRATEGY_STATE_DISABLED,   // Estratégia desativada
   STRATEGY_STATE_ACTIVE,     // Estratégia ativa
   STRATEGY_STATE_PAUSED,     // Estratégia em pausa
   STRATEGY_STATE_ERROR       // Erro na estratégia
};

//+------------------------------------------------------------------+
//| Classe base para todas as estratégias                            |
//+------------------------------------------------------------------+
class CStrategyBase
{
protected:
   string m_name;                     // Nome da estratégia
   string m_symbol;                  // Símbolo de negociação
   ENUM_TIMEFRAMES m_timeframe;      // Timeframe da estratégia
   ENUM_STRATEGY_STATE m_state;      // Estado atual da estratégia
   CMarketData* m_market_data;       // Gerenciador de dados de mercado
   CTradeManager* m_trade_manager;   // Gerenciador de negociações
   CIndicatorManager* m_indicator_manager; // Gerenciador de indicadores
   CRiskManager* m_risk_manager;     // Gerenciador de risco
   ulong m_magic_number;             // Número mágico para identificação
   int m_rates_total;                // Total de barras disponíveis
   int m_prev_calculated;            // Número de barras processadas anteriormente
   
   // Métodos virtuais puros que devem ser implementados pelas classes derivadas
   virtual bool OnInitSpecific() = 0;     // Inicialização específica da estratégia
   virtual void OnDeinitSpecific() = 0;   // Finalização específica da estratégia
   virtual void OnTickSpecific() = 0;     // Processamento de tick específico
   
   // Construtor protegido para evitar instanciação direta
   CStrategyBase() : m_state(STRATEGY_STATE_DISABLED), 
                    m_market_data(NULL), 
                    m_trade_manager(NULL), 
                    m_indicator_manager(NULL), 
                    m_risk_manager(NULL),
                    m_magic_number(0),
                    m_rates_total(0),
                    m_prev_calculated(0) {}
   
public:
   // Construtor principal
   CStrategyBase(string name, string symbol, ENUM_TIMEFRAMES timeframe, ulong magic_number = 0) : 
      m_name(name), 
      m_symbol(symbol), 
      m_timeframe(timeframe),
      m_state(STRATEGY_STATE_DISABLED),
      m_market_data(NULL),
      m_trade_manager(NULL),
      m_indicator_manager(NULL),
      m_risk_manager(NULL),
      m_magic_number(magic_number),
      m_rates_total(0),
      m_prev_calculated(0) {
      
      // Inicializa os gerenciadores
      m_market_data = new CMarketData(symbol, timeframe);
      m_trade_manager = new CTradeManager(symbol, m_magic_number);
      m_indicator_manager = new CIndicatorManager(symbol, timeframe);
      m_risk_manager = new CRiskManager();
   }
   
   // Destrutor virtual
   virtual ~CStrategyBase() {
      // Libera a memória alocada
      if(CheckPointer(m_risk_manager) == POINTER_DYNAMIC) delete m_risk_manager;
      if(CheckPointer(m_indicator_manager) == POINTER_DYNAMIC) delete m_indicator_manager;
      if(CheckPointer(m_trade_manager) == POINTER_DYNAMIC) delete m_trade_manager;
      if(CheckPointer(m_market_data) == POINTER_DYNAMIC) delete m_market_data;
      
      m_risk_manager = NULL;
      m_indicator_manager = NULL;
      m_trade_manager = NULL;
      m_market_data = NULL;
   }
   
   // Métodos de ciclo de vida da estratégia
   bool OnInit() {
      if(m_state != STRATEGY_STATE_DISABLED) {
         Print("Aviso: Estratégia já inicializada");
         return false;
      }
      
      // Inicializa os gerenciadores
      if(m_market_data == NULL) {
         Print("Erro: Gerenciador de dados de mercado não inicializado");
         return false;
      }
      
      if(m_trade_manager == NULL) {
         Print("Erro: Gerenciador de negociações não inicializado");
         return false;
      }
      
      if(m_indicator_manager == NULL) {
         Print("Erro: Gerenciador de indicadores não inicializado");
         return false;
      }
      
      if(m_risk_manager == NULL) {
         Print("Erro: Gerenciador de risco não inicializado");
         return false;
      }
      
      // Inicialização específica da estratégia
      if(!OnInitSpecific()) {
         Print("Falha na inicialização específica da estratégia");
         m_state = STRATEGY_STATE_ERROR;
         return false;
      }
      
      m_state = STRATEGY_STATE_ACTIVE;
      Print("Estratégia ", m_name, " inicializada com sucesso");
      return true;
   }
   
   void OnDeinit(const int reason) {
      if(m_state == STRATEGY_STATE_DISABLED) return;
      
      // Finalização específica da estratégia
      OnDeinitSpecific();
      
      m_state = STRATEGY_STATE_DISABLED;
      Print("Estratégia ", m_name, " finalizada");
   }
   
   void OnTick() {
      if(m_state != STRATEGY_STATE_ACTIVE) return;
      
      // Atualiza os contadores de barras
      m_prev_calculated = m_rates_total;
      m_rates_total = iBars(m_symbol, m_timeframe);
      
      // Atualiza os dados de mercado
      if(m_market_data == NULL || !m_market_data.Update(m_rates_total, m_prev_calculated)) {
         Print("Falha ao atualizar dados de mercado");
         m_state = STRATEGY_STATE_ERROR;
         return;
      }
         
      // Processamento específico da estratégia
      OnTickSpecific();
   }
   
   // Métodos de controle da estratégia
   void Enable() {
      if(m_state == STRATEGY_STATE_DISABLED || m_state == STRATEGY_STATE_PAUSED) {
         m_state = STRATEGY_STATE_ACTIVE;
         Print("Estratégia ", m_name, " ativada");
      }
   }
   
   void Disable() {
      if(m_state == STRATEGY_STATE_ACTIVE || m_state == STRATEGY_STATE_PAUSED) {
         m_state = STRATEGY_STATE_DISABLED;
         Print("Estratégia ", m_name, " desativada");
      }
   }
   
   void Pause() {
      if(m_state == STRATEGY_STATE_ACTIVE) {
         m_state = STRATEGY_STATE_PAUSED;
         Print("Estratégia ", m_name, " pausada");
      }
   }
   
   // Getters
   string GetName() const { return m_name; }
   string GetSymbol() const { return m_symbol; }
   ENUM_TIMEFRAMES GetTimeframe() const { return m_timeframe; }
   ENUM_STRATEGY_STATE GetState() const { return m_state; }
   bool IsActive() const { return (m_state == STRATEGY_STATE_ACTIVE); }
   
   // Métodos virtuais para estatísticas e parâmetros
   virtual string GetStats() const { return ""; }
   virtual string GetParams() const { return ""; }
   virtual bool SetParams(const string params) { return true; }
   
   // Métodos auxiliares
   CMarketData* GetMarketData() const { return m_market_data; }
   CTradeManager* GetTradeManager() const { return m_trade_manager; }
   CIndicatorManager* GetIndicatorManager() const { return m_indicator_manager; }
   CRiskManager* GetRiskManager() const { return m_risk_manager; }
   
   // Desabilitar cópia e atribuição
private:
   CStrategyBase(const CStrategyBase&);
   void operator=(const CStrategyBase&);
};

#endif // _STRATEGY_BASE_MQH_
