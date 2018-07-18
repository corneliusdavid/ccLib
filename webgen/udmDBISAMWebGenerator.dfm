inherited dmDBISAMWebGenerator: TdmDBISAMWebGenerator
  OldCreateOrder = True
  Height = 284
  Width = 304
  object qryWebPics: TDBISAMQuery
    AutoDisplayLabels = False
    CopyOnAppend = False
    EngineVersion = '4.21 Build 11'
    MaxRowCount = -1
    SQL.Strings = (
      'select PicFile, Desc '
      'from webpics'
      'where Name = :Name')
    Params = <
      item
        DataType = ftString
        Name = 'Name'
      end>
    Left = 176
    Top = 144
    ParamData = <
      item
        DataType = ftString
        Name = 'Name'
      end>
    object qryWebPicsPicFile: TStringField
      FieldName = 'PicFile'
      Origin = 'webpics.PicFile'
      Size = 200
    end
    object qryWebPicsDesc: TStringField
      FieldName = 'Desc'
      Origin = 'webpics.Desc'
      Size = 400
    end
  end
  object qryGeneral: TDBISAMQuery
    AutoDisplayLabels = False
    CopyOnAppend = False
    EngineVersion = '4.21 Build 11'
    MaxRowCount = -1
    SQL.Strings = (
      'select IntVal, FloatVal, DateVal, TimeVal, StrVal, MemoVal'
      'from General'
      'where Name = :Name')
    Params = <
      item
        DataType = ftString
        Name = 'Name'
      end>
    Left = 176
    Top = 32
    ParamData = <
      item
        DataType = ftString
        Name = 'Name'
      end>
    object qryGeneralIntVal: TIntegerField
      FieldName = 'IntVal'
      Origin = 'General.IntVal'
    end
    object qryGeneralFloatVal: TFloatField
      FieldName = 'FloatVal'
      Origin = 'General.FloatVal'
    end
    object qryGeneralDateVal: TDateField
      FieldName = 'DateVal'
      Origin = 'General.DateVal'
    end
    object qryGeneralTimeVal: TTimeField
      FieldName = 'TimeVal'
      Origin = 'General.TimeVal'
    end
    object qryGeneralStrVal: TStringField
      FieldName = 'StrVal'
      Origin = 'General.StrVal'
      Size = 200
    end
    object qryGeneralMemoVal: TBlobField
      FieldName = 'MemoVal'
      Origin = 'General.MemoVal'
    end
  end
  object qryStoredProcs: TDBISAMQuery
    AutoDisplayLabels = False
    CopyOnAppend = False
    AfterOpen = qryAfterOpen
    EngineVersion = '4.21 Build 11'
    MaxRowCount = -1
    SQL.Strings = (
      'select name, sql from StoredSQL where name = :name')
    Params = <
      item
        DataType = ftString
        Name = 'name'
      end>
    Left = 176
    Top = 88
    ParamData = <
      item
        DataType = ftString
        Name = 'name'
      end>
    object qryStoredProcsname: TStringField
      FieldName = 'name'
      Origin = 'StoredSQL.name'
      Size = 30
    end
    object qryStoredProcssql: TMemoField
      FieldName = 'sql'
      Origin = 'StoredSQL.sql'
      BlobType = ftMemo
    end
  end
  object qryDynamic: TDBISAMQuery
    AutoDisplayLabels = False
    CopyOnAppend = False
    AfterOpen = qryAfterOpen
    EngineVersion = '4.21 Build 11'
    MaxRowCount = -1
    Params = <>
    Left = 176
    Top = 200
  end
end
