//+------------------------------------------------------------------+
//|                                                risk_manager.mqh   |
//|                  Copyright 2025, Hooligan Lisboa                 |
//|                 https://github.com/HooliganLisboa                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Hooligan Lisboa"
#property link      "https://github.com/HooliganLisboa"
#property strict

#ifndef _RISK_MANAGER_MQH_
#define _RISK_MANAGER_MQH_

#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>

// Incluir arquivos locais
#include "globals.mqh"
#include "utilities.mqh"

// Estrutura para armazenar métricas de risco
struct RiskMetrics
{
    double currentExposure;      // Exposição atual em % do patrimônio
    double dailyPnL;             // Lucro/Prejuízo do dia
    double maxDailyDrawdown;     // Máximo drawdown diário
    double maxPositionRisk;      // Risco máximo por posição (% do patrimônio)
    double maxDailyLoss;         // Perda diária máxima permitida (% do patrimônio)
    int maxOpenPositions;        // Número máximo de posições abertas simultaneamente
    double maxLeverage;          // Alavancagem máxima permitida
    double minStopLossPips;      // Stop Loss mínimo em pips
    double minTakeProfitPips;    // Take Profit mínimo em pips
};

//+------------------------------------------------------------------+
//| Classe para gerenciar o risco das operações                      |
//+------------------------------------------------------------------+
class CRiskManager
{
private:
    RiskMetrics m_metrics;          // Métricas de risco atuais
    double m_initialBalance;        // Saldo inicial do dia
    double m_maxBalance;            // Saldo máximo atingido no dia
    datetime m_lastCheck;           // Última verificação
    
    // Atualiza as métricas de risco
    void UpdateMetrics()
    {
        CalculateExposure();
        
        // Atualiza o saldo máximo
        double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
        if(currentBalance > m_maxBalance)
        {
            m_maxBalance = currentBalance;
        }
        
        // Calcula o drawdown diário
        if(m_maxBalance > 0.0)
        {
            double drawdown = ((m_maxBalance - currentBalance) / m_maxBalance) * 100.0;
            if(drawdown > m_metrics.maxDailyDrawdown)
            {
                m_metrics.maxDailyDrawdown = drawdown;
            }
        }
    }
    
    // Calcula a exposição atual de forma otimizada
    void CalculateExposure()
    {
        // Obtém a margem total usada diretamente das informações da conta
        double totalMargin = AccountInfoDouble(ACCOUNT_MARGIN);
        double equity = AccountInfoDouble(ACCOUNT_EQUITY);
        
        // Calcula a exposição como porcentagem do patrimônio
        if(equity > 0.0)
        {
            m_metrics.currentExposure = (totalMargin / equity) * 100.0;
        }
        else
        {
            m_metrics.currentExposure = 0.0;
        }
    }
    
    // Reinicia as métricas diárias
    void ResetDailyMetrics()
    {
        m_initialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
        m_maxBalance = m_initialBalance;
        m_metrics.dailyPnL = 0.0;
        m_metrics.maxDailyDrawdown = 0.0;
        
        // Valores padrão
        m_metrics.maxPositionRisk = 2.0;           // 2% do patrimônio por posição
        m_metrics.maxDailyLoss = 5.0;              // 5% de perda diária máxima
        m_metrics.maxOpenPositions = 10;           // Máximo de 10 posições abertas
        m_metrics.maxLeverage = 10.0;              // Alavancagem máxima de 1:10
        m_metrics.minStopLossPips = 10.0;          // Stop Loss mínimo de 10 pips
        m_metrics.minTakeProfitPips = 20.0;        // Take Profit mínimo de 20 pips
    }
    
public:
    // Construtor
    CRiskManager() : m_initialBalance(0.0), m_maxBalance(0.0), m_lastCheck(0)
    {
        ResetDailyMetrics();
    }
    
    // Destrutor
    ~CRiskManager()
    {
        // Nada a fazer no momento
    }
    
    // Inicializa o gerenciador de risco
    bool Initialize()
    {
        ResetDailyMetrics();
        return true;
    }
    
    // Finaliza o gerenciador de risco
    void Deinitialize()
    {
        // Nada a fazer no momento
    }
    
    // Atualiza as métricas de risco
    void Update()
    {
        datetime currentTime = TimeCurrent();
        MqlDateTime time1, time2;
        TimeToStruct(currentTime, time1);
        TimeToStruct(m_lastCheck, time2);
        
        // Verifica se é um novo dia
        if(time1.day != time2.day || time1.mon != time2.mon || time1.year != time2.year)
        {
            ResetDailyMetrics();
        }
        
        // Atualiza as métricas
        UpdateMetrics();
        m_lastCheck = currentTime;
    }
    
    // Verifica se uma nova posição pode ser aberta
    bool CanOpenPosition(double riskPercent = 0.0)
    {
        if(riskPercent <= 0.0) 
            riskPercent = m_metrics.maxPositionRisk;
        
        // Verifica se o número máximo de posições foi atingido
        if(PositionsTotal() >= m_metrics.maxOpenPositions)
        {
            Print("Não é possível abrir nova posição: Número máximo de posições atingido");
            return false;
        }
        
        // Verifica se o risco por posição é válido
        if(riskPercent > m_metrics.maxPositionRisk)
        {
            Print("Risco por posição (", riskPercent, "%) excede o máximo permitido (", m_metrics.maxPositionRisk, "%)");
            return false;
        }
        
        // Verifica se a perda diária máxima foi atingida
        double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
        double dailyLoss = 0.0;
        
        if(m_initialBalance > 0.0)
        {
            dailyLoss = ((m_initialBalance - currentBalance) / m_initialBalance) * 100.0;
        }
        
        if(dailyLoss >= m_metrics.maxDailyLoss)
        {
            Print("Não é possível abrir nova posição: Perda diária máxima atingida");
            return false;
        }
        
        return true;
    }
    
    // Define o risco máximo por posição (% do patrimônio)
    void SetMaxPositionRisk(double percent)
    {
        if(percent > 0.0 && percent <= 100.0)
        {
            m_metrics.maxPositionRisk = percent;
        }
    }
    
    // Define a perda diária máxima permitida (% do patrimônio)
    void SetMaxDailyLoss(double percent)
    {
        if(percent > 0.0 && percent <= 100.0)
        {
            m_metrics.maxDailyLoss = percent;
        }
    }
    
    // Define o número máximo de posições abertas simultaneamente
    void SetMaxOpenPositions(int maxPositions)
    {
        if(maxPositions > 0)
        {
            m_metrics.maxOpenPositions = maxPositions;
        }
    }
    
    // Obtém as métricas de risco atuais
    RiskMetrics GetMetrics() const
    {
        return m_metrics;
    }
    
    // Verifica se um Stop Loss é válido
    static bool IsValidStopLoss(const string symbol, const double entryPrice, const double stopLoss)
    {
        if(stopLoss <= 0.0) 
            return false; // Stop loss obrigatório
        
        double point_val = SymbolInfoDouble(symbol, SYMBOL_POINT);
        double stop_level = (double)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL) * point_val;
        double min_stop_distance = stop_level * 1.5; // Adiciona uma margem de segurança
        
        // Verifica a distância mínima do preço atual
        double current_price = SymbolInfoDouble(symbol, SYMBOL_ASK);
        double dist = MathAbs(entryPrice - stopLoss);
        
        return (dist >= min_stop_distance);
    }
    
    // Verifica se um Take Profit é válido
    static bool IsValidTakeProfit(const string symbol, const double entryPrice, const double takeProfit)
    {
        if(takeProfit <= 0.0) 
            return true; // Take profit opcional
        
        double point_val = SymbolInfoDouble(symbol, SYMBOL_POINT);
        double stop_level = (double)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL) * point_val;
        double min_take_profit_distance = stop_level * 1.5; // Adiciona uma margem de segurança
        
        // Verifica a distância mínima do preço atual
        double current_price = SymbolInfoDouble(symbol, SYMBOL_ASK);
        double dist = MathAbs(takeProfit - entryPrice);
        
        return (dist >= min_take_profit_distance);
    }
};

// Instância global do gerenciador de risco
CRiskManager g_risk_manager;

#endif // _RISK_MANAGER_MQH_
