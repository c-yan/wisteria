object MainForm: TMainForm
  Left = 20
  Top = 20
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #34276' -Resizer-'
  ClientHeight = 183
  ClientWidth = 396
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  Menu = MainMenu
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 16
  object StatusBar: TStatusBar
    Left = 0
    Top = 161
    Width = 396
    Height = 22
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    Panels = <>
    SimplePanel = True
    SizeGrip = False
    UseSystemFont = False
  end
  object SizeGroupBox: TGroupBox
    Left = 8
    Top = 2
    Width = 205
    Height = 95
    Caption = #22823#12365#12373
    TabOrder = 1
    object Label1: TLabel
      Left = 10
      Top = 20
      Width = 15
      Height = 16
      Caption = #24133
    end
    object Label2: TLabel
      Left = 10
      Top = 47
      Width = 25
      Height = 16
      Caption = #39640#12373
    end
    object UnitLabel1: TLabel
      Left = 153
      Top = 20
      Width = 12
      Height = 16
      Caption = '%'
      ShowAccelChar = False
    end
    object UnitLabel2: TLabel
      Left = 153
      Top = 48
      Width = 12
      Height = 16
      Caption = '%'
      ShowAccelChar = False
    end
    object WidthEdit: TEdit
      Left = 44
      Top = 16
      Width = 100
      Height = 24
      TabOrder = 0
      Text = '100'
      OnChange = WidthEditChange
    end
    object HeightEdit: TEdit
      Left = 44
      Top = 44
      Width = 100
      Height = 24
      TabOrder = 1
      Text = '100'
      OnChange = HeightEditChange
    end
    object RatioKeepCheckBox: TCheckBox
      Left = 8
      Top = 70
      Width = 139
      Height = 17
      Caption = #32294#27178#27604#12434#32173#25345#12377#12427
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = RatioKeepCheckBoxClick
    end
  end
  object FilePatternGroupBox: TGroupBox
    Left = 8
    Top = 104
    Width = 205
    Height = 47
    Caption = #12501#12449#12452#12523#21517#12398#29983#25104#35215#21063
    TabOrder = 2
    object FilePatternEdit: TEdit
      Left = 9
      Top = 17
      Width = 186
      Height = 24
      TabOrder = 0
      Text = '%p\%n_s.bmp'
    end
  end
  object SizeRadioGroup: TRadioGroup
    Left = 222
    Top = 2
    Width = 168
    Height = 45
    Caption = #22823#12365#12373#12398#25351#23450
    Columns = 2
    ItemIndex = 1
    Items.Strings = (
      #32118#23550#25351#23450
      #30456#23550#25351#23450)
    TabOrder = 3
    OnClick = SizeRadioGroupClick
  end
  object HTMLCheckBox: TCheckBox
    Left = 222
    Top = 108
    Width = 113
    Height = 17
    Caption = 'HTML'#12434#20986#21147#12377#12427
    TabOrder = 5
  end
  object CondGroupBox: TGroupBox
    Left = 222
    Top = 52
    Width = 168
    Height = 45
    Caption = #26465#20214
    TabOrder = 4
    object CondComboBox: TComboBox
      Left = 8
      Top = 16
      Width = 153
      Height = 24
      Style = csDropDownList
      TabOrder = 0
      Items.Strings = (
        #24133#22522#28310
        #39640#12373#22522#28310
        #38263#36794#22522#28310
        #30701#36794#22522#28310
        #26368#22823
        #26368#23567)
    end
  end
  object MainMenu: TMainMenu
    AutoHotkeys = maManual
    AutoLineReduction = maManual
    Left = 224
    Top = 120
    object FileMenu: TMenuItem
      Caption = #25991#26360'(&F)'
      object OpenMenu: TMenuItem
        Caption = #35373#23450#12398#35501#36796'(&O)...'
        Hint = #35373#23450#12434#22806#37096#12501#12449#12452#12523#12363#12425#35501#12415#36796#12415#12414#12377
        ShortCut = 16463
        OnClick = OpenMenuClick
      end
      object SaveMenu: TMenuItem
        Caption = #35373#23450#12398#20445#23384'(&S)...'
        Hint = #35373#23450#12434#22806#37096#12501#12449#12452#12523#12395#20445#23384#12375#12414#12377
        ShortCut = 16467
        OnClick = SaveMenuClick
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object ClipBoardMenu: TMenuItem
        Caption = #36028#12426#20184#12369'(&P)'
        Hint = #20837#21147#12392#12375#12390#12463#12522#12483#12503#12508#12540#12489#12395#12354#12427#30011#20687#12434#20351#29992#12375#12414#12377
        OnClick = ClipBoardMenuClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object ExitMenu: TMenuItem
        Caption = #32066#20102'(&X)'
        Hint = #34276#12434#32066#20102#12375#12414#12377
        OnClick = ExitMenuClick
      end
    end
    object ConfigMenu: TMenuItem
      Caption = #35373#23450'(&C)'
      object OutputMenu: TMenuItem
        Caption = #20986#21147'(&O)'
        object AutoIndexedMenu: TMenuItem
          Caption = #12452#12531#12487#12483#12463#12473#12459#12521#12540#12391#20986#21147#12377#12427'(&A)'
          Hint = '256'#33394#26410#28288#12398#22580#21512#12395#12452#12531#12487#12483#12463#12473#12459#12521#12540#12391#20986#21147#12375#12414#12377
          OnClick = CheckMenuClick
        end
        object ExifAutoRotateMenu: TMenuItem
          Caption = #33258#21205#22238#36578'(&R)'
          Hint = 'Exif '#24773#22577#12434#21462#24471#12375#12390#33258#21205#12391#22238#36578#12434#12375#12414#12377
          OnClick = CheckMenuClick
        end
        object NonMagnifyMenu: TMenuItem
          Caption = #25313#22823#12375#12394#12356'(&N)'
          Hint = #25351#23450#12469#12452#12474#12424#12426#20837#21147#30011#20687#12364#23567#12373#12356#22580#21512#12395#12469#12452#12474#22793#26356#12434#34892#12356#12414#12379#12435
          OnClick = CheckMenuClick
        end
        object N3: TMenuItem
          Caption = '-'
        end
        object AvoidCollisionMenu: TMenuItem
          Caption = #12501#12449#12452#12523#21517#12398#34909#31361#12434#36991#12369#12427'(&N)'
          Checked = True
          Hint = #12501#12449#12452#12523#12434#19978#26360#12365#12375#12394#12356#12424#12358#12395#12375#12414#12377
          OnClick = CheckMenuClick
        end
        object CopyTimeStampMenu: TMenuItem
          Caption = #26356#26032#26085#26178#12434#20889#12377'(&T)'
          Hint = #29983#25104#12373#12428#12427#12501#12449#12452#12523#12395#26356#26032#26085#26178#12434#35079#20889#12375#12414#12377
          OnClick = CheckMenuClick
        end
        object HTMLReversePlaceMenu: TMenuItem
          Caption = #20986#21147#20596#12395' HTML '#12434#20986#21147#12377#12427'(&A)'
          Hint = #20837#21147#30011#20687#20596#12391#12399#12394#12367#12289#20986#21147#30011#20687#20596#12395' HTML '#12434#20986#21147#12375#12414#12377
          OnClick = CheckMenuClick
        end
      end
      object CompressionMenu: TMenuItem
        Caption = #22311#32302'(&C)'
        object JpegQualityMenu: TMenuItem
          Caption = 'JPEG '#30011#36074'(&J)...'
          Hint = 'JPEG '#20986#21147#26178#12398#30011#36074#12434#35373#23450#12375#12414#12377
          OnClick = JpegQualityMenuClick
        end
        object ProgressiveJpegMenu: TMenuItem
          Caption = #12503#12525#12464#12524#12483#12471#12502' JPEG '#20986#21147'(&P)'
          Checked = True
          Hint = 'JPEG '#20986#21147#12434#12503#12525#12464#12524#12483#12471#12502' JPEG '#12395#12375#12414#12377
          OnClick = CheckMenuClick
        end
        object N8: TMenuItem
          Caption = '-'
        end
        object PngCompressMenu: TMenuItem
          Caption = 'PNG '#22311#32302#29575'(&C)...'
          Hint = 'PNG'#12398#22311#32302#29575#12434#35373#23450#12375#12414#12377
          OnClick = PngCompressMenuClick
        end
      end
      object N10: TMenuItem
        Caption = #25313#22823'(&E)'
        object Enlarge1Menu: TMenuItem
          Tag = 1
          Caption = #26368#36817#20621#35036#38291'(&N)'
          Hint = #25313#22823#12450#12523#12468#12522#12474#12512#12434#26368#36817#20621#35036#38291#12395#35373#23450#12375#12414#12377
          RadioItem = True
          OnClick = CheckMenuClick
        end
        object Enlarge2Menu: TMenuItem
          Tag = 2
          Caption = #32218#24418#35036#38291'(&L)'
          Hint = #25313#22823#12450#12523#12468#12522#12474#12512#12434#32218#24418#35036#38291#12395#35373#23450#12375#12414#12377
          RadioItem = True
          OnClick = CheckMenuClick
        end
        object Enlarge3Menu: TMenuItem
          Tag = 3
          Caption = '2-lobed Lanczos-windowed sinc '#35036#38291'(&2)'
          Hint = #25313#22823#12450#12523#12468#12522#12474#12512#12434' 2-lobed Lanczos-windowed sinc '#35036#38291#12395#35373#23450#12375#12414#12377
          RadioItem = True
          OnClick = CheckMenuClick
        end
        object Enlarge4Menu: TMenuItem
          Tag = 4
          Caption = '3-lobed Lanczos-windowed sinc '#35036#38291'(&3)'
          Checked = True
          Hint = #25313#22823#12450#12523#12468#12522#12474#12512#12434' 3-lobed Lanczos-windowed sinc '#35036#38291#12395#35373#23450#12375#12414#12377
          RadioItem = True
          OnClick = CheckMenuClick
        end
        object Enlarge5Menu: TMenuItem
          Tag = 5
          Caption = '4-lobed Lanczos-windowed sinc '#35036#38291'(&4)'
          Hint = #25313#22823#12450#12523#12468#12522#12474#12512#12434' 4-lobed Lanczos-windowed sinc '#35036#38291#12395#35373#23450#12375#12414#12377
          RadioItem = True
          OnClick = CheckMenuClick
        end
      end
      object N11: TMenuItem
        Caption = #32302#23567'(&D)'
        object Reduce1Menu: TMenuItem
          Tag = 1
          Caption = #26368#36817#20621#35036#38291'(&N)'
          Hint = #32302#23567#12450#12523#12468#12522#12474#12512#12434#26368#36817#20621#35036#38291#12395#35373#23450#12375#12414#12377
          RadioItem = True
          OnClick = CheckMenuClick
        end
        object Reduce2Menu: TMenuItem
          Tag = 2
          Caption = #24179#22343#30011#32032#27861'(&A)'
          Checked = True
          Hint = #32302#23567#12450#12523#12468#12522#12474#12512#12434#24179#22343#30011#32032#27861#12395#35373#23450#12375#12414#12377
          RadioItem = True
          OnClick = CheckMenuClick
        end
        object Reduce3Menu: TMenuItem
          Tag = 3
          Caption = '2-lobed Lanczos-windowed sinc '#35036#38291'(&2)'
          Hint = #32302#23567#12450#12523#12468#12522#12474#12512#12434' 2-lobed Lanczos-windowed sinc '#35036#38291#12395#35373#23450#12375#12414#12377
          RadioItem = True
          OnClick = CheckMenuClick
        end
        object Reduce4Menu: TMenuItem
          Tag = 4
          Caption = '3-lobed Lanczos-windowed sinc '#35036#38291'(&3)'
          Hint = #32302#23567#12450#12523#12468#12522#12474#12512#12434' 3-lobed Lanczos-windowed sinc '#35036#38291#12395#35373#23450#12375#12414#12377
          RadioItem = True
          OnClick = CheckMenuClick
        end
        object Reduce5Menu: TMenuItem
          Tag = 5
          Caption = '4-lobed Lanczos-windowed sinc '#35036#38291'(&4)'
          Hint = #32302#23567#12450#12523#12468#12522#12474#12512#12434' 4-lobed Lanczos-windowed sinc '#35036#38291#12395#35373#23450#12375#12414#12377
          RadioItem = True
          OnClick = CheckMenuClick
        end
        object N6: TMenuItem
          Caption = '-'
        end
        object LinearizedReductionMenu: TMenuItem
          Caption = #30011#32032#12434#32218#24418#20516#12395#22793#25563#12375#12390#20966#29702#12377#12427
          Checked = True
          OnClick = CheckMenuClick
        end
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object OnTopMenu: TMenuItem
        Caption = #25163#21069#12395#34920#31034'(&T)'
        Checked = True
        Hint = #24120#12395#26368#21069#38754#12395#34920#31034#12373#12428#12427#12424#12358#12395#12375#12414#12377
        OnClick = OnTopMenuClick
      end
      object IdleModeMenu: TMenuItem
        Caption = 'CPU '#12364#26247#12394#12392#12365#12395#20966#29702#12377#12427'(&I)'
        Checked = True
        Hint = #20182#12398#12450#12503#12522#12465#12540#12471#12519#12531#12398#37034#39764#12395#12394#12425#12394#12356#12424#12358#21205#20316#12375#12414#12377
        OnClick = IdleModeMenuClick
      end
      object OpenFolderMenu: TMenuItem
        Caption = #20966#29702#24460#12395#12501#12457#12523#12480#12434#38283#12367'(&A)'
        Hint = #20966#29702#24460#12395#35442#24403#12398#12501#12457#12523#12480#12434#38283#12365#12414#12377
        OnClick = CheckMenuClick
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object IncludeSubDirMenu: TMenuItem
        Caption = #12469#12502#12487#12451#12524#12463#12488#12522#12418#20966#29702#12377#12427'(&R)'
        Hint = #12487#12451#12524#12463#12488#12522#12434#25351#23450#12375#12383#12392#12365#12395#12289#12469#12502#12487#12451#12524#12463#12488#12522#12418#20966#29702#12398#23550#35937#12392#12375#12414#12377
        OnClick = CheckMenuClick
      end
      object FileListSortMenu: TMenuItem
        Caption = #20837#21147#12501#12449#12452#12523#32676#12434#25972#21015#12377#12427'(&S)'
        Hint = #20837#21147#12501#12449#12452#12523#32676#12434#12501#12449#12452#12523#12497#12473#12391#26119#38918#25972#21015#12375#12414#12377
        OnClick = CheckMenuClick
      end
    end
    object EffectMenu: TMenuItem
      Caption = #21177#26524'(&E)'
      object WhiteFilterMenu: TMenuItem
        Caption = #30333#33394#21270'(&W)'
        Hint = #25351#23450#36637#24230#20197#19978#12398#30011#32032#12434#30333#33394#21270#12375#12414#12377
        OnClick = CheckMenuClick
      end
      object TrimMenu: TMenuItem
        Caption = #20999#12426#25244#12365'(&T)'
        Hint = #30011#20687#12434#20999#12426#25244#12365#12414#12377
        OnClick = CheckMenuClick
      end
      object TurnOverMenu: TMenuItem
        Caption = #21453#36578'(&F)'
        Hint = #30011#20687#12434#21453#36578#12375#12414#12377
        OnClick = CheckMenuClick
      end
      object RotateMenu: TMenuItem
        Caption = #22238#36578'(&R)'
        Hint = #30011#20687#12434#22238#36578#12375#12414#12377
        OnClick = CheckMenuClick
      end
      object GammaFixMenu: TMenuItem
        Caption = #12460#12531#12510#35036#27491'(&G)'
        Hint = #12460#12531#12510#35036#27491#12434#34892#12356#12414#12377
        OnClick = CheckMenuClick
      end
      object NormalizeMenu: TMenuItem
        Caption = #27491#35215#21270'(&N)'
        Hint = #27491#35215#21270#12434#34892#12356#12414#12377
        OnClick = CheckMenuClick
      end
      object LumaFixMenu: TMenuItem
        Caption = #36637#24230#35036#27491'(&L)'
        Hint = #36637#24230#35036#27491#12434#34892#12356#12414#12377
        OnClick = CheckMenuClick
      end
      object ContrastFixMenu: TMenuItem
        Caption = #12467#12531#12488#12521#12473#12488#35036#27491'(&C)'
        Hint = #12467#12531#12488#12521#12473#12488#35036#27491#12434#34892#12356#12414#12377
        OnClick = CheckMenuClick
      end
      object CleanEffectMenu: TMenuItem
        Caption = #12494#12452#12474#38500#21435'(&A)'
        Hint = #12494#12452#12474#38500#21435#12434#34892#12356#12414#12377
        OnClick = CheckMenuClick
      end
      object SharpEffectMenu: TMenuItem
        Caption = #36650#37101#24375#35519'(&S)'
        Hint = #36650#37101#24375#35519#12434#34892#12356#12414#12377
        OnClick = CheckMenuClick
      end
      object GrayscaleMenu: TMenuItem
        Caption = #30333#40658#21270'(&M)'
        Hint = #30333#40658#30011#20687#12408#12398#22793#25563#12434#34892#12356#12414#12377
        OnClick = CheckMenuClick
      end
      object LMapMenu: TMenuItem
        Caption = 'LMap'
        Visible = False
        OnClick = CheckMenuClick
      end
    end
    object ValuesMenu: TMenuItem
      Caption = #20516'(&V)'
      object WhiteValueMenu: TMenuItem
        Caption = #30333#33394#21270#38334#20516'(&W)...'
        Hint = #30333#33394#21270#12398#38334#20516#12434#35373#23450#12375#12414#12377
        OnClick = WhiteValueMenuClick
      end
      object TrimValueMenu: TMenuItem
        Caption = #20999#12426#25244#12365#31684#22258'(&T)...'
        Hint = #20999#12426#25244#12365#31684#22258#12434#35373#23450#12375#12414#12377
        OnClick = TrimValueMenuClick
      end
      object RotateAngleMenu: TMenuItem
        Caption = #22238#36578#35282#24230'(&R)...'
        Hint = #22238#36578#35282#24230#12434#35373#23450#12375#12414#12377
        OnClick = RotateAngleMenuClick
      end
      object GammaValueMenu: TMenuItem
        Caption = #12460#12531#12510#27604'(&G)...'
        Hint = #12460#12531#12510#27604#12434#35373#23450#12375#12414#12377
        OnClick = GammaValueMenuClick
      end
      object NormalizeRangeMenu: TMenuItem
        Caption = #27491#35215#21270#31684#22258'(&N)...'
        Hint = #27491#35215#21270#31684#22258#12434#35373#23450#12375#12414#12377
        OnClick = NormalizeRangeMenuClick
      end
      object LumaRangeMenu: TMenuItem
        Caption = #36637#24230#31684#22258'(&L)...'
        Hint = #36637#24230#31684#22258#12434#35373#23450#12375#12414#12377
        OnClick = LumaRangeMenuClick
      end
      object ContrastValueMenu: TMenuItem
        Caption = #12467#12531#12488#12521#12473#12488#27604'(&C)...'
        Hint = #12467#12531#12488#12521#12473#12488#27604#12434#35373#23450#12375#12414#12377
        OnClick = ContrastValueMenuClick
      end
      object CleanValueMenu: TMenuItem
        Caption = #12494#12452#12474#38500#21435#24230'(&A)...'
        Hint = #12494#12452#12474#38500#21435#12398#24375#12373#12434#35373#23450#12375#12414#12377
        OnClick = CleanValueMenuClick
      end
      object SharpValueMenu: TMenuItem
        Caption = #36650#37101#24375#35519#24230'(&S)...'
        Hint = #36650#37101#24375#35519#12398#24375#12373#12434#35373#23450#12375#12414#12377
        OnClick = SharpValueMenuClick
      end
      object GrayscaleMethodMenu: TMenuItem
        Caption = #30333#40658#21270#27861'(&M)...'
        Hint = #36637#24230#12398#35336#31639#24335#12434#35373#23450#12375#12414#12377
        OnClick = GrayscaleMethodMenuClick
      end
      object LMapValueMenu: TMenuItem
        Caption = 'LMap'
        Visible = False
        OnClick = LMapValueMenuClick
      end
    end
    object SampleMenu: TMenuItem
      Caption = #38619#22411'(&S)'
    end
    object HelpMenu: TMenuItem
      Caption = #24773#22577'(&H)'
      object AboutMenu: TMenuItem
        Caption = #34276#12395#12388#12356#12390'(&A)...'
        Hint = #12496#12540#12472#12519#12531#24773#22577#31561#12434#34920#31034#12375#12414#12377
        OnClick = AboutMenuClick
      end
      object ShowHelpMenu: TMenuItem
        Caption = #12504#12523#12503'(&H)'
        Hint = #12504#12523#12503#12501#12449#12452#12523#12434#34920#31034#12375#12414#12377
        OnClick = ShowHelpMenuClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object GoWebMenu: TMenuItem
        Caption = #20316#32773#12398#12506#12540#12472#12434#38283#12367'(&W)'
        Hint = #20316#32773#12398#12454#12455#12502#12506#12540#12472#12434#38283#12365#12414#12377
        OnClick = GoWebMenuClick
      end
      object GoGitHubMenu: TMenuItem
        Caption = #12477#12540#12473#12467#12540#12489#12398#12506#12540#12472#12434#38283#12367
        Hint = #12477#12540#12473#12467#12540#12489#12398#12454#12455#12502#12506#12540#12472#12434#38283#12365#12414#12377
        OnClick = GoGitHubMenuClick
      end
      object GoGitHubIssuesMenu: TMenuItem
        Caption = #19981#20855#21512#12539#35201#26395#31649#29702#12398#12506#12540#12472#12434#38283#12367
        Hint = #19981#20855#21512#12539#35201#26395#31649#29702#12398#12454#12455#12502#12506#12540#12472#12434#38283#12365#12414#12377
        OnClick = GoGitHubIssuesMenuClick
      end
      object SendMailMenu: TMenuItem
        Caption = #20316#32773#12395#12513#12540#12523#12434#20986#12377'(&M)'
        Hint = #20316#32773#12395#12513#12540#12523#12434#20986#12375#12414#12377
        OnClick = SendMailMenuClick
      end
    end
  end
  object OpenDialog: TOpenDialog
    DefaultExt = 'ini'
    Filter = #35373#23450#12501#12449#12452#12523' (*.ini)|*.ini|'#20840#12390#12398#12501#12449#12452#12523' (*.*)|*.*'
    Title = #35373#23450#12398#35501#12415#36796#12415
    Left = 288
    Top = 120
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'ini'
    Filter = #35373#23450#12501#12449#12452#12523' (*.ini)|*.ini|'#20840#12390#12398#12501#12449#12452#12523' (*.*)|*.*'
    Title = #35373#23450#12398#20445#23384
    Left = 352
    Top = 120
  end
end
