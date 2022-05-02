--Witches' Eye
--Scripted by Narwhal
local s,id=GetID()
function s.initial_effect(c)
  aux.AddEquipProcedure(c,0,aux.FilterBoolFunction(Card.IsSetCard,0x197))
  --Look at top 3 cards of your deck, choose top or bottom, then order
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1,id)
  e1:SetCost(s.spycost)
  e1:SetTarget(s.spytg)
  e1:SetOperation(s.spyop)
  c:RegisterEffect(e1)
end
s.listed_series={0x197}
--Pay 1000 LP to activate and equipped monster cannot have declared/cannot declare an attack the turn you activate
function s.spycost(e,tp,eg,ep,ev,re,r,rp,chk)
  local atk=e:GetHandler():GetEquipTarget():GetAttackAnnouncedCount()
  if atk~=0 then return false end
  if chk==0 then return Duel.CheckLPCost(tp,1000) end
  Duel.PayLPCost(tp,1000)
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_EQUIP)
  e1:SetCode(EFFECT_CANNOT_ATTACK)
  e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
  e:GetHandler():RegisterEffect(e1)
end
--Look at top 3 cards of your deck, choose top or bottom, then order
function s.spytg(e,tp,eg,ep,ev,re,r,rp,chk)
  --if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
  if chk==0 then return true end
  local you=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2
  local opp=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>2
  local op=2
  if (you or opp) then
    if you and opp then
      op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    elseif you then
      op=Duel.SelectOption(tp,aux.Stringid(id,0))
    else
      op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
    end
    if op==2 then
      e:SetLabel(op)
      --Debug.Message("[set label for player] is "..tostring(e:GetLabel()))
    else
      e:SetLabel(op)
      --Debug.Message("[set label for player] is "..tostring(e:GetLabel()))
    end
  end
end
function s.spyop(e,tp,eg,ep,ev,re,r,rp)
  local player=e:GetLabel()
  --Debug.Message("[recieve label for player] is "..tostring(e:GetLabel()))
  if player==0 then
    local g=Duel.GetDecktopGroup(tp,3)
    Duel.ConfirmCards(tp,g)
    local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    if opt==1 then
      for tc in g:Iter() do
        Duel.MoveSequence(tc,opt)
        e:SetLabel(opt)
        --Debug.Message("[bottom set] is "..tostring(e:GetLabel()))
      end
    end
    local bottom=e:GetLabel()
    --Debug.Message("[bottom recieve] is "..tostring(bottom))
    if bottom==0 then
      Duel.SortDecktop(tp,tp,3)
      e:SetLabel(0)
      --Debug.Message("[current label] is "..tostring(e:GetLabel()))
      --Debug.Message("[current label for player] is "..tostring(e:GetLabel()))
    elseif bottom==1 then
      Duel.SortDeckbottom(tp,tp,3)
      e:SetLabel(0)
      --Debug.Message("[current label] is "..tostring(e:GetLabel()))
      --Debug.Message("[current label for player] is "..tostring(e:GetLabel()))
    end
  else
    local g=Duel.GetDecktopGroup(1-tp,3)
    Duel.ConfirmCards(tp,g)
    e:SetLabel(0)
    --Debug.Message("[current label for player] is "..tostring(e:GetLabel()))
    local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    if opt==1 then
      for tc in g:Iter() do
        Duel.MoveSequence(tc,opt)
        e:SetLabel(opt)
        --Debug.Message("[bottom set] is "..tostring(e:GetLabel()))
      end
    end
    local bottom=e:GetLabel()
    --Debug.Message("[bottom recieve] is "..tostring(bottom))
    if bottom==0 then
      Duel.SortDecktop(tp,1-tp,3)
      e:SetLabel(0)
      --Debug.Message("[current label] is "..tostring(e:GetLabel()))
      --Debug.Message("[current label for player] is "..tostring(e:GetLabel()))
    elseif bottom==1 then
      Duel.SortDeckbottom(tp,1-tp,3)
      e:SetLabel(0)
      --Debug.Message("[current label] is "..tostring(e:GetLabel()))
      --Debug.Message("[current label for player] is "..tostring(e:GetLabel()))
    end
  end
end
