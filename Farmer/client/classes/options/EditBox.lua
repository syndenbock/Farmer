local _, addon = ...;

local CreateFrame = _G.CreateFrame;
local CreateFromMixins = _G.CreateFromMixins;
local GameFontNormal = _G.GameFontNormal;

local BACKDROP_TEMPLATE = _G.BackdropTemplateMixin and 'BackdropTemplate';

local EditBox = addon.export('Class/Options/EditBox', {});

local function createScroll (name, parent, editBox)
  local scroll = CreateFrame('ScrollFrame', name .. 'ScrollFrame', parent,
      'UIPanelScrollFrameTemplate');

  scroll:SetPoint('TOPLEFT', parent, 'TOPLEFT', 0, -4);
  scroll:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -6, 4);
  scroll:SetScrollChild(editBox);
  scroll:HookScript('OnMouseDown', function ()
    editBox:SetFocus();
  end);
  scroll:HookScript('OnScrollRangeChanged', function (self, _, yrange)
    if (editBox:GetNumLetters() == editBox:GetCursorPosition()) then
      self:SetVerticalScroll(yrange);
    end
  end);

  return scroll;
end

local function createEditbox (name, parent, width, height)
  local edit = CreateFrame('EditBox', name .. 'EditBox', parent);
  local scroll = createScroll(name, parent, edit);

  edit:SetAutoFocus(false);
  edit:SetMultiLine(true);
  edit:EnableMouse(true);
  edit:SetMaxLetters(1000);

  --edit:SetFontObject('ChatFontNormal');
  --edit:SetFontObject(GameFontNormal);
  edit:SetFont(GameFontNormal:GetFont(), 16, 'THINOUTLINE');

  edit:SetSize(width, height);

  edit:SetPoint('TOPLEFT', scroll, 'TOPLEFT', 0, 0);
  edit:SetPoint('BOTTOMRIGHT', scroll, 'BOTTOMRIGHT', 0, 0);
  edit:SetTextInsets(8, 8, 8, 8);
  edit:HookScript('OnEscapePressed', edit.ClearFocus);
  edit:Show();

  return edit;
end

local function createBack (name, parent, width, height, anchors)
  local back = CreateFrame('Frame', name .. 'Back', parent, BACKDROP_TEMPLATE);

  back:SetBackdrop({
    -- bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\PVPFrame\\UI-Character-PVP-Highlight',
    edgeSize = 10,
    -- insets = { left = 20, right = 20, top = 20, bottom = 20 },
  });

  back:SetSize(width, height);
  back:SetPoint(anchors.anchor, anchors.parent, anchors.parentAnchor,
      anchors.xOffset, anchors.yOffset);

  return back;
end

local function createTextField (name, parent, width, height, anchors)
  local back = createBack(name, parent, width, height, anchors);
  local edit = createEditbox(name, back, width, height);

  return edit;
end

function EditBox:new (parent, name, anchorFrame, xOffset, yOffset, width,
                      height, anchor, parentAnchor)
  local this = CreateFromMixins(EditBox);

  this.textField = createTextField(name, parent, width, height, {
    anchor = anchor or 'TOPLEFT',
    parent = anchorFrame,
    parentAnchor = parentAnchor or 'BOTTOMLEFT',
    xOffset = xOffset,
    yOffset = yOffset,
  });

  return this;
end

function EditBox:GetText ()
  return self.textField:GetText();
end

function EditBox:SetText (text)
  self.textField:SetText(text);
end

EditBox.GetValue = EditBox.GetText;
EditBox.SetValue = EditBox.SetText;
