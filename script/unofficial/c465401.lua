--Ritual of the Three Witches
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --Activation - normally I'd describe it, but it's a long chain of conditional effects XD
  local e1=Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_TODECK)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id)
  e1:SetCondition(s.condition)
  e1:SetTarget(s.target)
  e1:SetOperation(s.activate)
  c:RegisterEffect(e1)
end
s.listed_names={465386}
--Filter for activation
function s.cfilter(c)
  return Duel.IsEnvironment(465386)
end
--Activation conditions
function s.condition(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_FZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
  if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) and Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
  local g1=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
  local g2=Duel.SelectTarget(1-tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
  g1:Merge(g2)
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
end
--Chain of conditional effects
function s.activate(e,tp,eg,ep,ev,re,r,rp)
  --Destroy both targeted cards
  local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
  local tg=g:Filter(Card.IsRelateToEffect,nil,e)
  --If both cards were destroyed, each player can banish 1 card from opponent's hand
  if Duel.Destroy(tg,REASON_EFFECT)>1 then
    local b1=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
    if #b1>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
      Duel.ConfirmCards(tp,b1)
      local b1a=b1:Select(tp,1,1,nil)
      Duel.HintSelection(b1a)
      if Duel.Remove(b1a,POS_FACEUP,REASON_EFFECT) then
        Duel.ShuffleHand(1-tp)
        local b2=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
        if #b2>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
          Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
          Duel.ConfirmCards(1-tp,b2)
          local b2a=b2:Select(1-tp,1,1,nil)
          Duel.HintSelection(b2a)
          if Duel.Remove(b2a,POS_FACEUP,REASON_EFFECT)~=0 then
            Duel.ShuffleHand(tp)
            --If both players banished 1 card from opponent's hand, shuffle 1 card from opponent's GY to Deck
            local gy1=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE)
            if #gy1>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
              Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
              local gy1a=gy1:Select(tp,1,1,nil)
              Duel.ConfirmCards(tp,gy1a)
              Duel.SendtoDeck(gy1a,nil,0,REASON_EFFECT)
              local gy2=Duel.GetFieldGroup(tp,LOCATION_GRAVE,0)
              if #gy2>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,3)) then
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
                local gy2a=gy2:Select(1-tp,1,1,nil)
                Duel.ConfirmCards(1-tp,gy2a)
                Duel.SendtoDeck(gy2a,nil,0,REASON_EFFECT)
              end
            end
          end
        end
      end
    end
  end
end
