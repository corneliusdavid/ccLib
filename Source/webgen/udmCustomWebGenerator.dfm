object dmCustomWebGenerator: TdmCustomWebGenerator
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 222
  Width = 247
  object PageProducer: TPageProducer
    OnHTMLTag = PageProducerHTMLTag
    Left = 56
    Top = 24
  end
  object DataSetTableProducer: TDataSetTableProducer
    MaxRows = 999
    TableAttributes.Border = 3
    TableAttributes.CellSpacing = 1
    TableAttributes.CellPadding = 8
    TableAttributes.Width = 0
    OnFormatCell = DataSetTableProducerFormatCell
    Left = 56
    Top = 72
  end
end
