--Witch's Bubbling Cauldron
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --Activation
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_ACTIVATE)
  e0:SetCode(EVENT_FREE_CHAIN)
  c:RegisterEffect(e0)
  --Tribute 1 monster from hand or field, gain HP equal to Tributed monster's LV x 500
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_RECOVER+CATEGORY_DAMAGE)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1,id)
  e1:SetCost(s.tribcost)
  e1:SetTarget(s.tribtg)
  e1:SetOperation(s.tribop)
  c:RegisterEffect(e1)
end
s.listed_names={465393}
--Tribute 1 monster from hand or field, gain HP equal to Tributed monster's LV x 500
function s.tribfilter(c)
  return c:IsType(TYPE_MONSTER) and c:GetLevel()>0 and c:IsReleasable()
end
function s.tribcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.tribfilter,1,true,nil,nil,tp) end
  local sg=Duel.SelectReleaseGroupCost(tp,s.tribfilter,1,1,true,nil,nil,tp)
  e:SetLabel(sg:GetFirst():GetLevel()*500)
  Duel.Release(sg,REASON_COST)
  if sg:GetFirst():GetOriginalCode()==465393 then
    e:SetLabelObject(sg)
    --Debug.Message("[label] is "..tostring(e:GetLabelObject()))
  else
    e:SetLabelObject(nil)
    --Debug.Message("[label] is "..tostring(e:GetLabelObject()))
  end
end
function s.tribtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SetTargetPlayer(tp)
  Duel.SetTargetParam(e:GetLabel())
  Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabel())
end
function s.tribop(e,tp,eg,ep,ev,re,r,rp)
  local newt=e:GetLabelObject()
  local newtfilter=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,465393)
  local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
  Duel.Recover(p,d,REASON_EFFECT)
  --Debug.Message("[code] is "..tostring(code))
  if newt~=nil then
    if Duel.Damage(1-tp,newtfilter*500,REASON_EFFECT)>0 and newtfilter==3 then
      local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
      if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local sg=g:Select(tp,1,1,nil)
        Duel.Destroy(sg,REASON_EFFECT)
  		end
    end
  end
end
