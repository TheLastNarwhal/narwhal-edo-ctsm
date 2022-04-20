--Sirenity's True Nature
--Scripted by Narwhal / Created by Lacooda
local s,id=GetID()
function s.initial_effect(c)
  --Fusion Summon 1 "Sansirenity" fusion monster using monsters from hand or field as fusion materials, or deck if no attack
  local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0x196),nil,s.fextra)
  c:RegisterEffect(e1)
  AshBlossomTable=AshBlossomTable or {}
  table.insert(AshBlossomTable,e1)
end
s.listed_series={0x196}
function s.fcheck(tp,sg,fc)
  return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.fextra(e,tp,mg)
  if Duel.GetTurnPlayer()~=tp and Duel.GetCurrentPhase()==PHASE_END and Duel.GetActivityCount(1-tp,ACTIVITY_ATTACK)==0 then
    local eg=Duel.GetMatchingGroup(s.exfilter,tp,LOCATION_DECK,0,nil)
    if eg and #eg>0 then
      return eg,s.fcheck
    end
  end
  return nil
end
function s.exfilter(c)
  return c:IsMonster() and c:IsSetCard(0x196) and c:IsAbleToGrave()
end
