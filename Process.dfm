object ProcessForm: TProcessForm
  Left = 294
  Top = 162
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = #20966#29702#29366#27841
  ClientHeight = 185
  ClientWidth = 382
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 16
    Top = 80
    Width = 74
    Height = 16
    Caption = #32076#36942' ('#20840#20307')'
  end
  object Label2: TLabel
    Left = 16
    Top = 112
    Width = 74
    Height = 16
    Caption = #32076#36942' ('#20491#21029')'
  end
  object GlobalLabel: TLabel
    Left = 347
    Top = 80
    Width = 19
    Height = 16
    Alignment = taRightJustify
    Caption = '0%'
  end
  object LocalLabel: TLabel
    Left = 347
    Top = 112
    Width = 19
    Height = 16
    Alignment = taRightJustify
    Caption = '0%'
  end
  object FileNameLabel: TLabel
    Left = 120
    Top = 16
    Width = 4
    Height = 16
  end
  object Label6: TLabel
    Left = 16
    Top = 16
    Width = 99
    Height = 16
    Caption = #20966#29702#20013#12398#12501#12449#12452#12523
  end
  object Label7: TLabel
    Left = 16
    Top = 48
    Width = 60
    Height = 16
    Caption = #20966#29702#20869#23481
  end
  object SituationLabel: TLabel
    Left = 120
    Top = 48
    Width = 4
    Height = 16
  end
  object GlobalProgressBar: TProgressBar
    Left = 96
    Top = 80
    Width = 228
    Height = 13
    TabOrder = 1
  end
  object LocalProgressBar: TProgressBar
    Left = 96
    Top = 112
    Width = 228
    Height = 13
    TabOrder = 2
  end
  object AbortButton: TButton
    Left = 158
    Top = 144
    Width = 75
    Height = 25
    Caption = #20013#26029
    TabOrder = 0
    OnClick = AbortButtonClick
  end
end
