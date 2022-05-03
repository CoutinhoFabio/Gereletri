unit u_gera_barcode;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, ExtCtrls, StdCtrls, Buttons,
  PrintersDlgs, ZDataset, ubarcodes, Graphics, Printers;

type

  { TW_GenerateBarCode }

  TW_GenerateBarCode = class(TForm)
    BarcodeQR1: TBarcodeQR;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    BtnImprimir: TSpeedButton;
    BtnSair: TSpeedButton;
    BtnSalvar: TSpeedButton;
    PrintDialog1: TPrintDialog;
    procedure BtnImprimirClick(Sender: TObject);
    procedure BtnSairClick(Sender: TObject);
    procedure BtnSalvarClick(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure DrawBarcode(content: string);
  public

  end;

var
  W_GenerateBarCode: TW_GenerateBarCode;

implementation
  uses U_Main, TypInfo;

{$R *.lfm}

{ TW_GenerateBarCode }

//==============================================================================
//   Form - On Show
//==============================================================================
procedure TW_GenerateBarCode.FormShow(Sender: TObject);
var
  temp_query: TZQuery;
begin
  temp_query:= TZQuery.Create(self);
  temp_query.Connection:= W_Main.ZConnection1;
  temp_query.SQL.Text:= 'SELECT DISTINCT nome FROM Produtos';
  temp_query.Open;
  ComboBox1.OnChange:= nil;
  ComboBox1.Items.Clear;
  temp_query.First;
  while not temp_query.EOF do
  begin
    ComboBox1.Items.Add(temp_query.FieldByName('nome').AsString);
    temp_query.Next;
  end;
  temp_query.Close;
  temp_query.Free;

  if(ComboBox1.Items.Count > 0)then
  begin
    ComboBox1.ItemIndex:= 0;
    DrawBarcode('Produto: ' + ComboBox1.Text + #13#10 +
                'Serial: ');
  end;
  ComboBox1.OnChange:= @ComboBox1Change;
end;

//==============================================================================
//   Draw Bar Code
//==============================================================================
procedure TW_GenerateBarCode.DrawBarcode(content: string);
begin
  BarcodeQR1.Text:= content;
  BarcodeQR1.Generate;
end;

//==============================================================================
//   Btn Imprimir - On Click
//==============================================================================
procedure TW_GenerateBarCode.BtnImprimirClick(Sender: TObject);
var
  rectPage: TRect;
  image1: Graphics.TBitmap;
begin
  try
    if PrintDialog1.Execute then
    begin
      rectPage := Rect(0, 0, Printer.PageWidth, Printer.PageHeight);
      with Printer do
      begin
        //start printing
        BeginDoc;
        BarcodeQR1.SaveToFile('tmp_barcode.bmp');
        image1:= Graphics.TBitmap.Create;
        image1.LoadFromFile('tmp_barcode.bmp');
        Canvas.StretchDraw(Rect(500, 500, 1000, 1000), image1);
        image1.Free;
        DeleteFile('tmp_barcode.bmp');
        //finish printing
        EndDoc;
      end;
      ShowMessage('Impressão concluída');
    end;
  except

    ShowMessage('Ocorreu um erro inesperado');
  end;
  //PrinterSetupDialog1.Execute;
  //frReport1.LoadFromFile('Barcode.lrf');
  //frReport1.ShowReport;
end;

//==============================================================================
//   Btn Sair - On Click
//==============================================================================
procedure TW_GenerateBarCode.BtnSairClick(Sender: TObject);
begin
  Close;
end;

//==============================================================================
//   Btn Salvar - On Click
//==============================================================================
procedure TW_GenerateBarCode.BtnSalvarClick(Sender: TObject);
var
  temp_query: TZQuery;
  id_prod: integer;
  serie: string;
begin
  if(ComboBox1.Text = '')then
  begin
    ShowMessage('Selecione o produto');
    ComboBox1.SetFocus;
    Exit;
  end;

  if(Edit1.Text = '')then
  begin
    ShowMessage('insira o conteudo do texto');
    Edit1.SetFocus;
    Exit;
  end;
  serie:= Edit1.Text;

  //captura o id do produto selecionado
  temp_query:= TZQuery.Create(self);
  temp_query.Connection:= W_Main.ZConnection1;
  temp_query.SQL.Text:= 'SELECT id FROM Produtos WHERE nome = ' +
                        QuotedStr(ComboBox1.Text);
  temp_query.Open;
  id_prod:= temp_query.Fields[0].AsInteger;
  temp_query.Close;

  //verifica se o código de série não foi registrado ainda
  temp_query.SQL.Clear;
  temp_query.SQL.Text:= 'SELECT COUNT(1) FROM Historico WHERE serie=' + QuotedStr(serie);
  temp_query.Open;
  if(temp_query.Fields[0].AsInteger <> 0)then
  begin
    ShowMessage('Já existe um registro com o mesmo código');
    temp_query.Close;
    temp_query.Free;
  end
  else
  begin
    temp_query.Close;
    temp_query.SQL.Clear();
    temp_query.SQL.Text:= 'INSERT INTO Historico(id_prod,serie,data) ' +
                          'VALUES(:id_prod,:serie,:data)';
    temp_query.ParamByName('id_prod').AsInteger:= id_prod;
    temp_query.ParamByName('serie').AsString:= serie;
    temp_query.ParamByName('data').AsString:= DateToStr(Now());
    temp_query.ExecSQL;
    temp_query.Close;
    temp_query.Free;
    W_Main.ZConnection1.Connected:= True;
  end;

  {
  temp_query.SQL.Text:= 'IF NOT EXISTS (SELECT id_prod,serie FROM Historico '+
                        'WHERE id= ' + QuotedStr(id_prod) + ' AND ' +
                        'serie = ' + QuotedStr(serie) + ')' +
                        'BEGIN ' +
                           'INSERT INTO Historico(id_prod,serie,data) ' +
                            'VALUES(' +
                                     QuotedStr(id_prod) + ',' +
                                     QuotedStr(serie) +
                                     QuotedStr(DateToStr(Now())) +
                                   ') ' +
                        'END';
  temp_query.ExecSQL;
  temp_query.Close;
  temp_query.Free;
  }

  ShowMessage('Código de barras salvo no histórico');
end;

//==============================================================================
//   ComboBox Produto - On Change
//==============================================================================
procedure TW_GenerateBarCode.ComboBox1Change(Sender: TObject);
begin
  DrawBarcode('Produto: ' + ComboBox1.Text + #13#10 + 'Serie: ' + Edit1.Text);
end;

//==============================================================================
//   Edit Texto - On Change
//==============================================================================
procedure TW_GenerateBarCode.Edit1Change(Sender: TObject);
begin
  DrawBarcode('Produto: ' + ComboBox1.Text + #13#10 + 'Serie: ' + Edit1.Text);
end;

end.

