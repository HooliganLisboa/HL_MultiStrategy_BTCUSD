//+------------------------------------------------------------------+
//|                                      strategy_initialization.mqh |
//|                  Copyright 2025, Hooligan Lisboa                 |
//|                 https://github.com/HooliganLisboa                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Hooligan Lisboa"
#property link      "https://github.com/HooliganLisboa"
#property strict

#ifndef STRATEGY_INITIALIZATION_MQH
#define STRATEGY_INITIALIZATION_MQH

// Incluir definições globais
#include "globals.mqh"
#include "strategy_base.mqh"

// Incluir estratégias refatoradas
#include "Strategies/strategy_a_refactored.mqh"
#include "Strategies/strategy_b_refactored.mqh"
#include "Strategies/strategy_c_refactored.mqh"
#include "Strategies/strategy_d_refactored.mqh"
#include "Strategies/strategy_e_refactored.mqh"
#include "Strategies/strategy_f_refactored.mqh"
#include "Strategies/strategy_g_refactored.mqh"
#include "Strategies/strategy_h_refactored.mqh"
#include "Strategies/strategy_i_refactored.mqh"
#include "Strategies/strategy_j_refactored.mqh"
#include "Strategies/strategy_k_refactored.mqh"
#include "Strategies/strategy_l_refactored.mqh"
#include "Strategies/strategy_m_refactored.mqh"
#include "Strategies/strategy_n_refactored.mqh"
#include "Strategies/strategy_o_refactored.mqh"
#include "Strategies/strategy_p_refactored.mqh"
#include "Strategies/strategy_q_refactored.mqh"
#include "Strategies/strategy_r_refactored.mqh"
#include "Strategies/strategy_s_refactored.mqh"
#include "Strategies/strategy_t_refactored.mqh"

//+------------------------------------------------------------------+
//| Funções para gerenciar as estratégias                            |
//+------------------------------------------------------------------+

// Array global para armazenar as estratégias ativas
CArrayObj* g_activeStrategies = NULL;

//+------------------------------------------------------------------+
//| Inicializa o gerenciador de estratégias                          |
//+------------------------------------------------------------------+
bool InitializeStrategyManager() {
    if(g_activeStrategies != NULL) {
        // Já foi inicializado
        Print("Gerenciador de estratégias já inicializado");
        return true;
    }
    
    g_activeStrategies = new CArrayObj();
    if(g_activeStrategies == NULL) {
        Print("Erro ao alocar memória para o gerenciador de estratégias");
        return false;
    }
    
    Print("Gerenciador de estratégias inicializado com sucesso");
    return true;
}

//+------------------------------------------------------------------+
//| Libera os recursos do gerenciador de estratégias                 |
//+------------------------------------------------------------------+
void DeinitializeStrategyManager() {
    if(g_activeStrategies != NULL) {
        // Liberar todas as estratégias
        for(int i = g_activeStrategies.Total() - 1; i >= 0; i--) {
            CStrategyBase* strategy = g_activeStrategies.At(i);
            if(strategy != NULL) {
                strategy.Deinitialize();
                delete strategy;
            }
        }
        g_activeStrategies.Clear();
        delete g_activeStrategies;
        g_activeStrategies = NULL;
    }
}

//+------------------------------------------------------------------+
//| Inicializa uma estratégia específica                             |
//+------------------------------------------------------------------+
bool InitializeStrategy(ENUM_STRATEGY strategy, string symbol, ENUM_TIMEFRAMES timeframe) {
    if(g_activeStrategies == NULL) {
        Print("Erro: Gerenciador de estratégias não inicializado");
        return false;
    }
    
    // Verificar se a estratégia já foi inicializada
    for(int i = 0; i < g_activeStrategies.Total(); i++) {
        CStrategyBase* existing = g_activeStrategies.At(i);
        if(existing != NULL && existing.GetStrategyId() == strategy) {
            Print("Estratégia ", EnumToString(strategy), " já está inicializada");
            return true;
        }
    }
    
    // Criar e inicializar a estratégia
    CStrategyBase* strategyObj = NULL;
    
    switch(strategy) {
        case STRATEGY_A: strategyObj = new CStrategyA(symbol, timeframe); break;
        case STRATEGY_B: strategyObj = new CStrategyB(symbol, timeframe); break;
        case STRATEGY_C: strategyObj = new CStrategyC(symbol, timeframe); break;
        case STRATEGY_D: strategyObj = new CStrategyD(symbol, timeframe); break;
        case STRATEGY_E: strategyObj = new CStrategyE(symbol, timeframe); break;
        case STRATEGY_F: strategyObj = new CStrategyF(symbol, timeframe); break;
        case STRATEGY_G: strategyObj = new CStrategyG(symbol, timeframe); break;
        case STRATEGY_H: strategyObj = new CStrategyH(symbol, timeframe); break;
        case STRATEGY_I: strategyObj = new CStrategyI(symbol, timeframe); break;
        case STRATEGY_J: strategyObj = new CStrategyJ(symbol, timeframe); break;
        case STRATEGY_K: strategyObj = new CStrategyK(symbol, timeframe); break;
        case STRATEGY_L: strategyObj = new CStrategyL(symbol, timeframe); break;
        case STRATEGY_M: strategyObj = new CStrategyM(symbol, timeframe); break;
        case STRATEGY_N: strategyObj = new CStrategyN(symbol, timeframe); break;
        case STRATEGY_O: strategyObj = new CStrategyO(symbol, timeframe); break;
        case STRATEGY_P: strategyObj = new CStrategyP(symbol, timeframe); break;
        case STRATEGY_Q: strategyObj = new CStrategyQ(symbol, timeframe); break;
        case STRATEGY_R: strategyObj = new CStrategyR(symbol, timeframe); break;
        case STRATEGY_S: strategyObj = new CStrategyS(symbol, timeframe); break;
        case STRATEGY_T: strategyObj = new CStrategyT(symbol, timeframe); break;
        default:
            Print("Estratégia não implementada: ", EnumToString(strategy));
            return false;
    }
    
    if(strategyObj == NULL) {
        Print("Falha ao criar a estratégia ", EnumToString(strategy));
        return false;
    }
    
    // Inicializar a estratégia
    if(!strategyObj.Initialize()) {
        Print("Falha ao inicializar a estratégia ", EnumToString(strategy));
        delete strategyObj;
        return false;
    }
    
    // Adicionar à lista de estratégias ativas
    if(g_activeStrategies.Add(strategyObj) < 0) {
        Print("Falha ao adicionar a estratégia ", EnumToString(strategy), " à lista de ativas");
        delete strategyObj;
        return false;
    }
    
    Print("Estratégia ", EnumToString(strategy), " inicializada com sucesso");
    return true;

//+------------------------------------------------------------------+
//| Inicializa os indicadores utilizados pela Estratégia A            |
//+------------------------------------------------------------------+
bool InitializeStrategyAIndicators()
{
    // Liberar handles anteriores se existirem
    if(g_handle_ma_a != INVALID_HANDLE) 
        IndicatorRelease(g_handle_ma_a);
    
    if(g_handle_psar_a != INVALID_HANDLE) 
        IndicatorRelease(g_handle_psar_a);
        
    // Inicializar MA para Estratégia A
    g_handle_ma_a = iMA(_Symbol, PERIOD_CURRENT, 
                       InpStrategyA_MA_Period, 
                       InpStrategyA_MA_Shift, 
                       InpStrategyA_MA_Method, 
                       InpStrategyA_MA_Applied);
    
    // Inicializar PSAR para Estratégia A
    g_handle_psar_a = iSAR(_Symbol, PERIOD_CURRENT, 
                          InpStrategyA_PSAR_Step, 
                          InpStrategyA_PSAR_Maximum);
    
    // Verificar se os handles foram criados corretamente
    if(g_handle_ma_a == INVALID_HANDLE || g_handle_psar_a == INVALID_HANDLE)
    {
        Print("Erro ao inicializar indicadores da Estratégia A: ", GetLastError());

    }
    
    Print("Indicadores da Estratégia A inicializados com sucesso. MA handle: ", 
          g_handle_ma_a, ", PSAR handle: ", g_handle_psar_a);

}

//+------------------------------------------------------------------+
//| Inicializa os indicadores utilizados pela Estratégia B            |
//+------------------------------------------------------------------+
bool InitializeStrategyBIndicators()
{
    // Liberar handles anteriores se existirem
    if(g_handle_rsi_b != INVALID_HANDLE) 
        IndicatorRelease(g_handle_rsi_b);
    
    if(g_handle_macd_b != INVALID_HANDLE) 
        IndicatorRelease(g_handle_macd_b);
        
    // Inicializar RSI para Estratégia B
    g_handle_rsi_b = iRSI(_Symbol, PERIOD_CURRENT, 
                         InpStrategyB_RSI_Period, 
                         PRICE_CLOSE, 0);
    
    // Inicializar MACD para Estratégia B
    g_handle_macd_b = iMACD(_Symbol, PERIOD_CURRENT, 
                           InpStrategyB_MACD_Fast, 
                           InpStrategyB_MACD_Slow, 
                           InpStrategyB_MACD_Signal, 
                           PRICE_CLOSE, 0);
    
    // Verificar se os handles foram criados corretamente
    if(g_handle_rsi_b == INVALID_HANDLE || g_handle_macd_b == INVALID_HANDLE)
    {
        Print("Erro ao inicializar indicadores da Estratégia B: ", GetLastError());

    }
    
    Print("Indicadores da Estratégia B inicializados com sucesso. RSI handle: ", 
          g_handle_rsi_b, ", MACD handle: ", g_handle_macd_b);

}

//+------------------------------------------------------------------+
//| Inicializa os indicadores utilizados pela Estratégia C            |
//+------------------------------------------------------------------+
bool InitializeStrategyCIndicators()
{
    // Liberar handles anteriores se existirem
    if(g_handle_adx_c != INVALID_HANDLE) 
        IndicatorRelease(g_handle_adx_c);
    
    // Inicializar ADX para Estratégia C
    g_handle_adx_c = iADX(_Symbol, PERIOD_CURRENT, 
                         InpStrategyC_ADX_Period, 
                         PRICE_CLOSE, 0);
    
    // Verificar se o handle foi criado corretamente
    if(g_handle_adx_c == INVALID_HANDLE)
    {
        Print("Erro ao inicializar indicadores da Estratégia C: ", GetLastError());

    }
    
    Print("Indicadores da Estratégia C inicializados com sucesso. ADX handle: ", 
          g_handle_adx_c);

}

//+------------------------------------------------------------------+
//| Inicializa os indicadores utilizados pela Estratégia D            |
//+------------------------------------------------------------------+
bool InitializeStrategyDIndicators()
{
    // Inicialização dos indicadores para a Estratégia D
    // Adicione a lógica de inicialização específica da Estratégia D aqui
    Print("Inicializando indicadores da Estratégia D");

}

//+------------------------------------------------------------------+
//| Inicializa os indicadores utilizados pela Estratégia E            |
//+------------------------------------------------------------------+
bool InitializeStrategyEIndicators()
{
    // Inicialização dos indicadores para a Estratégia E
    // Adicione a lógica de inicialização específica da Estratégia E aqui
    Print("Inicializando indicadores da Estratégia E");

}

//+------------------------------------------------------------------+
//| Inicializa os indicadores utilizados pela Estratégia F            |
//+------------------------------------------------------------------+
bool InitializeStrategyFIndicators()
{
    // Inicialização dos indicadores para a Estratégia F
    // Adicione a lógica de inicialização específica da Estratégia F aqui
    Print("Inicializando indicadores da Estratégia F");

}

//+------------------------------------------------------------------+
//| Inicializa os indicadores utilizados pela Estratégia G            |
//+------------------------------------------------------------------+
bool InitializeStrategyGIndicators()
{
    // Inicialização dos indicadores para a Estratégia G
    // Adicione a lógica de inicialização específica da Estratégia G aqui
    Print("Inicializando indicadores da Estratégia G");

}

//+------------------------------------------------------------------+
//| Inicializa os indicadores utilizados pela Estratégia H            |
//+------------------------------------------------------------------+
bool InitializeStrategyHIndicators()
{
    // Inicialização dos indicadores para a Estratégia H
    // Adicione a lógica de inicialização específica da Estratégia H aqui
    Print("Inicializando indicadores da Estratégia H");

}

//+------------------------------------------------------------------+
//| Inicializa os indicadores utilizados pela Estratégia I            |
//+------------------------------------------------------------------+
bool InitializeStrategyIIndicators()
{
    // Inicialização dos indicadores para a Estratégia I
    // Adicione a lógica de inicialização específica da Estratégia I aqui
    Print("Inicializando indicadores da Estratégia I");

}

//+------------------------------------------------------------------+
//| Inicializa os indicadores utilizados pela Estratégia J            |
//+------------------------------------------------------------------+
bool InitializeStrategyJIndicators()
{
    // Inicialização dos indicadores para a Estratégia J
    // Adicione a lógica de inicialização específica da Estratégia J aqui
    Print("Inicializando indicadores da Estratégia J");

}

//+------------------------------------------------------------------+
//| Inicializa os indicadores utilizados pela Estratégia K            |
//+------------------------------------------------------------------+
bool InitializeStrategyKIndicators()
{
    // Inicialização dos indicadores para a Estratégia K
    // Adicione a lógica de inicialização específica da Estratégia K aqui
    Print("Inicializando indicadores da Estratégia K");

}

//+------------------------------------------------------------------+
//| Inicializa os indicadores utilizados pela Estratégia L            |
//+------------------------------------------------------------------+
bool InitializeStrategyLIndicators()
{
    // Inicialização dos indicadores para a Estratégia L
    // Adicione a lógica de inicialização específica da Estratégia L aqui
    Print("Inicializando indicadores da Estratégia L");

}

//+------------------------------------------------------------------+
//| Inicializa os indicadores utilizados pela Estratégia M            |
//+------------------------------------------------------------------+
bool InitializeStrategyMIndicators()
{
    // Inicialização dos indicadores para a Estratégia M
    // Adicione a lógica de inicialização específica da Estratégia M aqui
    Print("Inicializando indicadores da Estratégia M");

}

//+------------------------------------------------------------------+
//| Inicializa os indicadores utilizados pela Estratégia N            |
//+------------------------------------------------------------------+
bool InitializeStrategyNIndicators()
{
    // Inicialização dos indicadores para a Estratégia N
    // Adicione a lógica de inicialização específica da Estratégia N aqui
    Print("Inicializando indicadores da Estratégia N");

}

//+------------------------------------------------------------------+
//| Inicializa os indicadores utilizados pela Estratégia O            |
//+------------------------------------------------------------------+
bool InitializeStrategyOIndicators()
{
    // Inicialização dos indicadores para a Estratégia O
    // Adicione a lógica de inicialização específica da Estratégia O aqui
    Print("Inicializando indicadores da Estratégia O");

}

//+------------------------------------------------------------------+
//| Inicializa os indicadores utilizados pela Estratégia P            |
//+------------------------------------------------------------------+
bool InitializeStrategyPIndicators()
{
    // Inicialização dos indicadores para a Estratégia P (Price Action)
    Print("Inicializando indicadores da Estratégia P - Price Action");
    
    // O ATR é inicializado na própria estratégia
    // Esta função está aqui para manter a consistência com as outras estratégias

}

//+------------------------------------------------------------------+
//| Inicializa os indicadores utilizados pela Estratégia Q            |
//+------------------------------------------------------------------+
bool InitializeStrategyQIndicators()
{
    // Inicialização dos indicadores para a Estratégia Q
    Print("Inicializando indicadores da Estratégia Q");
    
    // Os indicadores são criados diretamente na classe CStrategyQ
    // Esta função é mantida para manter a consistência com outras estratégias
    // mas a inicialização real dos indicadores é feita no método InitializeIndicators() da classe CStrategyQ
    
    return true;
}

//+------------------------------------------------------------------+
//| Inicializa os indicadores utilizados pela Estratégia R            |
//+------------------------------------------------------------------+
bool InitializeStrategyRIndicators()
{
    // Inicialização dos indicadores para a Estratégia R
    // Adicione a lógica de inicialização específica da Estratégia R aqui
    Print("Inicializando indicadores da Estratégia R");

}

//+------------------------------------------------------------------+
//| Inicializa os indicadores utilizados pela Estratégia S            |
//+------------------------------------------------------------------+
bool InitializeStrategySIndicators()
{
    // Inicialização dos indicadores para a Estratégia S
    // Adicione a lógica de inicialização específica da Estratégia S aqui
    Print("Inicializando indicadores da Estratégia S");

}

//+------------------------------------------------------------------+
//| Inicializa os indicadores utilizados pela Estratégia T            |
//+------------------------------------------------------------------+
bool InitializeStrategyTIndicators()
{
    // Inicialização dos indicadores para a Estratégia T
    // Adicione a lógica de inicialização específica da Estratégia T aqui
    Print("Inicializando indicadores da Estratégia T");

}

//+------------------------------------------------------------------+
//| Inicializa os indicadores de uma estratégia específica             |
//+------------------------------------------------------------------+
bool InitializeStrategyIndicators(ENUM_STRATEGY strategy) {
    switch(strategy) {
        case STRATEGY_A: return InitializeStrategyAIndicators();
        case STRATEGY_B: return InitializeStrategyBIndicators();
        case STRATEGY_C: return InitializeStrategyCIndicators();
        case STRATEGY_D: return InitializeStrategyDIndicators();
        case STRATEGY_E: return InitializeStrategyEIndicators();
        case STRATEGY_F: return InitializeStrategyFIndicators();
        case STRATEGY_G: return InitializeStrategyGIndicators();
        case STRATEGY_H: return InitializeStrategyHIndicators();
        case STRATEGY_I: return InitializeStrategyIIndicators();
        case STRATEGY_J: return InitializeStrategyJIndicators();
        case STRATEGY_K: return InitializeStrategyKIndicators();
        case STRATEGY_L: return InitializeStrategyLIndicators();
        case STRATEGY_M: return InitializeStrategyMIndicators();
        case STRATEGY_N: return InitializeStrategyNIndicators();
        case STRATEGY_O: return InitializeStrategyOIndicators();
        case STRATEGY_P: return InitializeStrategyPIndicators();
        case STRATEGY_Q: return InitializeStrategyQIndicators();
        case STRATEGY_R: return InitializeStrategyRIndicators();
        case STRATEGY_S: return InitializeStrategySIndicators();
        case STRATEGY_T: return InitializeStrategyTIndicators();
        default:
            Print("Estratégia não implementada: ", EnumToString(strategy));
            return false;
    }
}

//+------------------------------------------------------------------+
//| Verifica se uma estratégia está habilitada                        |
//+------------------------------------------------------------------+
bool IsStrategyEnabled(ENUM_STRATEGY strategy) {
    switch(strategy) {
        case STRATEGY_A: return InpUseStrategyA;
        case STRATEGY_B: return InpUseStrategyB;
        case STRATEGY_C: return InpUseStrategyC;
        case STRATEGY_D: return InpUseStrategyD;
        case STRATEGY_E: return InpUseStrategyE;
        case STRATEGY_F: return InpUseStrategyF;
        case STRATEGY_G: return InpUseStrategyG;
        case STRATEGY_H: return InpUseStrategyH;
        case STRATEGY_I: return InpUseStrategyI;
        case STRATEGY_J: return InpUseStrategyJ;
        case STRATEGY_K: return InpUseStrategyK;
        case STRATEGY_L: return InpUseStrategyL;
        case STRATEGY_M: return InpUseStrategyM;
        case STRATEGY_N: return InpUseStrategyN;
        case STRATEGY_O: return InpUseStrategyO;
        case STRATEGY_P: return InpUseStrategyP;
        case STRATEGY_Q: return InpUseStrategyQ;
        case STRATEGY_R: return InpUseStrategyR;
        case STRATEGY_S: return InpUseStrategyS;
        case STRATEGY_T: return InpUseStrategyT;
        default: return false;
    }
}

//+------------------------------------------------------------------+
//| Inicializa uma estratégia específica                              |
//+------------------------------------------------------------------+
bool InitializeStrategy(ENUM_STRATEGY strategy, string symbol, ENUM_TIMEFRAMES timeframe) {
    // Esta função pode ser implementada para inicializar uma estratégia específica
    // com base no tipo de estratégia, símbolo e timeframe fornecidos
    // Por enquanto, apenas retornamos true para indicar sucesso
    return true;
}

//+------------------------------------------------------------------+
//| Inicializa os indicadores de todas as estratégias ativas          |
//+------------------------------------------------------------------+
bool InitializeAllStrategyIndicators() {
    bool success = true;
    
    // Inicializar indicadores comuns
    if(!InitializeCommonIndicators()) {
        Print("Falha ao inicializar indicadores comuns");
        success = false;
    }
    
    // Inicializar indicadores específicos de cada estratégia ativa
    for(int i = STRATEGY_A; i < STRATEGY_COUNT; i++) {
        ENUM_STRATEGY strategy = (ENUM_STRATEGY)i;
        
        if(IsStrategyEnabled(strategy)) {
            if(!InitializeStrategyIndicators(strategy)) {
                Print("Falha ao inicializar indicadores da estratégia ", EnumToString(strategy));
                success = false;
            }
        }
    }
    
    return success;
}

#endif // STRATEGY_INITIALIZATION_MQH
