local _, addon = ...;

local Factory = addon.OptionFactory;

local EditBox = {};

EditBox.__index = EditBox;

function EditBox:New (parent, name, anchorFrame, xOffset, yOffset, width, height, anchor, parentAnchor)
  local back = CreateFrame('Frame', name .. 'Back', parent)
  local edit = CreateFrame('EditBox', name .. 'EditBox', back);
  local scroll = CreateFrame('ScrollFrame', name .. 'ScrollFrame', back, 'UIPanelScrollFrameTemplate');
  local this = {};

  setmetatable(this, EditBox);

  this.edit = edit;

  anchor = anchor or 'TOPLEFT';
  parentAnchor = parentAnchor or 'BOTTOMLEFT';

  back:SetBackdrop({
    -- bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\PVPFrame\\UI-Character-PVP-Highlight',
    edgeSize = 10,
    -- insets = { left = 20, right = 20, top = 20, bottom = 20 },
  });

  back:SetSize(width, height);
  back:SetPoint(anchor, anchorFrame, parentAnchor, xOffset, yOffset);

  edit:SetAutoFocus(false);
  edit:SetMultiLine(true);
  edit:EnableMouse(true);
  edit:SetMaxLetters(1000);

  --edit:SetFontObject('ChatFontNormal');
  --edit:SetFontObject(GameFontNormal);
  --edit:SetFont(addon.vars.font, 16, 'THINOUTLINE');
  edit:SetFont(GameFontNormal:GetFont(), 16, 'THINOUTLINE');

  edit:SetSize(width, height);

  edit:SetPoint('TOPLEFT', scroll, 'TOPLEFT', 0, 0);
  edit:SetPoint('BOTTOMRIGHT', scroll, 'BOTTOMRIGHT', 0, 0);
   edit:SetTextInsets(8, 8, 8, 8);
  edit:SetScript('OnEscapePressed', edit.ClearFocus);
  edit:Show();


  scroll:SetPoint('TOPLEFT', back, 'TOPLEFT', 0, -4);
  scroll:SetPoint('BOTTOMRIGHT', back, 'BOTTOMRIGHT', -6, 4);
  scroll:SetScrollChild(edit);
  scroll:SetScript('OnMouseDown', function ()
    edit:SetFocus();
  end);
  scroll:SetScript('OnVerticalScroll', function ()
    print(edit:HasFocus());

  end);

  return this;
end

function EditBox:GetText ()
  return self.edit:GetText();
end

EditBox.GetValue = EditBox.GetText;

function EditBox:SetText (text)
  self.edit:SetText(text);
end

EditBox.SetValue = EditBox.SetText;

Factory.EditBox = EditBox;
