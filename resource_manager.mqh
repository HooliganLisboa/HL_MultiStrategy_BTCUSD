//+------------------------------------------------------------------+
//|                                              resource_manager.mqh |
//|                  Copyright 2025, Hooligan Lisboa                 |
//|                 https://github.com/HooliganLisboa                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Hooligan Lisboa"
#property link      "https://github.com/HooliganLisboa"
#property strict

#ifndef _RESOURCE_MANAGER_MQH_
#define _RESOURCE_MANAGER_MQH_


#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>

// Incluir arquivos locais
#include "globals.mqh"
#include "utilities.mqh"

//+------------------------------------------------------------------+
//| Classe para armazenar informações de um handle de indicador      |
//+------------------------------------------------------------------+
class CIndicatorHandle : public CObject
{
public:
   int handle;
   string name;
   
   // Construtor
   CIndicatorHandle(int h = INVALID_HANDLE, string n = "") : handle(h), name(n) {}
   
   // Destrutor - libera o handle se for válido
   ~CIndicatorHandle() {
      if(handle != INVALID_HANDLE) {
         IndicatorRelease(handle);
         handle = INVALID_HANDLE;
      }
   }
   
   // Operador de comparação
   virtual int Compare(const CObject* node, const int mode=0) const {
      const CIndicatorHandle* other = node;
      if(other == NULL) return -1;
      
      if(mode == 0) {
         // Comparação por handle
         if(handle < other.handle) return -1;
         if(handle > other.handle) return 1;
      } else {
         // Comparação por nome
         return StringCompare(name, other.name);
      }
      
      return 0;
   }
};

//+------------------------------------------------------------------+
//| Classe para gerenciar recursos de indicadores                    |
//+------------------------------------------------------------------+
class CResourceManager : public CObject
{
private:
   CArrayObj m_handles;  // Lista de handles gerenciados
   
   // Encontra um handle pelo nome
   int FindHandleByName(const string name) const {
      if(name == "" || m_handles.Total() == 0) return -1;
      
      for(int i = 0; i < m_handles.Total(); i++) {
         CIndicatorHandle* h = dynamic_cast<CIndicatorHandle*>(m_handles.At(i));
         if(h != NULL && h.name == name) {
            return i;
         }
      }
      
      return -1;
   }
   
   // Encontra um handle pelo valor
   int FindHandleByValue(const int handle) const {
      if(handle == INVALID_HANDLE || m_handles.Total() == 0) return -1;
      
      for(int i = 0; i < m_handles.Total(); i++) {
         CIndicatorHandle* h = dynamic_cast<CIndicatorHandle*>(m_handles.At(i));
         if(h != NULL && h.handle == handle) {
            return i;
         }
      }
      
      return -1;
   }
   
public:
   // Construtor
   CResourceManager() {
      m_handles.FreeMode(true);  // Habilita a exclusão automática dos objetos
   }
   
   // Destrutor - libera todos os recursos
   ~CResourceManager() {
      ReleaseAll();
   }
   
   // Adiciona um handle ao gerenciador
   bool AddHandle(int handle, const string name = "") {
      if(handle == INVALID_HANDLE) {
         Print("Erro: Tentativa de adicionar handle inválido");
         return false;
      }
      
      // Verifica se o handle já existe
      if(FindHandleByValue(handle) >= 0) {
         Print("Aviso: Handle já existe no gerenciador");
         return true;
      }
      
      // Verifica se já existe um handle com o mesmo nome
      if(name != "" && FindHandleByName(name) >= 0) {
         Print("Aviso: Já existe um handle com o nome '", name, "'");
         return false;
      }
      
      // Adiciona o novo handle
      CIndicatorHandle* h = new CIndicatorHandle(handle, name);
      if(h == NULL) {
         Print("Erro ao alocar memória para o handle");
         return false;
      }
      
      if(!m_handles.Add(h)) {
         delete h;
         Print("Erro ao adicionar handle à lista");
         return false;
      }
      
      return true;
   }
   
   // Remove e libera um handle pelo nome
   bool RemoveHandle(const string name) {
      int index = FindHandleByName(name);
      if(index < 0) {
         Print("Aviso: Handle com nome '", name, "' não encontrado");
         return false;
      }
      
      // Remove o handle da lista (o destrutor libera o recurso)
      return m_handles.Delete(index);
   }
   
   // Remove e libera um handle pelo valor
   bool RemoveHandle(const int handle) {
      int index = FindHandleByValue(handle);
      if(index < 0) {
         Print("Aviso: Handle ", handle, " não encontrado");
         return false;
      }
      
      // Remove o handle da lista (o destrutor libera o recurso)
      return m_handles.Delete(index);
   }
   
   // Obtém um handle pelo nome
   int GetHandle(const string name) const {
      int index = FindHandleByName(name);
      if(index < 0) return INVALID_HANDLE;
      
      CIndicatorHandle* h = dynamic_cast<CIndicatorHandle*>(m_handles.At(index));
      return (h != NULL) ? h.handle : INVALID_HANDLE;
   }
   
   // Verifica se um handle existe
   bool HandleExists(const int handle) const {
      return (FindHandleByValue(handle) >= 0);
   }
   
   bool HandleExists(const string name) const {
      return (FindHandleByName(name) >= 0);
   }
   
   // Libera todos os recursos gerenciados
   void ReleaseAll() {
      m_handles.Clear();
   }
   
   // Retorna o número de handles gerenciados
   int TotalHandles() const {
      return m_handles.Total();
   }
   
   // Obtém o nome de um handle
   string GetHandleName(const int handle) const {
      int index = FindHandleByValue(handle);
      if(index < 0) return "";
      
      CIndicatorHandle* h = dynamic_cast<CIndicatorHandle*>(m_handles.At(index));
      return (h != NULL) ? h.name : "";
   }
   
   // Obtém um array com todos os handles gerenciados
   void GetHandles(int &handles[]) {
      int count = m_handles.Total();
      ArrayResize(handles, count);
      
      for(int i = 0; i < count; i++) {
         CIndicatorHandle* h = dynamic_cast<CIndicatorHandle*>(m_handles.At(i));
         handles[i] = (h != NULL) ? h.handle : INVALID_HANDLE;
      }
   }
   
   // Obtém um array com todos os nomes de handles
   void GetHandleNames(string &names[]) {
      int count = m_handles.Total();
      ArrayResize(names, count);
      
      for(int i = 0; i < count; i++) {
         CIndicatorHandle* h = dynamic_cast<CIndicatorHandle*>(m_handles.At(i));
         names[i] = (h != NULL) ? h.name : "";
      }
   }
};

#endif // _RESOURCE_MANAGER_MQH_
