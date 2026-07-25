# TODO - Correções do Sistema de Lembretes de Contactos

## Informação Recolhida
- `isOverdue` em `contact_model.dart` usa `>` em vez de `>=` (notifica 1 dia tarde)
- Cloud Functions `checkOverdueContacts` usa `<=` em vez de `<` (também 1 dia tarde)
- Client-side: contactos sem interações (`daysSinceLastContact == -1`) → `isOverdue = false` (NUNCA notifica)
- Server-side: contactos sem interações → `daysSinceLastContact = 999` → notifica (inconsistente)
- ID de notificação mensal no servidor só permite 1 notificação/mês, mas para "Toda semana" precisamos semanal
- IDs de notificação diferentes entre client e server podem causar duplicados

## Plano de Correção - CONCLUÍDO ✅

### Passo 1: Corrigir `contact_model.dart` ✅
- `isOverdue`: Mudar `>` para `>=` — notifica no dia 7 em vez do dia 8
- `daysSinceLastContact`: Quando `null`, retornar 999 (consistente com server) em vez de -1

### Passo 2: Corrigir `notification_scheduler.dart` (client-side) ✅
- Actualizar `_checkOverdueContacts` para tratar `daysSinceLastContact >= 999` (nunca contactado)
- Sincronizar formato do ID para usar chave determinística por período
- Dupla verificação: por ID único do período + por notificações não lidas pendentes

### Passo 3: Corrigir `functions/index.js` (server-side) ✅
- `checkOverdueContacts`: Mudar `<=` para `<` no `daysSinceLastContact < desiredFrequency`
- Melhorar ID de notificação para usar ISO week (semanal), fortnight (quinzenal) ou month (mensal)
- Garantir contactos nunca contactados (sem interações) geram notificação corretamente (daysSinceLastContact = 999)

