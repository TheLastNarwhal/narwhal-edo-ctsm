--Advent of the End
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  --Activation - again, long list of effects, so not gonna list them here...
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
  e1:SetCondition(s.condition)
  e1:SetTarget(s.target)
  e1:SetOperation(s.activate)
  c:RegisterEffect(e1)
  --Flag operation for conditional activation
  aux.GlobalCheck(s,function()
    local ge1=Effect.CreateEffect(c)
    ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
    ge1:SetOperation(s.checkop)
    Duel.RegisterEffect(ge1,0)
  end)
end
s.listed_names={465399}
s.toss_coin=true
--Flagcheck for conditional activation
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
  for ec in aux.Next(eg) do
    if ec:IsCode(465399) and ec:IsFaceup() then Duel.RegisterFlagEffect(ec:GetSummonPlayer(),id,0,0,0) end
    --Debug.Message("[flag value] is "..tostring(Duel.GetFlagEffect(tp,id)))
  end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
  --Debug.Message("[flag value] is "..tostring(Duel.GetFlagEffect(tp,id)))
  return Duel.GetFlagEffect(tp,id)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,1-tp,1)
end
function s.rmfilter(c)
  return c:IsAbleToRemove() and aux.SpElimFilter(c)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
  local res=Duel.TossCoin(1-tp,1)
  if res==1 then
    --e:SetLabel(res)
    --Debug.Message("[Heads label] is "..tostring(e:GetLabel()))
    local death=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>1
    local val=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
    local taxes=Duel.CheckLPCost(1-tp,400*val) and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0
    if not death and not taxes then return end
    local op=0
    if death and not taxes then op=Duel.SelectOption(1-tp,aux.Stringid(id,0))
    elseif not death and taxes then op=Duel.SelectOption(1-tp,aux.Stringid(id,1))+1
    else op=Duel.SelectOption(1-tp,aux.Stringid(id,0),aux.Stringid(id,1))
    end
    if op==0 then
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
      local ban1=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
      ban2=Duel.SelectMatchingCard(1-tp,Card.IsAbleToRemove,1-tp,LOCATION_ONFIELD,0,1,1,nil)
      ban1:Merge(ban2)
      Duel.HintSelection(ban1)
      if Duel.Remove(ban1,POS_FACEUP,REASON_RULE)==2 then
        local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
        local g2=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,nil)
        local g3=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
        local sg=Group.CreateGroup()
        if #g1>0 and ((#g2==0 and #g3==0) or Duel.SelectYesNo(tp,aux.Stringid(id,4))) then
          Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
          local sg1=g1:Select(tp,1,1,nil)
          Duel.HintSelection(sg1)
          sg:Merge(sg1)
        end
        if #g2>0 and ((#sg==0 and #g3==0) or Duel.SelectYesNo(tp,aux.Stringid(id,5))) then
          Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
          local sg2=g2:Select(tp,1,1,nil)
          Duel.HintSelection(sg2)
          sg:Merge(sg2)
        end
        if #g3>0 and (#sg==0 or Duel.SelectYesNo(tp,aux.Stringid(id,6))) then
          Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
          local sg3=g3:RandomSelect(tp,1)
          sg:Merge(sg3)
        end
        Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
      end
    else
      local val=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
      Duel.PayLPCost(1-tp,400*val)
      --e:SetLabel(op)
      --Debug.Message("[Player choice] is "..tostring(e:GetLabel()))
    end
  else
    local time=Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_TURN)==nil
    local hand=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
    local knowledge=hand<8 and Duel.IsPlayerCanDraw(tp,8-hand)
    if not time and not knowledge then return end
    local op=0
    if time and not knowledge then op=Duel.SelectOption(1-tp,aux.Stringid(id,2))
    elseif not time and knowledge then op=Duel.SelectOption(1-tp,aux.Stringid(id,3))+1
    else op=Duel.SelectOption(1-tp,aux.Stringid(id,2),aux.Stringid(id,3))
    end
    if op==0 then
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
      e1:SetCode(EFFECT_SKIP_TURN)
      e1:SetTargetRange(0,1)
      e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
      Duel.RegisterEffect(e1,tp)
      --e:SetLabel(op)
      --Debug.Message("[Player choice] is "..tostring(e:GetLabel()))
    else
      Duel.Draw(tp,8-hand,REASON_EFFECT)
      --e:SetLabel(op)
      --Debug.Message("[Player choice] is "..tostring(e:GetLabel()))
    end
  end
end
